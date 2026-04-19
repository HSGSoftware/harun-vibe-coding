// Package ws owns the WebSocket hub, clients, channel routing, and per-channel handlers.
// The wire format is documented in plan.md §6: {channel, type, id, timestamp, payload}
// with snake_case payload keys and required id for resume-on-reconnect.
package ws

import (
	"encoding/json"
	"time"

	"github.com/google/uuid"
)

// Channel names.
const (
	ChanChat     = "chat"
	ChanTerminal = "terminal"
	ChanEvents   = "events"
	ChanFS       = "fs"
	ChanAIEvents = "ai_events"
)

// Envelope is the on-wire message envelope used in both directions.
type Envelope struct {
	Channel   string          `json:"channel"`
	Type      string          `json:"type"`
	ID        string          `json:"id"`
	Timestamp int64           `json:"timestamp"`
	Payload   json.RawMessage `json:"payload"`
}

// NewEnvelope builds an outbound envelope with a fresh id and current timestamp.
func NewEnvelope(channel, typ string, payload any) (Envelope, error) {
	raw, err := json.Marshal(payload)
	if err != nil {
		return Envelope{}, err
	}
	return Envelope{
		Channel:   channel,
		Type:      typ,
		ID:        uuid.NewString(),
		Timestamp: time.Now().UnixMilli(),
		Payload:   raw,
	}, nil
}
