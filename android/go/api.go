package mobile

import (
	"encoding/json"
	"fmt"
	"strings"
	"sync"
)

var (
	dataDir string
	initMu  sync.Mutex
)

type apiResponse struct {
	OK        bool             `json:"ok"`
	Error     string           `json:"error,omitempty"`
	Record    *ConfigRecord    `json:"record,omitempty"`
	Message   string           `json:"message,omitempty"`
	Connected *bool            `json:"connected,omitempty"`
	Lines     []bulkResultLine `json:"lines,omitempty"`
	Inbounds  []inboundSummary `json:"inbounds,omitempty"`
}

type bulkResultLine struct {
	Index      int    `json:"index"`
	Name       string `json:"name"`
	ConfigLink string `json:"configLink"`
	SubLink    string `json:"subLink"`
}

type bulkCreateRequest struct {
	BaseName       string  `json:"baseName"`
	Count          int     `json:"count"`
	TrafficLimitGB float64 `json:"trafficLimitGb"`
	ExpirationDays int     `json:"expirationDays"`
	InboundPort    int     `json:"inboundPort"`
	InboundIDs     []int   `json:"inboundIds,omitempty"`
	RemarkPattern  string  `json:"remarkPattern,omitempty"`
}

// Init stores the app data directory path. Returns empty string on success.
func Init(dir string) string {
	initMu.Lock()
	defer initMu.Unlock()
	dir = strings.TrimSpace(dir)
	if dir == "" {
		return "data directory is required"
	}
	dataDir = dir
	return ""
}

// ConnectPanelJSON opens a persistent panel session until DisconnectPanelJSON.
func ConnectPanelJSON(settingsJSON string) string {
	settings, err := parsePanelSettings(settingsJSON)
	if err != nil {
		return failJSON(err.Error())
	}
	if err := connectPanelSession(settings); err != nil {
		return failJSON(err.Error())
	}
	out, _ := json.Marshal(apiResponse{OK: true, Message: "Connected.", Connected: boolPtr(true)})
	return string(out)
}

// DisconnectPanelJSON closes the persistent panel session.
func DisconnectPanelJSON() string {
	invalidatePanelSessionCache()
	out, _ := json.Marshal(apiResponse{OK: true, Message: "Disconnected.", Connected: boolPtr(false)})
	return string(out)
}

// PanelConnectionStatusJSON returns whether a persistent session is active.
func PanelConnectionStatusJSON() string {
	connected := isPanelConnected()
	out, _ := json.Marshal(apiResponse{OK: true, Connected: &connected})
	return string(out)
}

// TestPanelConnectionJSON tests 3X-UI panel credentials without keeping session.
func TestPanelConnectionJSON(settingsJSON string) string {
	settings, err := parsePanelSettings(settingsJSON)
	if err != nil {
		return failJSON(err.Error())
	}
	if err := test3XUI(settings); err != nil {
		return failJSON(err.Error())
	}
	out, _ := json.Marshal(apiResponse{OK: true, Message: "Connection successful."})
	return string(out)
}

// ListInboundsJSON returns enabled/disabled inbounds from the connected panel session.
func ListInboundsJSON(settingsJSON string) string {
	settings, err := parsePanelSettings(settingsJSON)
	if err != nil {
		return failJSON(err.Error())
	}
	if !isPanelConnected() {
		return failJSON("panel is not connected — connect first")
	}
	client, _, err := getCachedPanelClient(settings)
	if err != nil {
		return failJSON(err.Error())
	}
	inbounds, err := client.listInbounds()
	if err != nil {
		return failJSON(err.Error())
	}
	summaries := make([]inboundSummary, 0, len(inbounds))
	for _, inbound := range inbounds {
		summaries = append(summaries, inboundSummary{
			ID:       inbound.ID,
			Protocol: strings.TrimSpace(inbound.Protocol),
			Remark:   strings.TrimSpace(inbound.Remark),
			Port:     inbound.Port,
			Enable:   inbound.Enable,
		})
	}
	out, _ := json.Marshal(apiResponse{OK: true, Inbounds: summaries})
	return string(out)
}

// CreateClientJSON creates a client on the panel using the cached session when available.
func CreateClientJSON(settingsJSON, requestJSON string) string {
	settings, err := parsePanelSettings(settingsJSON)
	if err != nil {
		return failJSON(err.Error())
	}
	if !isPanelConnected() {
		return failJSON("panel is not connected — connect first")
	}

	var payload createClientRequest
	if err := json.Unmarshal([]byte(requestJSON), &payload); err != nil {
		return failJSON("invalid create request: " + err.Error())
	}
	payload.Name = strings.TrimSpace(payload.Name)
	if payload.Name == "" {
		return failJSON("config name is required")
	}
	if len(payload.InboundIDs) == 0 && payload.InboundPort <= 0 {
		return failJSON("at least one inbound must be selected")
	}

	created, err := createClientOnPanel(settings, payload)
	if err != nil {
		return failJSON(err.Error())
	}

	record := created.Record
	out, _ := json.Marshal(apiResponse{OK: true, Record: &record, Message: "Config created."})
	return string(out)
}

