package ai

import (
	"context"
	"time"
)

// contextWithTimeout is a tiny helper that returns a derived context with a
// second-granularity deadline. Kept separate so the production code reads
// cleanly: `ctx, cancel := contextWithTimeout(ctx, 5)`.
func contextWithTimeout(parent context.Context, seconds int) (context.Context, context.CancelFunc) {
	return context.WithTimeout(parent, time.Duration(seconds)*time.Second)
}
