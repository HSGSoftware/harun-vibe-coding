package api

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"

	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/domain/project"
)

// RegisterProjects mounts CRUD + lifecycle routes. Runtime fields (Status,
// RunningPort, TunnelURL) are stitched on here from the runner + tunnel services.
func RegisterProjects(r *gin.RouterGroup, d Deps) {
	g := r.Group("/projects")

	g.GET("", func(c *gin.Context) {
		list, err := d.Projects.List(c.Request.Context())
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		enriched := enrichAll(d, list)
		c.JSON(http.StatusOK, gin.H{"projects": enriched, "total": len(enriched)})
	})

	g.GET("/:id", func(c *gin.Context) {
		p, err := d.Projects.Get(c.Request.Context(), c.Param("id"))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		if p == nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "not_found"})
			return
		}
		c.JSON(http.StatusOK, enrich(d, *p))
	})

	g.POST("", func(c *gin.Context) {
		var body struct {
			Name     string `json:"name"`
			Env      string `json:"env"`
			Source   string `json:"source"`
			Port     int    `json:"port"`
			EntryCmd string `json:"entry_cmd"`
			Group    string `json:"group"`
		}
		if err := c.BindJSON(&body); err != nil || strings.TrimSpace(body.Name) == "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "bad_body"})
			return
		}
		p, err := d.Projects.CreateEmpty(c.Request.Context(), body.Name, body.Env, body.Port)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		if body.EntryCmd != "" {
			_, _ = d.Projects.Update(c.Request.Context(), p.ID, project.Project{EntryCmd: body.EntryCmd, Group: body.Group})
		}
		c.JSON(http.StatusOK, enrich(d, *p))
	})

	g.PATCH("/:id", func(c *gin.Context) {
		var patch project.Project
		if err := c.BindJSON(&patch); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "bad_body"})
			return
		}
		p, err := d.Projects.Update(c.Request.Context(), c.Param("id"), patch)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, enrich(d, *p))
	})

	g.DELETE("/:id", func(c *gin.Context) {
		keep := c.Query("keep_files") == "1"
		if err := d.Projects.Delete(c.Request.Context(), c.Param("id"), keep); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})

	g.POST("/:id/start", func(c *gin.Context) {
		p, _ := d.Projects.Get(c.Request.Context(), c.Param("id"))
		if p == nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "not_found"})
			return
		}
		if err := d.Runner.Start(c.Request.Context(), *p); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		_ = d.Projects.Touch(c.Request.Context(), p.ID)
		c.JSON(http.StatusOK, gin.H{"ok": true, "port": p.Port})
	})

	g.POST("/:id/stop", func(c *gin.Context) {
		if err := d.Runner.Stop(c.Param("id")); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})

	g.POST("/:id/restart", func(c *gin.Context) {
		p, _ := d.Projects.Get(c.Request.Context(), c.Param("id"))
		if p == nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "not_found"})
			return
		}
		if err := d.Runner.Restart(c.Request.Context(), *p); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})

	g.GET("/:id/logs", func(c *gin.Context) {
		lines := d.Runner.Tail(c.Param("id"), 400)
		c.JSON(http.StatusOK, gin.H{"logs": strings.Join(lines, "\n")})
	})

	g.POST("/:id/input", func(c *gin.Context) {
		var body struct {
			Text string `json:"text"`
		}
		if err := c.BindJSON(&body); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "bad_body"})
			return
		}
		if err := d.Runner.Write(c.Param("id"), body.Text); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})

	g.POST("/:id/refresh", stub)
	g.GET("/:id/export", stub)
	g.POST("/import/zip", stub)
	g.POST("/import/clone", stub)
	g.GET("/:id/qr", stub)
}

func enrich(d Deps, p project.Project) project.Project {
	status, port := d.Runner.Status(p.ID)
	p.Status = status
	p.RunningPort = port
	if t := d.Tunnel.Get(p.ID); t != nil {
		p.TunnelURL = t.URL
	}
	return p
}

func enrichAll(d Deps, items []project.Project) []project.Project {
	out := make([]project.Project, len(items))
	for i, p := range items {
		out[i] = enrich(d, p)
	}
	return out
}
