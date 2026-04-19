package api

import (
	"encoding/json"
	"net/http"

	"github.com/gin-gonic/gin"

	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/storage"
)

// RegisterSettings mounts /settings/*.
func RegisterSettings(r *gin.RouterGroup, d Deps) {
	repo := storage.NewSettingsRepo(d.DB)
	g := r.Group("/settings")

	g.GET("", func(c *gin.Context) {
		all, err := repo.All(c.Request.Context())
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, all)
	})

	g.PATCH("", func(c *gin.Context) {
		raw, err := c.GetRawData()
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		var patch map[string]any
		if err := json.Unmarshal(raw, &patch); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "bad_body"})
			return
		}
		for k, v := range patch {
			enc, _ := json.Marshal(v)
			_ = repo.Set(c.Request.Context(), k, string(enc))
		}
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})

	g.POST("/theme", stub)
	g.POST("/shortcuts", stub)
	g.GET("/export", stub)
	g.POST("/import", stub)
}
