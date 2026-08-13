package mobile

import (
	"bytes"
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/http/cookiejar"
	"net/url"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/google/uuid"
)

const (
	maxAPIRetries     = 3
	minPanelVersion   = "3.3.0"
)

type threeXUIResponse struct {
	Success bool            `json:"success"`
	Msg     string            `json:"msg"`
	Obj     json.RawMessage   `json:"obj"`
}

type threeXUIInbound struct {
	ID       int             `json:"id"`
	Protocol string          `json:"protocol"`
	Port     int             `json:"port"`
	Enable   bool            `json:"enable"`
	Settings json.RawMessage `json:"settings"`
	Remark   string          `json:"remark"`
}

type threeXUIClientEntry struct {
	ID         string `json:"id"`
	Email      string `json:"email"`
	TotalGB    int64  `json:"totalGB"`
	ExpiryTime int64  `json:"expiryTime"`
	Enable     bool   `json:"enable"`
	SubID      string `json:"subId"`
	TgID       string `json:"tgId,omitempty"`
	LimitIP    int    `json:"limitIp"`
}

type threeXUIPanelClient struct {
	Email      string `json:"email"`
	UUID       string `json:"uuid"`
	ID         string `json:"id"`
	SubID      string `json:"subId"`
	Enable     bool   `json:"enable"`
	ExpiryTime int64  `json:"expiryTime"`
	TotalGB    int64  `json:"totalGB"`
	LimitIP    int    `json:"limitIp"`
}

type threeXUIClient struct {
	baseURL    string
	basePath   string
	http       *http.Client
	apiKey     string
	csrfToken  string
	loggedIn   bool
}

func newThreeXUIClient(settings PanelSettings) (*threeXUIClient, error) {
	baseURL, basePath, err := normalizePanelURL(settings.PanelURL)
	if err != nil {
		return nil, err
	}
	jar, err := cookiejar.New(nil)
	if err != nil {
		return nil, err
	}
	transport := &http.Transport{}
	return &threeXUIClient{
		baseURL:  baseURL,
		basePath: basePath,
		apiKey:   strings.TrimSpace(settings.APIKey),
		http: &http.Client{
			Timeout:   20 * time.Second,
			Jar:       jar,
			Transport: transport,
		},
	}, nil
}

func normalizePanelURL(raw string) (baseURL, basePath string, err error) {
	raw = strings.TrimSpace(raw)
	if raw == "" {
		return "", "", errors.New("panel URL is required")
	}
	parsed, err := url.Parse(raw)
	if err != nil || parsed.Scheme == "" || parsed.Host == "" {
		return "", "", errors.New("panel URL is not valid")
	}
	path := strings.Trim(parsed.Path, "/")
	if path != "" {
		parts := strings.Split(path, "/")
		if len(parts) > 0 && strings.EqualFold(parts[len(parts)-1], "panel") {
			parts = parts[:len(parts)-1]
		}
		basePath = strings.Join(parts, "/")
	}
	parsed.Path = ""
	parsed.RawPath = ""
	parsed.RawQuery = ""
	parsed.Fragment = ""
	return parsed.String(), basePath, nil
}

func (c *threeXUIClient) apiURL(parts ...string) string {
	segments := []string{c.basePath, "panel", "api"}
	segments = append(segments, parts...)
	path := "/" + strings.Join(nonEmpty(segments), "/")
	u, _ := url.Parse(c.baseURL)
	u.Path = path
	return u.String()
}

func (c *threeXUIClient) loginURL() string {
	segments := nonEmpty([]string{c.basePath, "login"})
	path := "/" + strings.Join(segments, "/")
	u, _ := url.Parse(c.baseURL)
	u.Path = path
	return u.String()
}

func nonEmpty(items []string) []string {
	out := make([]string, 0, len(items))
	for _, item := range items {
		item = strings.Trim(item, "/")
		if item != "" {
			out = append(out, item)
		}
	}
	return out
}

