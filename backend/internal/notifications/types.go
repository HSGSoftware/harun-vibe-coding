// Package notifications builds server-side notifications and pushes them on the
// WebSocket events channel. Flutter's NotificationBridge converts them to
// Android notifications through ServerLifecycleService. See plan.md §13.
package notifications

import "time"

// Category is one of the seven hvc_* Android notification channels.
type Category string

const (
	CategoryAIResponse   Category = "ai_response"
	CategoryAIPermission Category = "ai_permission"
	CategoryServerError  Category = "server_error"
	CategoryTunnel       Category = "tunnel"
	CategoryBackup       Category = "backup"
	CategorySystem       Category = "system"
)

// Action is a bubble action (label + id) on a notification.
type Action struct {
	ID    string `json:"id"`
	Label string `json:"label"`
}

// Notification is the published shape (server -> WS events.notification).
type Notification struct {
	ID        string    `json:"id"`
	Category  Category  `json:"category"`
	Title     string    `json:"title"`
	Body      string    `json:"body"`
	Importance string   `json:"importance"`
	Actions   []Action  `json:"actions,omitempty"`
	DeepLink  string    `json:"deep_link,omitempty"`
	CreatedAt time.Time `json:"created_at"`
	Read      bool      `json:"read"`
}
