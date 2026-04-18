package api

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"

	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/domain/fs"
)

// RegisterFiles mounts file CRUD + search under /projects/:id/*.
func RegisterFiles(r *gin.RouterGroup, d Deps) {
	g := r.Group("/projects/:id")

	g.GET("/files", func(c *gin.Context) {
		p, _ := d.Projects.Get(c.Request.Context(), c.Param("id"))
		if p == nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "not_found"})
			return
		}
		depth, _ := strconv.Atoi(c.DefaultQuery("depth", "3"))
		start := c.DefaultQuery("path", "/")
		tree, err := fs.Tree(p.Path, start, depth)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, gin.H{"tree": tree})
	})

	g.GET("/file", func(c *gin.Context) {
		p, _ := d.Projects.Get(c.Request.Context(), c.Param("id"))
		if p == nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "not_found"})
			return
		}
		rel := c.Query("path")
		content, err := fs.Read(p.Path, rel)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, content)
	})

	g.PUT("/file", func(c *gin.Context) {
		p, _ := d.Projects.Get(c.Request.Context(), c.Param("id"))
		if p == nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "not_found"})
			return
		}
		var body struct {
			Path       string `json:"path"`
			Content    string `json:"content"`
			CreateDirs bool   `json:"create_dirs"`
		}
		if err := c.BindJSON(&body); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "bad_body"})
			return
		}
		n, err := fs.Write(p.Path, body.Path, body.Content, body.CreateDirs)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, gin.H{"ok": true, "size": n})
	})

	g.POST("/file/new", func(c *gin.Context) {
		p, _ := d.Projects.Get(c.Request.Context(), c.Param("id"))
		if p == nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "not_found"})
			return
		}
		var body struct {
			Path  string `json:"path"`
			IsDir bool   `json:"is_dir"`
		}
		if err := c.BindJSON(&body); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "bad_body"})
			return
		}
		if err := fs.CreateFile(p.Path, body.Path, body.IsDir); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})

	g.DELETE("/file", func(c *gin.Context) {
		p, _ := d.Projects.Get(c.Request.Context(), c.Param("id"))
		if p == nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "not_found"})
			return
		}
		var body struct {
			Path string `json:"path"`
		}
		if err := c.BindJSON(&body); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "bad_body"})
			return
		}
		if err := fs.Delete(p.Path, body.Path); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})

	g.POST("/file/rename", func(c *gin.Context) {
		p, _ := d.Projects.Get(c.Request.Context(), c.Param("id"))
		if p == nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "not_found"})
			return
		}
		var body struct {
			OldPath string `json:"old_path"`
			NewPath string `json:"new_path"`
		}
		if err := c.BindJSON(&body); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "bad_body"})
			return
		}
		if err := fs.Rename(p.Path, body.OldPath, body.NewPath); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})

	g.GET("/search", func(c *gin.Context) {
		p, _ := d.Projects.Get(c.Request.Context(), c.Param("id"))
		if p == nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "not_found"})
			return
		}
		opts := fs.Opts{
			Query:         c.Query("q"),
			CaseSensitive: c.Query("case") == "1",
			Regex:         c.Query("regex") == "1",
			Glob:          c.Query("glob"),
		}
		hits, err := fs.Search(p.Path, opts)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, gin.H{"results": hits})
	})

	g.POST("/file/duplicate", stub)
	g.POST("/replace", stub)
}
