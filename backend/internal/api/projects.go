package api

import (
	"github.com/gin-gonic/gin"
)

// RegisterProjects mounts /projects/* routes. Faz 2 replaces the stubs.
func RegisterProjects(r *gin.RouterGroup, d Deps) {
	g := r.Group("/projects")
	g.GET("", stub)
	g.GET("/:id", stub)
	g.POST("", stub)
	g.PATCH("/:id", stub)
	g.DELETE("/:id", stub)
	g.POST("/:id/start", stub)
	g.POST("/:id/stop", stub)
	g.POST("/:id/restart", stub)
	g.POST("/:id/refresh", stub)
	g.GET("/:id/logs", stub)
	g.POST("/:id/input", stub)
	g.GET("/:id/export", stub)
	g.POST("/import/zip", stub)
	g.POST("/import/clone", stub)
	g.GET("/:id/qr", stub)
}
