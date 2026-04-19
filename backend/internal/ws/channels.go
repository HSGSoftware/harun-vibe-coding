package ws

import (
	"encoding/json"
	"sync"
)

// InboundHandler handles a single client -> server message for a given `type` prefix.
type InboundHandler func(client *Client, payload json.RawMessage)

var (
	handlerMu sync.RWMutex
	handlers  = map[string]InboundHandler{}
)

// RegisterInbound installs a handler for a specific inbound message type
// (e.g. "chat.input", "terminal.attach"). Subsequent registrations overwrite.
func RegisterInbound(msgType string, h InboundHandler) {
	handlerMu.Lock()
	handlers[msgType] = h
	handlerMu.Unlock()
}

// dispatchInbound is called from the client read pump for any non-control type.
func (h *Hub) dispatchInbound(c *Client, msgType string, payload json.RawMessage) {
	handlerMu.RLock()
	handler, ok := handlers[msgType]
	handlerMu.RUnlock()
	if !ok {
		h.log.Debug().Str("type", msgType).Msg("no inbound handler")
		return
	}
	handler(c, payload)
}
