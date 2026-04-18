package api

import "github.com/gin-gonic/gin"

// RegisterNotifications mounts /notifications/* endpoints. Faz 8 fills these in.
func RegisterNotifications(r *gin.RouterGroup, d Deps) {
	g := r.Group("/notifications")
	g.GET("", stub)
	g.POST("/:id/read", stub)
	g.POST("/read-all", stub)
	g.DELETE("/:id", stub)
	g.POST("/settings", stub)
}
