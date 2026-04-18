package api

import "github.com/gin-gonic/gin"

// RegisterTunnel mounts /projects/:id/tunnel/* endpoints. Faz 2 fills these in.
func RegisterTunnel(r *gin.RouterGroup, d Deps) {
	g := r.Group("/projects/:id/tunnel")
	g.POST("/start", stub)
	g.POST("/stop", stub)
	g.GET("", stub)
}
