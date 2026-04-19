package ws

import (
	"sync"
	"time"
)

// messageCache retains recent envelopes for resume-on-reconnect (plan.md §6.6: 3-minute window).
type messageCache struct {
	mu      sync.Mutex
	entries []cachedEnvelope
}

type cachedEnvelope struct {
	env       Envelope
	channel   string
	cachedAt  time.Time
}

const cacheTTL = 3 * time.Minute

func newMessageCache() *messageCache { return &messageCache{} }

func (c *messageCache) put(channel string, env Envelope) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.gc()
	c.entries = append(c.entries, cachedEnvelope{env: env, channel: channel, cachedAt: time.Now()})
}

func (c *messageCache) since(fromID string) []Envelope {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.gc()
	if fromID == "" {
		return nil
	}
	idx := -1
	for i, e := range c.entries {
		if e.env.ID == fromID {
			idx = i
			break
		}
	}
	if idx < 0 || idx+1 >= len(c.entries) {
		return nil
	}
	out := make([]Envelope, 0, len(c.entries)-idx-1)
	for _, e := range c.entries[idx+1:] {
		out = append(out, e.env)
	}
	return out
}

func (c *messageCache) gc() {
	cutoff := time.Now().Add(-cacheTTL)
	i := 0
	for i < len(c.entries) && c.entries[i].cachedAt.Before(cutoff) {
		i++
	}
	if i > 0 {
		c.entries = c.entries[i:]
	}
}
