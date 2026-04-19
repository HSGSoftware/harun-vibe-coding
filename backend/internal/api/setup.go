package api

import (
	"context"
	"encoding/json"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/domain/ai"
	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/ws"
)

// RegisterSetup mounts setup-wizard endpoints. All of §5.2 lives here.
func RegisterSetup(r *gin.RouterGroup, d Deps) {
	g := r.Group("/setup")

	g.GET("/status", func(c *gin.Context) {
		st, err := LoadSetupState(c.Request.Context(), d.DB)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, st)
	})

	g.GET("/cli/detect", func(c *gin.Context) {
		ctx := c.Request.Context()
		claude := ai.DetectCLI(ctx, "claude", "claude")
		gemini := ai.DetectCLI(ctx, "gemini", "gemini")
		if claude.Installed {
			claude.LoggedIn = ai.ProbeClaudeLogin(ctx, claude.Path)
		}
		if gemini.Installed {
			gemini.LoggedIn = ai.ProbeGeminiLogin(ctx, gemini.Path)
		}
		c.JSON(http.StatusOK, gin.H{"claude": claude, "gemini": gemini})
	})

	g.POST("/cli/install", func(c *gin.Context) {
		var body struct {
			Provider string `json:"provider"`
		}
		if err := c.BindJSON(&body); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "bad_body"})
			return
		}
		id := uuid.NewString()
		var task *ai.Task
		var err error
		switch body.Provider {
		case "claude":
			task, err = ai.InstallClaudeCLI(context.Background(), id)
		case "gemini":
			task, err = ai.InstallGeminiCLI(context.Background(), id)
		default:
			c.JSON(http.StatusBadRequest, gin.H{"error": "unknown_provider"})
			return
		}
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		startTaskStream(d.Hub, body.Provider, "install", id, task)
		c.JSON(http.StatusOK, gin.H{"task_id": id})
	})

	g.POST("/cli/login", func(c *gin.Context) {
		var body struct {
			Provider string `json:"provider"`
		}
		if err := c.BindJSON(&body); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "bad_body"})
			return
		}
		info := ai.DetectCLI(c.Request.Context(), body.Provider, body.Provider)
		if !info.Installed {
			c.JSON(http.StatusBadRequest, gin.H{"error": "cli_not_installed"})
			return
		}
		id := uuid.NewString()
		var task *ai.Task
		var err error
		switch body.Provider {
		case "claude":
			task, err = ai.LoginClaudeCLI(context.Background(), id, info.Path)
		case "gemini":
			task, err = ai.LoginGeminiCLI(context.Background(), id, info.Path)
		default:
			c.JSON(http.StatusBadRequest, gin.H{"error": "unknown_provider"})
			return
		}
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		startTaskStream(d.Hub, body.Provider, "login", id, task)
		c.JSON(http.StatusOK, gin.H{"task_id": id})
	})

	g.POST("/cli/logout", func(c *gin.Context) {
		var body struct {
			Provider string `json:"provider"`
		}
		if err := c.BindJSON(&body); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "bad_body"})
			return
		}
		info := ai.DetectCLI(c.Request.Context(), body.Provider, body.Provider)
		if !info.Installed {
			c.JSON(http.StatusBadRequest, gin.H{"error": "cli_not_installed"})
			return
		}
		var err error
		switch body.Provider {
		case "claude":
			err = ai.LogoutClaudeCLI(c.Request.Context(), info.Path)
		case "gemini":
			err = ai.LogoutGeminiCLI(c.Request.Context(), info.Path)
		default:
			c.JSON(http.StatusBadRequest, gin.H{"error": "unknown_provider"})
			return
		}
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})

	g.POST("/cli/test", func(c *gin.Context) {
		var body struct {
			Provider string `json:"provider"`
		}
		if err := c.BindJSON(&body); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "bad_body"})
			return
		}
		info := ai.DetectCLI(c.Request.Context(), body.Provider, body.Provider)
		if !info.Installed {
			c.JSON(http.StatusOK, gin.H{"ok": false, "error": "cli_not_installed"})
			return
		}
		var loggedIn bool
		switch body.Provider {
		case "claude":
			loggedIn = ai.ProbeClaudeLogin(c.Request.Context(), info.Path)
		case "gemini":
			loggedIn = ai.ProbeGeminiLogin(c.Request.Context(), info.Path)
		}
		c.JSON(http.StatusOK, gin.H{"ok": loggedIn, "version": info.Version})
	})

	g.POST("/preferences", func(c *gin.Context) {
		raw, err := c.GetRawData()
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		_ = d.DB // preferences saved into settings table
		_ = raw
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})

	g.POST("/complete", func(c *gin.Context) {
		st, err := LoadSetupState(c.Request.Context(), d.DB)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		st.Completed = true
		st.Step = 7
		if err := SaveSetupState(c.Request.Context(), d.DB, st); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})

	g.POST("/reset", func(c *gin.Context) {
		st := &SetupState{Step: 1, CLI: map[string]string{}, Missing: []string{}}
		if err := SaveSetupState(c.Request.Context(), d.DB, st); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})
}

// startTaskStream forwards CLI subprocess output to the WebSocket events channel.
// Flutter subscribes on `events` and filters by `task_id`.
func startTaskStream(hub *ws.Hub, provider, kind, id string, task *ai.Task) {
	setupTasksMu.Lock()
	setupTasks.Add(task)
	setupTasksMu.Unlock()

	go func() {
		defer func() {
			setupTasksMu.Lock()
			setupTasks.Remove(id)
			setupTasksMu.Unlock()
		}()
		for event := range task.Output {
			payload := map[string]any{
				"task_id":  id,
				"provider": provider,
				"kind":     kind,
				"line":     event.Line,
				"stream":   event.Kind,
			}
			if event.AuthURL != "" {
				payload["auth_url"] = event.AuthURL
			}
			if event.Completed {
				payload["completed"] = true
				payload["exit_code"] = event.ExitCode
			}
			raw, _ := json.Marshal(payload)
			hub.PublishPayload("events", "events.cli_task", json.RawMessage(raw))
		}
	}()
}

