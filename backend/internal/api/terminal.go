package api

import (
	"encoding/json"
	"net/http"

	"github.com/gin-gonic/gin"

	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/ws"
)

// RegisterTerminal mounts /terminals/* REST + wires inbound WS terminal.* handlers.
// PTY I/O itself flows over WebSocket terminal channel via the hub.
func RegisterTerminal(r *gin.RouterGroup, d Deps) {
	g := r.Group("/terminals")

	g.GET("", func(c *gin.Context) {
		sessions := d.Terminals.List()
		c.JSON(http.StatusOK, gin.H{"terminals": sessions})
	})

	g.POST("", func(c *gin.Context) {
		var body struct {
			CWD   string `json:"cwd"`
			Cols  int    `json:"cols"`
			Rows  int    `json:"rows"`
			Shell string `json:"shell"`
		}
		_ = c.BindJSON(&body)
		cols := uint16(body.Cols)
		rows := uint16(body.Rows)
		if cols == 0 {
			cols = 80
		}
		if rows == 0 {
			rows = 24
		}
		cwd := body.CWD
		if cwd == "" {
			cwd = d.Config.Paths.ProjectsDir
		}
		s, err := d.Terminals.Start(c.Request.Context(), cwd, body.Shell, cols, rows)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, gin.H{"id": s.ID, "cwd": s.CWD})
	})

	g.DELETE("/:id", func(c *gin.Context) {
		_ = d.Terminals.Close(c.Param("id"))
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})

	g.POST("/:id/resize", func(c *gin.Context) {
		var body struct {
			Cols int `json:"cols"`
			Rows int `json:"rows"`
		}
		if err := c.BindJSON(&body); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "bad_body"})
			return
		}
		s := d.Terminals.Get(c.Param("id"))
		if s == nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "not_found"})
			return
		}
		if err := s.Resize(uint16(body.Cols), uint16(body.Rows)); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})

	// Wire inbound WS handlers once per server lifetime. Idempotent registrations are OK.
	ws.RegisterInbound("terminal.input", func(_ *ws.Client, payload json.RawMessage) {
		var body struct {
			TerminalID string `json:"terminal_id"`
			Data       string `json:"data"`
		}
		if err := json.Unmarshal(payload, &body); err != nil {
			return
		}
		s := d.Terminals.Get(body.TerminalID)
		if s == nil {
			return
		}
		_, _ = s.Write([]byte(body.Data))
	})
	ws.RegisterInbound("terminal.resize", func(_ *ws.Client, payload json.RawMessage) {
		var body struct {
			TerminalID string `json:"terminal_id"`
			Cols       int    `json:"cols"`
			Rows       int    `json:"rows"`
		}
		if err := json.Unmarshal(payload, &body); err != nil {
			return
		}
		s := d.Terminals.Get(body.TerminalID)
		if s != nil {
			_ = s.Resize(uint16(body.Cols), uint16(body.Rows))
		}
	})
}
