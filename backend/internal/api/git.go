package api

import "github.com/gin-gonic/gin"

// RegisterGit mounts /projects/:id/git/* endpoints. Faz 7 fills these in.
func RegisterGit(r *gin.RouterGroup, d Deps) {
	g := r.Group("/projects/:id/git")
	g.GET("/status", stub)
	g.GET("/log", stub)
	g.GET("/diff", stub)
	g.POST("/commit", stub)
	g.POST("/checkout", stub)
	g.POST("/pull", stub)
	g.POST("/push", stub)
	g.POST("/stash", stub)
	g.POST("/restore", stub)

	r.GET("/git/branches", stub)
}