// CreateBulkJSON creates multiple clients and returns numbered config/sub links.
func CreateBulkJSON(settingsJSON, requestJSON string) string {
	settings, err := parsePanelSettings(settingsJSON)
	if err != nil {
		return failJSON(err.Error())
	}
	if !isPanelConnected() {
		return failJSON("panel is not connected — connect first")
	}

	var req bulkCreateRequest
	if err := json.Unmarshal([]byte(requestJSON), &req); err != nil {
		return failJSON("invalid bulk request: " + err.Error())
	}
	req.BaseName = strings.TrimSpace(req.BaseName)
	if req.BaseName == "" || req.Count <= 0 {
		return failJSON("base name and count are required")
	}
	if len(req.InboundIDs) == 0 && req.InboundPort <= 0 {
		return failJSON("at least one inbound must be selected")
	}

	inboundIDs := req.InboundIDs
	if len(inboundIDs) == 0 {
		client, _, err := getCachedPanelClient(settings)
		if err != nil {
			return failJSON(err.Error())
		}
		inbounds, err := getPanelInbounds(client)
		if err != nil {
			return failJSON(err.Error())
		}
		inbound := pickInbound(inbounds, req.InboundPort)
		if inbound == nil {
			return failJSON(fmt.Sprintf("no enabled inbound on port %d", req.InboundPort))
		}
		inboundIDs = []int{inbound.ID}
	}

	total := req.Count * len(inboundIDs)
	lines := make([]bulkResultLine, 0, total)
	lineIndex := 0
	for _, inboundID := range inboundIDs {
		for i := 1; i <= req.Count; i++ {
			lineIndex++
			name := applyRemarkPattern(req.BaseName, i, req.RemarkPattern)
			created, err := createClientOnPanel(settings, createClientRequest{
				Name:           name,
				TrafficLimitGB: req.TrafficLimitGB,
				ExpirationDays: req.ExpirationDays,
				InboundIDs:     []int{inboundID},
			})
			if err != nil {
				return failJSON(fmt.Sprintf("bulk failed at %d: %s", lineIndex, err.Error()))
			}
			configLink := strings.TrimSpace(created.Record.ConfigLink)
			if configLink == "" {
				configLink = created.Link
			}
			subLink := strings.TrimSpace(created.Record.Link)
			lines = append(lines, bulkResultLine{
				Index:      lineIndex,
				Name:       name,
				ConfigLink: configLink,
				SubLink:    subLink,
			})
		}
	}

	out, _ := json.Marshal(apiResponse{OK: true, Lines: lines, Message: fmt.Sprintf("Bulk created: %d", len(lines))})
	return string(out)
}

// DeleteClientJSON removes a client from the panel by its email/name.
func DeleteClientJSON(settingsJSON, requestJSON string) string {
	settings, err := parsePanelSettings(settingsJSON)
	if err != nil {
		return failJSON(err.Error())
	}
	if !isPanelConnected() {
		return failJSON("panel is not connected — connect first")
	}

	var payload struct {
		Name        string `json:"name"`
		InboundPort int    `json:"inboundPort"`
	}
	if err := json.Unmarshal([]byte(requestJSON), &payload); err != nil {
		return failJSON("invalid delete request: " + err.Error())
	}
	payload.Name = strings.TrimSpace(payload.Name)
	if payload.Name == "" {
		return failJSON("config name is required")
	}
	if err := deleteClientOnPanel(settings, payload.Name, payload.InboundPort); err != nil {
		return failJSON(err.Error())
	}
	out, _ := json.Marshal(apiResponse{OK: true, Message: "Client deleted from panel."})
	return string(out)
}

func applyRemarkPattern(name string, index int, pattern string) string {
	pattern = strings.TrimSpace(pattern)
	if pattern == "" {
		return fmt.Sprintf("%s-%03d", name, index)
	}
	out := pattern
	out = strings.ReplaceAll(out, "{name}", name)
	out = strings.ReplaceAll(out, "{index}", fmt.Sprintf("%d", index))
	out = strings.ReplaceAll(out, "{index3}", fmt.Sprintf("%03d", index))
	return out
}

func parsePanelSettings(settingsJSON string) (PanelSettings, error) {
	var settings PanelSettings
	if err := json.Unmarshal([]byte(settingsJSON), &settings); err != nil {
		return settings, err
	}
	settings.PanelURL = strings.TrimSpace(settings.PanelURL)
	settings.SubURI = normalizeSubURIBase(settings.SubURI)
	settings.APIKey = strings.TrimSpace(settings.APIKey)
	if settings.PanelURL == "" {
		return settings, errRequired("panel URL is required")
	}
	if settings.APIKey != "" {
		return settings, nil
	}
	if strings.TrimSpace(settings.Username) == "" {
		return settings, errRequired("username is required")
	}
	if settings.Password == "" {
		return settings, errRequired("password is required")
	}
	return settings, nil
}

func boolPtr(v bool) *bool {
	return &v
}

func errRequired(msg string) error {
	return &requiredError{msg: msg}
}

type requiredError struct{ msg string }

func (e *requiredError) Error() string { return e.msg }

func failJSON(message string) string {
	out, _ := json.Marshal(apiResponse{OK: false, Error: message})
	return string(out)
}
