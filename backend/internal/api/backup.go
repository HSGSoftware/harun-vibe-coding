package api

import "github.com/gin-gonic/gin"

// RegisterBackup mounts /backups/* endpoints. Faz 7 & Faz 9 fill these in.
func RegisterBackup(r *gin.RouterGroup, d Deps) {
	g := r.Group("/backups")
	g.GET("", stub)
	g.POST("", stub)
	g.GET("/:id", stub)
	g.GET("/:id/download", stub)
	g.POST("/:id/restore", stub)
	g.DELETE("/:id", stub)
	g.POST("/settings", stub)
	g.POST("/cloud/connect", stub)
	g.POST("/cloud/disconnect", stub)
}