func (c *threeXUIClient) setHeaders(req *http.Request) {
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")
	req.Header.Set("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
	req.Header.Set("X-Requested-With", "XMLHttpRequest")
	if c.apiKey != "" {
		req.Header.Set("Authorization", "Bearer "+c.apiKey)
		req.Header.Set("X-API-Key", c.apiKey)
	}
}

func isHTTPNotFound(err error) bool {
	if err == nil {
		return false
	}
	return strings.Contains(err.Error(), "HTTP 404")
}

func usesIDField(protocol string) bool {
	switch strings.ToLower(strings.TrimSpace(protocol)) {
	case "trojan", "shadowsocks", "ss", "wireguard", "hysteria", "hysteria2":
		return true
	default:
		return false
	}
}

func isUnsafeHTTPMethod(method string) bool {
	switch method {
	case http.MethodPost, http.MethodPut, http.MethodPatch, http.MethodDelete:
		return true
	default:
		return false
	}
}

func (c *threeXUIClient) applyAPIHeaders(req *http.Request, method string) {
	c.setHeaders(req)
	if isUnsafeHTTPMethod(method) && c.csrfToken != "" {
		req.Header.Set("X-CSRF-Token", c.csrfToken)
	}
}

func (c *threeXUIClient) setLoginHeaders(req *http.Request, csrf string) {
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")
	req.Header.Set("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
	if csrf != "" {
		req.Header.Set("X-CSRF-Token", csrf)
	}
}

func (c *threeXUIClient) csrfTokenURL() string {
	segments := nonEmpty([]string{c.basePath, "csrf-token"})
	path := "/" + strings.Join(segments, "/")
	u, _ := url.Parse(c.baseURL)
	u.Path = path
	return u.String()
}

func (c *threeXUIClient) panelCSRFTokenURL() string {
	segments := nonEmpty([]string{c.basePath, "panel", "csrf-token"})
	path := "/" + strings.Join(segments, "/")
	u, _ := url.Parse(c.baseURL)
	u.Path = path
	return u.String()
}

func extractCSRFFromResponse(resp *http.Response, raw []byte) string {
	if token := resp.Header.Get("X-CSRF-Token"); token != "" {
		return token
	}
	if token := parseCSRFToken(string(raw)); token != "" {
		return token
	}
	var parsed threeXUIResponse
	if len(raw) > 0 && json.Unmarshal(raw, &parsed) == nil && len(parsed.Obj) > 0 {
		var token string
		if json.Unmarshal(parsed.Obj, &token) == nil && strings.TrimSpace(token) != "" {
			return strings.TrimSpace(token)
		}
	}
	return ""
}

func (c *threeXUIClient) refreshCSRF() error {
	targets := []string{c.panelCSRFTokenURL(), c.csrfTokenURL()}
	for _, target := range targets {
		req, err := http.NewRequest(http.MethodGet, target, nil)
		if err != nil {
			continue
		}
		c.setHeaders(req)
		resp, err := c.http.Do(req)
		if err != nil {
			continue
		}
		raw, _ := io.ReadAll(resp.Body)
		resp.Body.Close()
		if resp.StatusCode < 200 || resp.StatusCode >= 300 {
			continue
		}
		if token := extractCSRFFromResponse(resp, raw); token != "" {
			c.csrfToken = token
			return nil
		}
	}
	token, err := c.fetchCSRF()
	if err != nil {
		return err
	}
	c.csrfToken = token
	return nil
}

func (c *threeXUIClient) panelPageURL() string {
	segments := nonEmpty([]string{c.basePath, "panel"})
	path := "/" + strings.Join(segments, "/")
	u, _ := url.Parse(c.baseURL)
	u.Path = path
	return u.String()
}

func (c *threeXUIClient) fetchCSRF() (string, error) {
	req, err := http.NewRequest(http.MethodGet, c.csrfTokenURL(), nil)
	if err != nil {
		return "", err
	}
	c.setLoginHeaders(req, "")
	resp, err := c.http.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()
	if token := resp.Header.Get("X-CSRF-Token"); token != "" {
		return token, nil
	}
	raw, _ := io.ReadAll(resp.Body)
	if token := parseCSRFToken(string(raw)); token != "" {
		return token, nil
	}

	req, err = http.NewRequest(http.MethodGet, c.panelPageURL(), nil)
	if err != nil {
		return "", err
	}
	c.setLoginHeaders(req, "")
	resp, err = c.http.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()
	if token := resp.Header.Get("X-CSRF-Token"); token != "" {
		return token, nil
	}
	raw, _ = io.ReadAll(resp.Body)
	if token := parseCSRFToken(string(raw)); token != "" {
		return token, nil
	}
	return "", errors.New("csrf token not found")
}

func parseCSRFToken(html string) string {
	const marker = `name="csrf-token" content="`
	start := strings.Index(html, marker)
	if start < 0 {
		return ""
	}
	start += len(marker)
	end := strings.Index(html[start:], `"`)
	if end < 0 {
		return ""
	}
	return html[start : start+end]
}

func (c *threeXUIClient) doJSON(method, target string, payload any) (threeXUIResponse, int, error) {
	return c.doJSONWithRetry(method, target, payload, false)
}

func (c *threeXUIClient) doJSONWithRetry(method, target string, payload any, retried bool) (threeXUIResponse, int, error) {
	var body io.Reader
	if payload != nil {
		data, err := json.Marshal(payload)
		if err != nil {
			return threeXUIResponse{}, 0, err
		}
		body = bytes.NewReader(data)
	}
	req, err := http.NewRequest(method, target, body)
	if err != nil {
		return threeXUIResponse{}, 0, err
	}
	c.applyAPIHeaders(req, method)

	resp, err := c.http.Do(req)
	if err != nil {
		return threeXUIResponse{}, 0, err
	}
	defer resp.Body.Close()
	raw, err := io.ReadAll(resp.Body)
	if err != nil {
		return threeXUIResponse{}, resp.StatusCode, err
	}
	var parsed threeXUIResponse
	if len(raw) > 0 {
		_ = json.Unmarshal(raw, &parsed)
	}
	if resp.StatusCode == http.StatusForbidden && isUnsafeHTTPMethod(method) && !retried {
		if refreshErr := c.refreshCSRF(); refreshErr == nil {
			return c.doJSONWithRetry(method, target, payload, true)
		}
	}
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		msg := parsed.Msg
		if msg == "" {
			msg = strings.TrimSpace(string(raw))
		}
		if msg == "" {
			msg = resp.Status
		}
		if resp.StatusCode == http.StatusForbidden && c.apiKey != "" && !c.loggedIn {
			msg = msg + " (check API token in panel settings, or use username/password)"
		}
		return parsed, resp.StatusCode, fmt.Errorf("HTTP %d: %s", resp.StatusCode, msg)
	}
	return parsed, resp.StatusCode, nil
}

func (c *threeXUIClient) withRetry(action func(attempt int) error) error {
	var last error
	for attempt := 1; attempt <= maxAPIRetries; attempt++ {
		last = action(attempt)
		if last == nil {
			return nil
		}
		if attempt < maxAPIRetries {
			time.Sleep(time.Duration(attempt) * time.Second)
		}
	}
	return last
}

func (c *threeXUIClient) login(username, password string) error {
	return c.withRetry(func(attempt int) error {
		csrf, err := c.fetchCSRF()
		if err != nil {
			return fmt.Errorf("csrf fetch failed: %w", err)
		}
		payload := map[string]string{
			"username": strings.TrimSpace(username),
			"password": password,
		}
		data, err := json.Marshal(payload)
		if err != nil {
			return err
		}
		req, err := http.NewRequest(http.MethodPost, c.loginURL(), bytes.NewReader(data))
		if err != nil {
			return err
		}
		c.setLoginHeaders(req, csrf)
		resp, err := c.http.Do(req)
		if err != nil {
			return err
		}
		defer resp.Body.Close()
		raw, _ := io.ReadAll(resp.Body)
		var parsed threeXUIResponse
		if len(raw) > 0 {
			_ = json.Unmarshal(raw, &parsed)
		}
		if resp.StatusCode < 200 || resp.StatusCode >= 300 {
			msg := parsed.Msg
			if msg == "" {
				msg = strings.TrimSpace(string(raw))
			}
			if msg == "" {
				msg = resp.Status
			}
			return fmt.Errorf("HTTP %d: %s", resp.StatusCode, msg)
		}
		if !parsed.Success && parsed.Msg != "" {
			return errors.New(parsed.Msg)
		}
		c.loggedIn = true
		if err := c.refreshCSRF(); err != nil {
			return fmt.Errorf("csrf refresh after login failed: %w", err)
		}
		return nil
	})
}

func (c *threeXUIClient) listInbounds() ([]threeXUIInbound, error) {
	var inbounds []threeXUIInbound
	err := c.withRetry(func(attempt int) error {
		resp, _, err := c.doJSON(http.MethodGet, c.apiURL("inbounds", "list"), nil)
		if err != nil {
			return err
		}
		if !resp.Success {
			if resp.Msg != "" {
				return errors.New(resp.Msg)
			}
			return errors.New("inbounds list failed")
		}
		if err := json.Unmarshal(resp.Obj, &inbounds); err != nil {
			return err
		}
		return nil
	})
	return inbounds, err
}

func (c *threeXUIClient) addClient(inboundID int, protocol string, entry threeXUIClientEntry) error {
	return c.addClients([]int{inboundID}, protocol, entry)
}

func (c *threeXUIClient) addClients(inboundIDs []int, protocol string, entry threeXUIClientEntry) error {
	if len(inboundIDs) == 0 {
		return errors.New("no inbound selected")
	}
	if err := c.addClientsV3(inboundIDs, protocol, entry); err == nil {
		return nil
	} else if !isHTTPNotFound(err) {
		return err
	}
	return c.addClientLegacy(inboundIDs[0], entry)
}

func (c *threeXUIClient) addClientsV3(inboundIDs []int, protocol string, entry threeXUIClientEntry) error {
	clientMap := map[string]any{
		"email":      entry.Email,
		"subId":      entry.SubID,
		"enable":     entry.Enable,
		"expiryTime": entry.ExpiryTime,
		"totalGB":    entry.TotalGB,
		"limitIp":    entry.LimitIP,
		"flow":       "",
		"comment":    "BlackFox Config Builder",
	}
	if usesIDField(protocol) {
		clientMap["id"] = entry.ID
	} else {
		clientMap["uuid"] = entry.ID
	}
	payload := map[string]any{
		"client":     clientMap,
		"inboundIds": inboundIDs,
	}
	return c.withRetry(func(attempt int) error {
		resp, _, err := c.doJSON(http.MethodPost, c.apiURL("clients", "add"), payload)
		if err != nil {
			return err
		}
		if !resp.Success {
			if resp.Msg != "" {
				return errors.New(strings.TrimSpace(resp.Msg))
			}
			return errors.New("clients/add failed")
		}
		return nil
	})
}

func (c *threeXUIClient) addClientV3(inboundID int, protocol string, entry threeXUIClientEntry) error {
	return c.addClientsV3([]int{inboundID}, protocol, entry)
}

func (c *threeXUIClient) addClientLegacy(inboundID int, client threeXUIClientEntry) error {
	settingsMap := map[string][]threeXUIClientEntry{
		"clients": {client},
	}
	settingsJSON, err := json.Marshal(settingsMap)
	if err != nil {
		return err
	}
	payload := map[string]any{
		"id":       inboundID,
		"settings": string(settingsJSON),
	}
	return c.withRetry(func(attempt int) error {
		resp, _, err := c.doJSON(http.MethodPost, c.apiURL("inbounds", "addClient"), payload)
		if err != nil {
			return err
		}
		if !resp.Success {
			if resp.Msg != "" {
				return errors.New(strings.TrimSpace(resp.Msg))
			}
			return errors.New("add client failed")
		}
		return nil
	})
}

func (c *threeXUIClient) updateClient(inboundID int, clientID string, entry threeXUIClientEntry) error {
	settingsMap := map[string][]threeXUIClientEntry{
		"clients": {entry},
	}
	settingsJSON, err := json.Marshal(settingsMap)
	if err != nil {
		return err
	}
	payload := map[string]any{
		"id":       inboundID,
		"settings": string(settingsJSON),
	}
	return c.withRetry(func(attempt int) error {
		resp, _, err := c.doJSON(http.MethodPost, c.apiURL("inbounds", "updateClient", clientID), payload)
		if err != nil {
			return err
		}
		if !resp.Success {
			if resp.Msg != "" {
				return errors.New(strings.TrimSpace(resp.Msg))
			}
			return errors.New("update client failed")
		}
		return nil
	})
}

type threeXUIInboundSettings struct {
	Clients []threeXUIClientEntry `json:"clients"`
}

func parseInboundSettings(raw json.RawMessage) (threeXUIInboundSettings, error) {
	var settings threeXUIInboundSettings
	if len(raw) == 0 {
		return settings, errors.New("empty inbound settings")
	}
	payload := raw
	var encoded string
	if err := json.Unmarshal(raw, &encoded); err == nil && strings.TrimSpace(encoded) != "" {
		payload = json.RawMessage(encoded)
	}
	if err := json.Unmarshal(payload, &settings); err != nil && len(settings.Clients) == 0 {
		return settings, err
	}
	if len(settings.Clients) == 0 {
		return settings, errors.New("no clients in inbound settings")
	}
	return settings, nil
}

func (c *threeXUIClient) listPanelClients() ([]threeXUIPanelClient, error) {
	var clients []threeXUIPanelClient
	err := c.withRetry(func(attempt int) error {
		resp, _, err := c.doJSON(http.MethodGet, c.apiURL("clients", "list"), nil)
		if err != nil {
			return err
		}
		if !resp.Success {
			if resp.Msg != "" {
				return errors.New(resp.Msg)
			}
			return errors.New("clients list failed")
		}
		if err := json.Unmarshal(resp.Obj, &clients); err != nil {
			return err
		}
		return nil
	})
	return clients, err
}

func (c *threeXUIClient) findClientByEmail(email string) (*threeXUIClientEntry, *threeXUIInbound, error) {
	if entry, inbound, err := c.findClientByEmailV3(email); err == nil {
		return entry, inbound, nil
	}
	return c.findClientByEmailLegacy(email)
}

func (c *threeXUIClient) findClientByEmailV3(email string) (*threeXUIClientEntry, *threeXUIInbound, error) {
	clients, err := c.listPanelClients()
	if err != nil {
		return nil, nil, err
	}
	email = strings.TrimSpace(email)
	for _, row := range clients {
		if !strings.EqualFold(strings.TrimSpace(row.Email), email) {
			continue
		}
		id := strings.TrimSpace(row.UUID)
		if id == "" {
			id = strings.TrimSpace(row.ID)
		}
		entry := &threeXUIClientEntry{
			ID:         id,
			Email:      row.Email,
			TotalGB:    row.TotalGB,
			ExpiryTime: row.ExpiryTime,
			Enable:     row.Enable,
			SubID:      row.SubID,
			LimitIP:    row.LimitIP,
		}
		inbounds, err := c.listInbounds()
		if err != nil {
			return entry, nil, nil
		}
		for i := range inbounds {
			settings, err := parseInboundSettings(inbounds[i].Settings)
			if err != nil {
				continue
			}
			for j := range settings.Clients {
				if strings.EqualFold(strings.TrimSpace(settings.Clients[j].Email), email) {
					return entry, &inbounds[i], nil
				}
			}
		}
		if len(inbounds) > 0 {
			return entry, &inbounds[0], nil
		}
		return entry, nil, nil
	}
	return nil, nil, fmt.Errorf("client %q not found", email)
}

func (c *threeXUIClient) findClientByEmailLegacy(email string) (*threeXUIClientEntry, *threeXUIInbound, error) {
	inbounds, err := c.listInbounds()
	if err != nil {
		return nil, nil, err
	}
	email = strings.TrimSpace(email)
	for i := range inbounds {
		settings, err := parseInboundSettings(inbounds[i].Settings)
		if err != nil {
			continue
		}
		for j := range settings.Clients {
			if strings.EqualFold(strings.TrimSpace(settings.Clients[j].Email), email) {
				return &settings.Clients[j], &inbounds[i], nil
			}
		}
	}
	return nil, nil, fmt.Errorf("client %q not found", email)
}

func (c *threeXUIClient) getClientLinks(inboundID int, email string) ([]string, error) {
	links, err := c.getClientLinksV3(email)
	if err == nil && len(links) > 0 {
		return links, nil
	}
	if err != nil && !isHTTPNotFound(err) {
		return nil, err
	}
	return c.getClientLinksLegacy(inboundID, email)
}

func (c *threeXUIClient) getClientLinksV3(email string) ([]string, error) {
	target := c.apiURL("clients", "links", url.PathEscape(strings.TrimSpace(email)))
	resp, _, err := c.doJSON(http.MethodGet, target, nil)
	if err != nil {
		return nil, err
	}
	if !resp.Success {
		if resp.Msg != "" {
			return nil, errors.New(resp.Msg)
		}
		return nil, errors.New("clients/links failed")
	}
	var links []string
	if err := json.Unmarshal(resp.Obj, &links); err != nil {
		return nil, err
	}
	return links, nil
}

func (c *threeXUIClient) getClientLinksLegacy(inboundID int, email string) ([]string, error) {
	target := c.apiURL("inbounds", "getClientLinks", strconv.Itoa(inboundID), url.PathEscape(email))
	resp, _, err := c.doJSON(http.MethodGet, target, nil)
	if err != nil {
		return nil, err
	}
	if !resp.Success {
		if resp.Msg != "" {
			return nil, errors.New(resp.Msg)
		}
		return nil, errors.New("getClientLinks failed")
	}
	var links []string
	if err := json.Unmarshal(resp.Obj, &links); err != nil {
		return nil, err
	}
	return links, nil
}

func (c *threeXUIClient) getSubLinks(subID string) ([]string, error) {
	links, err := c.getSubLinksV3(subID)
	if err == nil && len(links) > 0 {
		return links, nil
	}
	if err != nil && !isHTTPNotFound(err) {
		return nil, err
	}
	return c.getSubLinksLegacy(subID)
}

func (c *threeXUIClient) getSubLinksV3(subID string) ([]string, error) {
	target := c.apiURL("clients", "subLinks", url.PathEscape(subID))
	resp, _, err := c.doJSON(http.MethodGet, target, nil)
	if err != nil {
		return nil, err
	}
	if !resp.Success {
		if resp.Msg != "" {
			return nil, errors.New(resp.Msg)
		}
		return nil, errors.New("clients/subLinks failed")
	}
	var links []string
	if err := json.Unmarshal(resp.Obj, &links); err != nil {
		return nil, err
	}
	return links, nil
}

func (c *threeXUIClient) getSubLinksLegacy(subID string) ([]string, error) {
	target := c.apiURL("inbounds", "getSubLinks", url.PathEscape(subID))
	resp, _, err := c.doJSON(http.MethodGet, target, nil)
	if err != nil {
		return nil, err
	}
	if !resp.Success {
		if resp.Msg != "" {
			return nil, errors.New(resp.Msg)
		}
		return nil, errors.New("getSubLinks failed")
	}
	var links []string
	if err := json.Unmarshal(resp.Obj, &links); err != nil {
		return nil, err
	}
	return links, nil
}

func buildSubURL(client *threeXUIClient, subID string) string {
	link := fmt.Sprintf("%s/sub/%s", strings.TrimRight(client.baseURL, "/"), subID)
	if client.basePath != "" {
		link = fmt.Sprintf("%s/%s/sub/%s", strings.TrimRight(client.baseURL, "/"), client.basePath, subID)
	}
	return link
}

func generateClientCredential(protocol string) string {
	switch strings.ToLower(strings.TrimSpace(protocol)) {
	case "trojan":
		return randomPassword(16)
	case "shadowsocks", "ss":
		return randomPassword(12)
	case "hysteria", "hysteria2":
		return randomPassword(12)
	default:
		return uuid.NewString()
	}
}

func randomPassword(length int) string {
	buf := make([]byte, length/2+1)
	_, _ = rand.Read(buf)
	return hex.EncodeToString(buf)[:length]
}

type threeXUIAllSettings struct {
	SubEnable   bool   `json:"subEnable"`
	SubURI      string `json:"subURI"`
	SubPath     string `json:"subPath"`
	SubPort     int    `json:"subPort"`
	SubDomain   string `json:"subDomain"`
	SubCertFile string `json:"subCertFile"`
	SubKeyFile  string `json:"subKeyFile"`
}

type cachedPanelSession struct {
	key      string
	client   *threeXUIClient
	settings *threeXUIAllSettings
	inbounds []threeXUIInbound
	loaded   time.Time
}

var panelSessionCache struct {
	mu sync.Mutex
	cachedPanelSession
}

var panelSessionPersistent bool

const panelSessionTTL = 2 * time.Minute

func invalidatePanelSessionCache() {
	panelSessionCache.mu.Lock()
	panelSessionCache.client = nil
	panelSessionCache.settings = nil
	panelSessionCache.inbounds = nil
	panelSessionCache.key = ""
	panelSessionPersistent = false
	panelSessionCache.mu.Unlock()
}

func panelSessionActive(key string) bool {
	panelSessionCache.mu.Lock()
	defer panelSessionCache.mu.Unlock()
	if panelSessionCache.client == nil || panelSessionCache.key != key {
		return false
	}
	if panelSessionPersistent {
		return true
	}
	return time.Since(panelSessionCache.loaded) < panelSessionTTL
}

func isPanelConnected() bool {
	panelSessionCache.mu.Lock()
	defer panelSessionCache.mu.Unlock()
	return panelSessionPersistent && panelSessionCache.client != nil
}

func connectPanelSession(settings PanelSettings) error {
	client, err := connectAndVerify(settings)
	if err != nil {
		invalidatePanelSessionCache()
		return err
	}
	panelSettings, err := client.getAllSettings()
	if err != nil {
		panelSettings = defaultPanelSubSettings()
	}
	applyStoredSubscriptionSettings(settings, panelSettings)

	key := sessionKey(settings)
	panelSessionCache.mu.Lock()
	panelSessionCache.key = key
	panelSessionCache.client = client
	panelSessionCache.settings = panelSettings
	panelSessionCache.inbounds, _ = client.listInbounds()
	panelSessionCache.loaded = time.Now()
	panelSessionPersistent = true
	panelSessionCache.mu.Unlock()
	return nil
}

func getPanelInbounds(client *threeXUIClient) ([]threeXUIInbound, error) {
	panelSessionCache.mu.Lock()
	if panelSessionCache.client == client && len(panelSessionCache.inbounds) > 0 {
		inbounds := append([]threeXUIInbound(nil), panelSessionCache.inbounds...)
		panelSessionCache.mu.Unlock()
		return inbounds, nil
	}
	panelSessionCache.mu.Unlock()

	inbounds, err := client.listInbounds()
	if err != nil {
		return nil, err
	}
	panelSessionCache.mu.Lock()
	if panelSessionCache.client == client {
		panelSessionCache.inbounds = inbounds
	}
	panelSessionCache.mu.Unlock()
	return inbounds, nil
}

func applyConfigDisplayName(link, displayName string) string {
	link = strings.TrimSpace(link)
	displayName = strings.TrimSpace(displayName)
	if link == "" || displayName == "" {
		return link
	}
	parsed, err := url.Parse(link)
	if err != nil {
		if idx := strings.LastIndex(link, "#"); idx >= 0 {
			return link[:idx+1] + displayName
		}
		return link + "#" + displayName
	}
	parsed.Fragment = displayName
	return parsed.String()
}

func sessionKey(settings PanelSettings) string {
	return strings.TrimSpace(settings.PanelURL) + "|" + strings.TrimSpace(settings.APIKey) + "|" + strings.TrimSpace(settings.SubURI)
}

func getCachedPanelClient(settings PanelSettings) (*threeXUIClient, *threeXUIAllSettings, error) {
	key := sessionKey(settings)
	if panelSessionActive(key) {
		panelSessionCache.mu.Lock()
		client := panelSessionCache.client
		panelSettings := panelSessionCache.settings
		panelSessionCache.mu.Unlock()
		return client, panelSettings, nil
	}

	client, err := connectAndVerify(settings)
	if err != nil {
		invalidatePanelSessionCache()
		return nil, nil, err
	}
	panelSettings, err := client.getAllSettings()
	if err != nil {
		panelSettings = defaultPanelSubSettings()
	}
	applyStoredSubscriptionSettings(settings, panelSettings)

	panelSessionCache.mu.Lock()
	panelSessionCache.key = key
	panelSessionCache.client = client
	panelSessionCache.settings = panelSettings
	panelSessionCache.loaded = time.Now()
	panelSessionCache.mu.Unlock()
	return client, panelSettings, nil
}

func defaultPanelSubSettings() *threeXUIAllSettings {
	return &threeXUIAllSettings{SubPath: "/sub/", SubPort: 2096}
}

func applyStoredSubscriptionSettings(stored PanelSettings, panel *threeXUIAllSettings) {
	if panel == nil {
		return
	}
	if uri := normalizeSubURIBase(stored.SubURI); uri != "" {
		panel.SubURI = uri
	}
}

func (c *threeXUIClient) getAllSettings() (*threeXUIAllSettings, error) {
	targets := []string{
		c.apiURL("setting", "all"),
	}
	if c.basePath != "" {
		targets = append(targets, strings.TrimRight(c.baseURL, "/")+"/"+c.basePath+"/panel/setting/all")
	}
	methods := []string{http.MethodGet, http.MethodPost}
	var lastErr error
	for _, target := range targets {
		for _, method := range methods {
			var payload any
			if method == http.MethodPost {
				payload = map[string]any{}
			}
			resp, _, err := c.doJSON(method, target, payload)
			if err != nil {
				lastErr = err
				continue
			}
			if !resp.Success {
				if resp.Msg != "" {
					lastErr = errors.New(resp.Msg)
				} else {
					lastErr = errors.New("get settings failed")
				}
				continue
			}
			var settings threeXUIAllSettings
			if err := json.Unmarshal(resp.Obj, &settings); err != nil {
				lastErr = err
				continue
			}
			return &settings, nil
		}
	}
	return nil, lastErr
}

func (c *threeXUIClient) subscriptionHost(panel *threeXUIAllSettings) string {
	if panel != nil && strings.TrimSpace(panel.SubDomain) != "" {
		return strings.TrimSpace(panel.SubDomain)
	}
	if parsed, err := url.Parse(c.baseURL); err == nil {
		return parsed.Hostname()
	}
	return ""
}

func subscriptionSchemes(panel *threeXUIAllSettings) []string {
	if panel != nil {
		if uri := strings.TrimSpace(panel.SubURI); uri != "" {
			if parsed, err := url.Parse(uri); err == nil && parsed.Scheme != "" {
				return []string{parsed.Scheme}
			}
		}
		if strings.TrimSpace(panel.SubCertFile) != "" || strings.TrimSpace(panel.SubKeyFile) != "" {
			return []string{"https"}
		}
	}
	return []string{"https", "http"}
}

func subscriptionDefaultScheme(panel *threeXUIAllSettings, baseURL string) string {
	for _, scheme := range subscriptionSchemes(panel) {
		return scheme
	}
	if parsed, err := url.Parse(baseURL); err == nil && parsed.Scheme != "" {
		return parsed.Scheme
	}
	return "https"
}

func (c *threeXUIClient) subscriptionURLCandidates(panel *threeXUIAllSettings, subID string) []string {
	subID = strings.TrimSpace(subID)
	if subID == "" {
		return nil
	}
	seen := map[string]struct{}{}
	var candidates []string
	add := func(v string) {
		v = strings.TrimSpace(v)
		if v == "" {
			return
		}
		if _, ok := seen[v]; ok {
			return
		}
		seen[v] = struct{}{}
		candidates = append(candidates, v)
	}

	if panel != nil {
		if uri := strings.TrimSpace(panel.SubURI); uri != "" {
			add(joinURLPath(uri, subID))
		}
	}

	host := c.subscriptionHost(panel)
	if host == "" {
		return candidates
	}

	port := 2096
	if panel != nil && panel.SubPort > 0 {
		port = panel.SubPort
	}
	subPath := "/sub/"
	if panel != nil && strings.TrimSpace(panel.SubPath) != "" {
		subPath = strings.TrimSpace(panel.SubPath)
	}
	if !strings.HasPrefix(subPath, "/") {
		subPath = "/" + subPath
	}
	subPath = strings.TrimRight(subPath, "/")

	pathVariants := []string{subPath}
	if c.basePath != "" {
		pathVariants = append(pathVariants, "/"+c.basePath+subPath)
	}

	for _, scheme := range subscriptionSchemes(panel) {
		hostPort := net.JoinHostPort(host, strconv.Itoa(port))
		for _, path := range pathVariants {
			add(fmt.Sprintf("%s://%s%s/%s", scheme, hostPort, path, subID))
			add(fmt.Sprintf("%s://%s%s/%s", scheme, host, path, subID))
		}
	}
	return candidates
}

func isValidSubscriptionURL(client *http.Client, subURL string) bool {
	req, err := http.NewRequest(http.MethodGet, subURL, nil)
	if err != nil {
		return false
	}
	req.Header.Set("User-Agent", "BlackFoxConfigBuilder/1.0")
	resp, err := client.Do(req)
	if err != nil {
		return false
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return false
	}
	body, err := io.ReadAll(io.LimitReader(resp.Body, 4096))
	if err != nil {
		return false
	}
	text := strings.TrimSpace(string(body))
	if text == "" || strings.EqualFold(text, "Error!") {
		return false
	}
	if strings.HasPrefix(text, "<") {
		return false
	}
	return true
}

func (c *threeXUIClient) resolveSubscriptionURL(panel *threeXUIAllSettings, subID string) string {
	candidates := c.subscriptionURLCandidates(panel, subID)
	transport := &http.Transport{}
	probe := &http.Client{Timeout: 8 * time.Second, Transport: transport}

	for _, candidate := range candidates {
		if isValidSubscriptionURL(probe, candidate) {
			return candidate
		}
	}
	return buildPanelSubURL(c, panel, subID)
}

func normalizeSubURIBase(raw string) string {
	raw = strings.TrimSpace(raw)
	if raw == "" {
		return ""
	}
	parsed, err := url.Parse(raw)
	if err != nil || parsed.Scheme == "" || parsed.Host == "" {
		return strings.TrimRight(raw, "/") + "/"
	}
	segments := strings.Split(strings.Trim(parsed.Path, "/"), "/")
	if len(segments) > 0 && looksLikeSubID(segments[len(segments)-1]) {
		segments = segments[:len(segments)-1]
	}
	if len(segments) > 0 {
		parsed.Path = "/" + strings.Join(segments, "/")
	} else {
		parsed.Path = "/"
	}
	parsed.RawQuery = ""
	parsed.Fragment = ""
	out := strings.TrimRight(parsed.String(), "/")
	if out == parsed.Scheme+"://"+parsed.Host {
		return out + "/"
	}
	return out + "/"
}

func looksLikeSubID(value string) bool {
	value = strings.TrimSpace(value)
	if len(value) < 6 || len(value) > 16 {
		return false
	}
	for _, r := range value {
		if (r >= 'a' && r <= 'z') || (r >= '0' && r <= '9') {
			continue
		}
		return false
	}
	return true
}

func joinURLPath(base, subID string) string {
	base = strings.TrimSpace(base)
	subID = strings.TrimSpace(subID)
	if base == "" || subID == "" {
		return ""
	}
	if strings.HasSuffix(base, "/") {
		return base + subID
	}
	return base + "/" + subID
}

func buildPanelSubURL(client *threeXUIClient, panel *threeXUIAllSettings, subID string) string {
	subID = strings.TrimSpace(subID)
	if subID == "" {
		return ""
	}
	if panel != nil {
		if uri := strings.TrimSpace(panel.SubURI); uri != "" {
			return joinURLPath(uri, subID)
		}
	}

	scheme := subscriptionDefaultScheme(panel, client.baseURL)
	host := client.subscriptionHost(panel)
	if host == "" {
		return ""
	}

	port := 2096
	if panel != nil && panel.SubPort > 0 {
		port = panel.SubPort
	}
	subPath := "/sub/"
	if panel != nil && strings.TrimSpace(panel.SubPath) != "" {
		subPath = strings.TrimSpace(panel.SubPath)
	}
	if !strings.HasPrefix(subPath, "/") {
		subPath = "/" + subPath
	}
	subPath = strings.TrimRight(subPath, "/")

	hostPort := net.JoinHostPort(host, strconv.Itoa(port))
	return fmt.Sprintf("%s://%s%s/%s", scheme, hostPort, subPath, subID)
}

func previewInbound(settings PanelSettings, port int) (*threeXUIInbound, string, error) {
	client, _, err := getCachedPanelClient(settings)
	if err != nil {
		return nil, "", err
	}
	inbounds, err := client.listInbounds()
	if err != nil {
		return nil, "", err
	}
	inbound := pickInbound(inbounds, port)
	if inbound == nil {
		return nil, "", fmt.Errorf("inbound not found")
	}
	return inbound, inbound.Protocol, nil
}

func enrichClientResult(client *threeXUIClient, panel *threeXUIAllSettings, inbound *threeXUIInbound, entry threeXUIClientEntry, req createClientRequest, result *createClientResult) {
	subURL := client.resolveSubscriptionURL(panel, entry.SubID)
	result.Link = subURL
	result.Record.Link = subURL

	if links, err := client.getClientLinks(inbound.ID, req.Name); err == nil && len(links) > 0 {
		result.Record.ConfigLink = applyConfigDisplayName(links[0], req.Name)
	}
	result.Record.ID = entry.ID
	result.Record.InboundPort = inbound.Port
}

func buildClientResult(client *threeXUIClient, panel *threeXUIAllSettings, inbound *threeXUIInbound, entry threeXUIClientEntry, req createClientRequest) createClientResult {
	subURL := buildPanelSubURL(client, panel, entry.SubID)
	var daysPtr *int
	if req.ExpirationDays > 0 {
		days := req.ExpirationDays
		daysPtr = &days
	}
	var trafficPtr *float64
	if req.TrafficLimitGB > 0 {
		traffic := req.TrafficLimitGB
		trafficPtr = &traffic
	}
	id := entry.ID
	if id == "" {
		id = entry.Email
	}
	result := createClientResult{
		Record: ConfigRecord{
			ID:             id,
			Name:           req.Name,
			Link:           subURL,
			Status:         "Active",
			TrafficLimitGB: trafficPtr,
			ExpirationDays: daysPtr,
			CreatedAtUTC:   time.Now().UTC(),
		},
		Link:      subURL,
		InboundID: inbound.ID,
	}
	enrichClientResult(client, panel, inbound, entry, req, &result)
	return result
}

func randomSubID() string {
	const chars = "abcdefghijklmnopqrstuvwxyz0123456789"
	buf := make([]byte, 8)
	_, _ = rand.Read(buf)
	out := make([]byte, 8)
	for i, b := range buf {
		out[i] = chars[int(b)%len(chars)]
	}
	return string(out)
}

func gbToBytes(gb float64) int64 {
	return int64(gb * 1024 * 1024 * 1024)
}

func trafficLimitBytes(gb float64) int64 {
	if gb <= 0 {
		return 0
	}
	return gbToBytes(gb)
}

func expiryTimeMillis(days int) int64 {
	if days <= 0 {
		return 0
	}
	return time.Now().Add(time.Duration(days) * 24 * time.Hour).UnixMilli()
}

func findInboundByID(inbounds []threeXUIInbound, id int) *threeXUIInbound {
	for i := range inbounds {
		if inbounds[i].ID == id {
			return &inbounds[i]
		}
	}
	return nil
}

func resolveInbounds(inbounds []threeXUIInbound, ids []int, port int) ([]*threeXUIInbound, error) {
	if len(ids) > 0 {
		out := make([]*threeXUIInbound, 0, len(ids))
		for _, id := range ids {
			inbound := findInboundByID(inbounds, id)
			if inbound == nil {
				return nil, fmt.Errorf("inbound %d not found", id)
			}
			if !inbound.Enable {
				return nil, fmt.Errorf("inbound %d is disabled", id)
			}
			out = append(out, inbound)
		}
		return out, nil
	}
	inbound := pickInbound(inbounds, port)
	if inbound == nil {
		if port > 0 {
			return nil, fmt.Errorf("no enabled inbound on port %d", port)
		}
		return nil, errors.New("no enabled inbound available")
	}
	return []*threeXUIInbound{inbound}, nil
}

func connectAndVerify(settings PanelSettings) (*threeXUIClient, error) {
	client, err := newThreeXUIClient(settings)
	if err != nil {
		return nil, err
	}

	hasAPIKey := client.apiKey != ""
	hasCreds := strings.TrimSpace(settings.Username) != "" && settings.Password != ""

	if hasAPIKey {
		// Bearer token auth — no session login required.
	} else if hasCreds {
		if err := client.login(settings.Username, settings.Password); err != nil {
			return nil, fmt.Errorf("login failed: %w", err)
		}
	} else {
		return nil, errors.New("username/password or API token required")
	}

	inbounds, err := client.listInbounds()
	if err != nil {
		if hasAPIKey {
			return nil, fmt.Errorf("api token auth failed: %w", err)
		}
		return nil, fmt.Errorf("inbounds check failed: %w", err)
	}
	if len(inbounds) == 0 {
		return nil, errors.New("no inbounds found on panel")
	}

	if version, verr := client.getPanelVersion(); verr == nil && version != "" {
		if compareSemver(version, minPanelVersion) < 0 {
			return nil, fmt.Errorf(
				"panel version %s is not supported (minimum %s required)",
				version,
				minPanelVersion,
			)
		}
	}

	return client, nil
}

func (c *threeXUIClient) getPanelVersion() (string, error) {
	targets := []string{
		c.apiURL("server", "status"),
		c.apiURL("server"),
	}
	for _, target := range targets {
		resp, _, err := c.doJSON(http.MethodGet, target, nil)
		if err != nil {
			continue
		}
		if !resp.Success {
			continue
		}
		var direct struct {
			Version string `json:"version"`
		}
		if err := json.Unmarshal(resp.Obj, &direct); err == nil {
			if v := strings.TrimSpace(direct.Version); v != "" {
				return v, nil
			}
		}
		var nested struct {
			Version string `json:"version"`
		}
		var wrapper map[string]json.RawMessage
		if err := json.Unmarshal(resp.Obj, &wrapper); err == nil {
			for _, key := range []string{"version", "panelVersion", "appVersion"} {
				if raw, ok := wrapper[key]; ok {
					var version string
					if err := json.Unmarshal(raw, &version); err == nil {
						if v := strings.TrimSpace(version); v != "" {
							return v, nil
						}
					}
				}
			}
			if raw, ok := wrapper["status"]; ok {
				if err := json.Unmarshal(raw, &nested); err == nil {
					if v := strings.TrimSpace(nested.Version); v != "" {
						return v, nil
					}
				}
			}
		}
	}
	return "", errors.New("panel version unavailable")
}

func compareSemver(a, b string) int {
	parse := func(v string) [3]int {
		var parts [3]int
		v = strings.TrimSpace(strings.TrimPrefix(strings.ToLower(v), "v"))
		if idx := strings.IndexAny(v, "-+"); idx >= 0 {
			v = v[:idx]
		}
		segments := strings.Split(v, ".")
		for i := 0; i < len(segments) && i < 3; i++ {
			n, _ := strconv.Atoi(strings.TrimSpace(segments[i]))
			parts[i] = n
		}
		return parts
	}
	av := parse(a)
	bv := parse(b)
	for i := 0; i < 3; i++ {
		if av[i] < bv[i] {
			return -1
		}
		if av[i] > bv[i] {
			return 1
		}
	}
	return 0
}

func test3XUI(settings PanelSettings) error {
	_, err := connectAndVerify(settings)
	return err
}

func createClientOnPanel(settings PanelSettings, req createClientRequest) (createClientResult, error) {
	var result createClientResult
	client, panelSettings, err := getCachedPanelClient(settings)
	if err != nil {
		return result, err
	}
	inbounds, err := getPanelInbounds(client)
	if err != nil {
		return result, err
	}
	inboundList, err := resolveInbounds(inbounds, req.InboundIDs, req.InboundPort)
	if err != nil {
		return result, err
	}
	primary := inboundList[0]
	inboundIDs := make([]int, len(inboundList))
	for i, inbound := range inboundList {
		inboundIDs[i] = inbound.ID
	}

	clientID := strings.TrimSpace(req.ClientID)
	if clientID == "" {
		clientID = generateClientCredential(primary.Protocol)
	}
	entry := threeXUIClientEntry{
		ID:         clientID,
		Email:      req.Name,
		TotalGB:    trafficLimitBytes(req.TrafficLimitGB),
		ExpiryTime: expiryTimeMillis(req.ExpirationDays),
		Enable:     true,
		SubID:      randomSubID(),
		LimitIP:    0,
	}
	if err := client.addClients(inboundIDs, primary.Protocol, entry); err != nil {
		if strings.Contains(strings.ToLower(err.Error()), "duplicate") ||
			strings.Contains(strings.ToLower(err.Error()), "exist") {
			if delErr := client.deleteClientByEmail(primary.ID, req.Name); delErr == nil {
				if retryErr := client.addClients(inboundIDs, primary.Protocol, entry); retryErr == nil {
					result = buildClientResult(client, panelSettings, primary, entry, req)
					return result, nil
				}
			}
			existing, existingInbound, findErr := client.findClientByEmail(req.Name)
			if findErr != nil {
				return result, fmt.Errorf("create client failed: %w", err)
			}
			updated := *existing
			updated.TotalGB = trafficLimitBytes(req.TrafficLimitGB)
			updated.ExpiryTime = expiryTimeMillis(req.ExpirationDays)
			updated.Enable = true
			if updateErr := client.updateClient(existingInbound.ID, updated.ID, updated); updateErr != nil {
				return result, fmt.Errorf("existing client found but update failed: %w", updateErr)
			}
			result = buildClientResult(client, panelSettings, existingInbound, updated, req)
			return result, nil
		}
		return result, fmt.Errorf("create client failed: %w", err)
	}

	result = buildClientResult(client, panelSettings, primary, entry, req)
	return result, nil
}

func (c *threeXUIClient) deleteClientByEmail(inboundID int, email string) error {
	email = strings.TrimSpace(email)
	if email == "" {
		return errors.New("client email is required")
	}
	if err := c.deleteClientV3(email); err == nil {
		return nil
	} else if !isHTTPNotFound(err) {
		return err
	}
	return c.deleteClientLegacy(inboundID, email)
}

func (c *threeXUIClient) deleteClientV3(email string) error {
	target := c.apiURL("clients", "del", url.PathEscape(strings.TrimSpace(email)))
	return c.withRetry(func(attempt int) error {
		resp, _, err := c.doJSON(http.MethodPost, target, map[string]any{})
		if err != nil {
			return err
		}
		if !resp.Success {
			if resp.Msg != "" {
				return errors.New(strings.TrimSpace(resp.Msg))
			}
			return errors.New("delete client failed")
		}
		return nil
	})
}

func (c *threeXUIClient) deleteClientLegacy(inboundID int, email string) error {
	target := c.apiURL("inbounds", strconv.Itoa(inboundID), "delClientByEmail", url.PathEscape(email))
	return c.withRetry(func(attempt int) error {
		resp, _, err := c.doJSON(http.MethodPost, target, map[string]any{})
		if err != nil {
			return err
		}
		if !resp.Success {
			if resp.Msg != "" {
				return errors.New(strings.TrimSpace(resp.Msg))
			}
			return errors.New("delete client failed")
		}
		return nil
	})
}

func deleteClientOnPanel(settings PanelSettings, email string, inboundPort int) error {
	if !isPanelConnected() {
		return errors.New("panel is not connected — connect first")
	}
	client, _, err := getCachedPanelClient(settings)
	if err != nil {
		return err
	}
	email = strings.TrimSpace(email)
	_, inbound, err := client.findClientByEmail(email)
	if err != nil {
		return err
	}
	if inboundPort > 0 && inbound.Port != inboundPort {
		return fmt.Errorf("client %q is on port %d, not %d", email, inbound.Port, inboundPort)
	}
	if err := client.deleteClientByEmail(inbound.ID, email); err != nil {
		return err
	}
	panelSessionCache.mu.Lock()
	panelSessionCache.inbounds = nil
	panelSessionCache.mu.Unlock()
	return nil
}

func pickInbound(inbounds []threeXUIInbound, port int) *threeXUIInbound {
	if port > 0 {
		for i := range inbounds {
			if inbounds[i].Enable && inbounds[i].Port == port {
				return &inbounds[i]
			}
		}
		return nil
	}
	for i := range inbounds {
		if inbounds[i].Enable {
			return &inbounds[i]
		}
	}
	if len(inbounds) > 0 {
		return &inbounds[0]
	}
	return nil
}
