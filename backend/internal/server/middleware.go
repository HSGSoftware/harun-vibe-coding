package server

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/rs/zerolog"
)

// RequestLogger logs one structured entry per HTTP request.
func RequestLogger(log zerolog.Logger) gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()
		c.Next()
		log.Debug().
			Str("method", c.Request.Method).
			Str("path", c.Request.URL.Path).
			Int("status", c.Writer.Status()).
			Dur("latency", time.Since(start)).
			Str("client", c.ClientIP()).
			Msg("http")
	}
}

// AuthGuard enforces a shared token if configured. Empty token disables the check.
// Token can be provided via X-Harun-Token header or ?token= query param.
func AuthGuard(token string) gin.HandlerFunc {
	return func(c *gin.Context) {
		if token == "" {
			c.Next()
			return
		}
		got := c.GetHeader("X-Harun-Token")
		if got == "" {
			got = c.Query("token")
		}
		if got != token {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
			return
		}
		c.Next()
	}
}
