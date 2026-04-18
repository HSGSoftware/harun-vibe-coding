package api

import "github.com/gin-gonic/gin"

// RegisterSettings mounts /settings/* endpoints. Faz 10 fills these in.
func RegisterSettings(r *gin.RouterGroup, d Deps) {
	g := r.Group("/settings")
	g.GET("", stub)
	g.PATCH("", stub)
	g.POST("/theme", stub)
	g.POST("/shortcuts", stub)
	g.GET("/export", stub)
	g.POST("/import", stub)
}
