package notifications

import (
	"context"
	"encoding/json"
	"time"

	"github.com/google/uuid"

	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/ws"
)

// Store is the subset of notifications storage the dispatcher needs.
type Store interface {
	Insert(ctx context.Context, n Notification) error
}

// Dispatcher emits notifications on the WS events channel and persists them.
type Dispatcher struct {
	hub   *ws.Hub
	store Store
}

func NewDispatcher(hub *ws.Hub, store Store) *Dispatcher {
	return &Dispatcher{hub: hub, store: store}
}

// Dispatch persists + publishes in one step. ctx may be context.Background().
func (d *Dispatcher) Dispatch(ctx context.Context, category Category, title, body, deepLink string, actions []Action) {
	n := Notification{
		ID:         uuid.NewString(),
		Category:   category,
		Title:      title,
		Body:       body,
		Importance: importanceFor(category),
		Actions:    actions,
		DeepLink:   deepLink,
		CreatedAt:  time.Now(),
	}
	_ = d.store.Insert(ctx, n)
	raw, _ := json.Marshal(n)
	d.hub.PublishPayload("events", "events.notification", json.RawMessage(raw))
}

func importanceFor(c Category) string {
	switch c {
	case CategoryAIPermission, CategoryServerError:
		return "high"
	case CategoryBackup:
		return "low"
	default:
		return "normal"
	}
}
