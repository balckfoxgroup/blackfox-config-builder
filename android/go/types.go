package mobile

import "time"

// PanelSettings holds 3X-UI panel connection credentials.
type PanelSettings struct {
	PanelURL string `json:"panelUrl"`
	Username string `json:"username"`
	Password string `json:"password"`
	APIKey   string `json:"apiKey"`
	SubURI   string `json:"subUri,omitempty"`
}

// ConfigRecord is a locally stored VPN config entry.
type ConfigRecord struct {
	ID             string    `json:"id"`
	Name           string    `json:"name"`
	Link           string    `json:"link"`
	ConfigLink     string    `json:"configLink,omitempty"`
	InboundPort    int       `json:"inboundPort,omitempty"`
	Status         string    `json:"status"`
	TrafficLimitGB *float64  `json:"trafficLimitGb,omitempty"`
	UsedTrafficGB  float64   `json:"usedTrafficGb"`
	ExpirationDays *int      `json:"expirationDays,omitempty"`
	CreatedAtUTC   time.Time `json:"createdAtUtc"`
}

type createClientRequest struct {
	Name           string  `json:"name"`
	TrafficLimitGB float64 `json:"trafficLimitGb"`
	ExpirationDays int     `json:"expirationDays"`
	InboundPort    int     `json:"inboundPort"`
	InboundIDs     []int   `json:"inboundIds,omitempty"`
	ClientID       string  `json:"clientId,omitempty"`
}

type inboundSummary struct {
	ID       int    `json:"id"`
	Protocol string `json:"protocol"`
	Remark   string `json:"remark"`
	Port     int    `json:"port"`
	Enable   bool   `json:"enable"`
}

type createClientResult struct {
	Record    ConfigRecord `json:"record"`
	Link      string       `json:"link"`
	InboundID int          `json:"inboundId"`
}
