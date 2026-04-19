package api

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"

	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/domain/git"
)

// RegisterGit mounts /projects/:id/git/* and /git/branches.
func RegisterGit(r *gin.RouterGroup, d Deps) {
	g := r.Group("/projects/:id/git")

	g.GET("/status", func(c *gin.Context) {
		p, _ := d.Projects.Get(c.Request.Context(), c.Param("id"))
		if p == nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "not_found"})
			return
		}
		st, err := git.GetStatus(p.Path)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, st)
	})

	g.GET("/log", func(c *gin.Context) {
		p, _ := d.Projects.Get(c.Request.Context(), c.Param("id"))
		if p == nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "not_found"})
			return
		}
		limit, _ := strconv.Atoi(c.DefaultQuery("limit", "50"))
		commits, err := git.GetLog(p.Path, limit)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, gin.H{"commits": commits})
	})

	g.POST("/commit", func(c *gin.Context) {
		p, _ := d.Projects.Get(c.Request.Context(), c.Param("id"))
		if p == nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "not_found"})
			return
		}
		var body struct {
			Message string `json:"message"`
		}
		if err := c.BindJSON(&body); err != nil || body.Message == "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "bad_body"})
			return
		}
		hash, err := git.Commit(p.Path, body.Message, "", "")
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, gin.H{"ok": true, "hash": hash})
	})

	g.POST("/checkout", func(c *gin.Context) {
		p, _ := d.Projects.Get(c.Request.Context(), c.Param("id"))
		if p == nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "not_found"})
			return
		}
		var body struct {
			Ref    string `json:"ref"`
			Create bool   `json:"create"`
		}
		if err := c.BindJSON(&body); err != nil || body.Ref == "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "bad_body"})
			return
		}
		if err := git.Checkout(p.Path, body.Ref, body.Create); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, gin.H{"ok": true, "branch": body.Ref})
	})

	g.GET("/diff", stub)
	g.POST("/pull", stub)
	g.POST("/push", stub)
	g.POST("/stash", stub)
	g.POST("/restore", stub)

	r.GET("/git/branches", stub)
}
