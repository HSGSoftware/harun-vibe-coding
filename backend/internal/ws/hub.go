package ws

import (
	"context"
	"net/http"
	"sync"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
	"github.com/rs/zerolog"
)

// upgrader is shared across connections. CheckOrigin accepts all origins because
// the server is expected to run on localhost/LAN only; the caller enforces CORS
// upstream via the server.CORS middleware and the optional AuthGuard.
var upgrader = websocket.Upgrader{
	ReadBufferSize:  4096,
	WriteBufferSize: 4096,
	CheckOrigin:     func(r *http.Request) bool { return true },
}

// Hub tracks active clients and broadcasts channel messages.
type Hub struct {
	log        zerolog.Logger
	mu         sync.RWMutex
	clients    map[*Client]struct{}
	register   chan *Client
	unregister chan *Client
	broadcast  chan broadcastMsg
	cache      *messageCache
}

type broadcastMsg struct {
	channel string
	env     Envelope
}

// NewHub returns a hub ready to Run.
func NewHub(log zerolog.Logger) *Hub {
	return &Hub{
		log:        log.With().Str("component", "ws").Logger(),
		clients:    make(map[*Client]struct{}),
		register:   make(chan *Client, 16),
		unregister: make(chan *Client, 16),
		broadcast:  make(chan broadcastMsg, 256),
		cache:      newMessageCache(),
	}
}

// Run owns the hub's event loop; return only when ctx is cancelled.
func (h *Hub) Run(ctx context.Context) {
	for {
		select {
		case <-ctx.Done():
			h.mu.Lock()
			for c := range h.clients {
				c.close()
			}
			h.mu.Unlock()
			return
		case c := <-h.register:
			h.mu.Lock()
			h.clients[c] = struct{}{}
			h.mu.Unlock()
		case c := <-h.unregister:
			h.mu.Lock()
			if _, ok := h.clients[c]; ok {
				delete(h.clients, c)
				c.close()
			}
			h.mu.Unlock()
		case msg := <-h.broadcast:
			h.cache.put(msg.channel, msg.env)
			h.mu.RLock()
			for c := range h.clients {
				if c.subscribed(msg.channel) {
					c.enqueue(msg.env)
				}
			}
			h.mu.RUnlock()
		}
	}
}

// Publish fans out env to every client subscribed to channel.
// It never blocks the caller — slow clients are dropped by their own send buffer.
func (h *Hub) Publish(channel string, env Envelope) {
	select {
	case h.broadcast <- broadcastMsg{channel: channel, env: env}:
	default:
		h.log.Warn().Str("channel", channel).Msg("broadcast dropped (backpressure)")
	}
}

// PublishPayload builds an envelope then Publish-es it. Errors are logged and swallowed.
func (h *Hub) PublishPayload(channel, typ string, payload any) {
	env, err := NewEnvelope(channel, typ, payload)
	if err != nil {
		h.log.Error().Err(err).Str("type", typ).Msg("publish marshal failed")
		return
	}
	h.Publish(channel, env)
}

// HandleUpgrade is the Gin handler that promotes the HTTP connection to WebSocket.
func (h *Hub) HandleUpgrade(c *gin.Context) {
	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		h.log.Warn().Err(err).Msg("upgrade failed")
		return
	}
	client := newClient(h, conn)
	h.register <- client
	go client.readPump()
	go client.writePump()
}
