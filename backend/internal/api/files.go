package api

import "github.com/gin-gonic/gin"

// RegisterFiles mounts file CRUD + search. Faz 3 fills these in.
func RegisterFiles(r *gin.RouterGroup, d Deps) {
	g := r.Group("/projects/:id")
	g.GET("/files", stub)
	g.GET("/file", stub)
	g.PUT("/file", stub)
	g.POST("/file/new", stub)
	g.DELETE("/file", stub)
	g.POST("/file/rename", stub)
	g.POST("/file/duplicate", stub)
	g.GET("/search", stub)
	g.POST("/replace", stub)
}
