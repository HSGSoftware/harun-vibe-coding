package api

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// RegisterSetup mounts setup-wizard endpoints. Faz 1 fills these in.
func RegisterSetup(r *gin.RouterGroup, d Deps) {
	g := r.Group("/setup")
	g.GET("/status", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"completed": false, "step": 1, "missing": []string{}, "cli_status": gin.H{}})
	})
	g.GET("/cli/detect", func(c *gin.Context) { c.JSON(http.StatusOK, gin.H{"claude": gin.H{"installed": false}, "gemini": gin.H{"installed": false}}) })
	g.POST("/cli/install", stub)
	g.POST("/cli/login", stub)
	g.POST("/cli/logout", stub)
	g.POST("/cli/test", stub)
	g.POST("/preferences", stub)
	g.POST("/complete", stub)
	g.POST("/reset", stub)
}

// stub is a placeholder that returns 501 until the handler is implemented in a later phase.
func stub(c *gin.Context) {
	c.JSON(http.StatusNotImplemented, gin.H{"error": "not_implemented", "path": c.FullPath()})
}
