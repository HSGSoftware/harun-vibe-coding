package api

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// RegisterTunnel mounts tunnel start/stop/status endpoints.
func RegisterTunnel(r *gin.RouterGroup, d Deps) {
	g := r.Group("/projects/:id/tunnel")

	g.POST("/start", func(c *gin.Context) {
		p, _ := d.Projects.Get(c.Request.Context(), c.Param("id"))
		if p == nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "not_found"})
			return
		}
		port := p.Port
		if _, runningPort := d.Runner.Status(p.ID); runningPort != 0 {
			port = runningPort
		}
		if port == 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "no_port"})
			return
		}
		t, err := d.Tunnel.StartCloudflared(c.Request.Context(), p.ID, port)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, gin.H{"url": t.URL, "provider": t.Provider})
	})

	g.POST("/stop", func(c *gin.Context) {
		d.Tunnel.Stop(c.Param("id"))
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})

	g.GET("", func(c *gin.Context) {
		t := d.Tunnel.Get(c.Param("id"))
		if t == nil {
			c.JSON(http.StatusOK, gin.H{"active": false})
			return
		}
		c.JSON(http.StatusOK, gin.H{"active": true, "url": t.URL, "provider": t.Provider})
	})
}
