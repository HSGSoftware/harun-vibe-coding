package api

import "github.com/gin-gonic/gin"

// RegisterTerminal mounts /terminals/* endpoints. Faz 4 fills these in.
// PTY I/O is over WebSocket terminal channel.
func RegisterTerminal(r *gin.RouterGroup, d Deps) {
	g := r.Group("/terminals")
	g.GET("", stub)
	g.POST("", stub)
	g.DELETE("/:id", stub)
	g.POST("/:id/resize", stub)
}
