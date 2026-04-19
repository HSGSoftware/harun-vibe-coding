package api

import (
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
)

// RegisterBackup mounts /backups/* endpoints.
func RegisterBackup(r *gin.RouterGroup, d Deps) {
	g := r.Group("/backups")

	g.GET("", func(c *gin.Context) {
		items, err := d.Backups.List(c.Request.Context(), c.Query("project_id"))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, gin.H{"backups": items})
	})

	g.POST("", func(c *gin.Context) {
		var body struct {
			ProjectID string `json:"project_id"`
			Type      string `json:"type"`
			Note      string `json:"note"`
		}
		if err := c.BindJSON(&body); err != nil || body.ProjectID == "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "bad_body"})
			return
		}
		p, _ := d.Projects.Get(c.Request.Context(), body.ProjectID)
		if p == nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "not_found"})
			return
		}
		var b any
		var err error
		switch body.Type {
		case "git_checkpoint":
			b, err = d.Backups.CreateGitCheckpoint(c.Request.Context(), p.ID, p.Path, body.Note)
		default:
			b, err = d.Backups.CreateLocalZip(c.Request.Context(), p.ID, p.Path, "manual", body.Note)
		}
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, b)
	})

	g.GET("/:id", func(c *gin.Context) {
		b, err := d.Backups.Get(c.Request.Context(), c.Param("id"))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		if b == nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "not_found"})
			return
		}
		c.JSON(http.StatusOK, b)
	})

	g.GET("/:id/download", func(c *gin.Context) {
		b, _ := d.Backups.Get(c.Request.Context(), c.Param("id"))
		if b == nil || b.Path == "" {
			c.JSON(http.StatusNotFound, gin.H{"error": "not_found"})
			return
		}
		if _, err := os.Stat(b.Path); err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "missing_file"})
			return
		}
		c.FileAttachment(b.Path, b.ID+".zip")
	})

	g.DELETE("/:id", func(c *gin.Context) {
		if err := d.Backups.Delete(c.Request.Context(), c.Param("id")); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})

	g.POST("/:id/restore", stub)
	g.POST("/settings", stub)
	g.POST("/cloud/connect", stub)
	g.POST("/cloud/disconnect", stub)
}
