package api

import (
	"net/http"

	"github.com/gin-gonic/gin"

	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/storage"
)

// RegisterNotifications mounts /notifications/*.
func RegisterNotifications(r *gin.RouterGroup, d Deps) {
	repo := storage.NewNotificationsRepo(d.DB)
	g := r.Group("/notifications")

	g.GET("", func(c *gin.Context) {
		items, err := repo.List(c.Request.Context(), c.Query("unread") == "1")
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, gin.H{"notifications": items})
	})
	g.POST("/:id/read", func(c *gin.Context) {
		_ = repo.MarkRead(c.Request.Context(), c.Param("id"))
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})
	g.POST("/read-all", func(c *gin.Context) {
		_ = repo.MarkAllRead(c.Request.Context())
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})
	g.DELETE("/:id", func(c *gin.Context) {
		_ = repo.Delete(c.Request.Context(), c.Param("id"))
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})
	g.POST("/settings", stub)
}
