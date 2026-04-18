package ws

import (
	"encoding/json"
	"sync"
	"time"

	"github.com/gorilla/websocket"
)

const (
	writeWait      = 10 * time.Second
	pongWait       = 60 * time.Second
	pingPeriod     = (pongWait * 9) / 10
	sendBufferSize = 256
)

// Client is a single WebSocket connection with its subscribed channel set.
type Client struct {
	hub   *Hub
	conn  *websocket.Conn
	send  chan Envelope
	subs  map[string]struct{}
	mu    sync.RWMutex
	once  sync.Once
}

func newClient(h *Hub, conn *websocket.Conn) *Client {
	return &Client{
		hub:  h,
		conn: conn,
		send: make(chan Envelope, sendBufferSize),
		subs: map[string]struct{}{},
	}
}

func (c *Client) subscribed(channel string) bool {
	c.mu.RLock()
	defer c.mu.RUnlock()
	_, ok := c.subs[channel]
	return ok
}

func (c *Client) subscribe(channels ...string) {
	c.mu.Lock()
	for _, ch := range channels {
		c.subs[ch] = struct{}{}
	}
	c.mu.Unlock()
}

func (c *Client) unsubscribe(channels ...string) {
	c.mu.Lock()
	for _, ch := range channels {
		delete(c.subs, ch)
	}
	c.mu.Unlock()
}

func (c *Client) enqueue(env Envelope) {
	select {
	case c.send <- env:
	default:
		c.hub.log.Warn().Msg("client send buffer full, dropping")
	}
}

func (c *Client) close() {
	c.once.Do(func() {
		close(c.send)
		_ = c.conn.Close()
	})
}

// readPump reads inbound control messages (subscribe, chat.input, terminal.input, ping, resume)
// and dispatches them to per-channel handlers.
func (c *Client) readPump() {
	defer func() { c.hub.unregister <- c }()
	c.conn.SetReadLimit(1 << 20) // 1 MB
	_ = c.conn.SetReadDeadline(time.Now().Add(pongWait))
	c.conn.SetPongHandler(func(string) error {
		return c.conn.SetReadDeadline(time.Now().Add(pongWait))
	})
	for {
		_, data, err := c.conn.ReadMessage()
		if err != nil {
			return
		}
		var raw struct {
			Type     string          `json:"type"`
			Channels []string        `json:"channels"`
			Payload  json.RawMessage `json:"payload"`
		}
		if err := json.Unmarshal(data, &raw); err != nil {
			c.hub.log.Debug().Err(err).Msg("bad inbound json")
			continue
		}
		switch raw.Type {
		case "subscribe":
			c.subscribe(raw.Channels...)
		case "unsubscribe":
			c.unsubscribe(raw.Channels...)
		case "ping":
			c.enqueuePong()
		case "resume":
			c.handleResume(raw.Payload)
		default:
			c.hub.dispatchInbound(c, raw.Type, raw.Payload)
		}
	}
}

// writePump pumps queued envelopes to the socket and drives pings.
func (c *Client) writePump() {
	ticker := time.NewTicker(pingPeriod)
	defer ticker.Stop()
	for {
		select {
		case env, ok := <-c.send:
			_ = c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if !ok {
				_ = c.conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}
			if err := c.conn.WriteJSON(env); err != nil {
				return
			}
		case <-ticker.C:
			_ = c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if err := c.conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				return
			}
		}
	}
}

func (c *Client) enqueuePong() {
	env, err := NewEnvelope("control", "pong", map[string]int64{"t": time.Now().UnixMilli()})
	if err != nil {
		return
	}
	c.enqueue(env)
}

func (c *Client) handleResume(payload json.RawMessage) {
	var p struct {
		FromID string `json:"from_id"`
	}
	if err := json.Unmarshal(payload, &p); err != nil {
		return
	}
	missed := c.hub.cache.since(p.FromID)
	for _, env := range missed {
		c.enqueue(env)
	}
}
