package api

import (
	"context"
	"encoding/json"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/domain/ai"
	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/storage"
	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/ws"
)

// aiSvc is package-global so ws inbound handlers registered inside RegisterAI
// can reach the service without Deps plumbing through goroutines.
var aiSvc = ai.NewService()

// RegisterAI mounts conversations + ai endpoints and wires the chat WS handlers.
func RegisterAI(r *gin.RouterGroup, d Deps) {
	convRepo := storage.NewConversationsRepo(d.DB)

	cg := r.Group("/conversations")
	cg.GET("", func(c *gin.Context) {
		limit, _ := strconv.Atoi(c.DefaultQuery("limit", "50"))
		list, err := convRepo.List(c.Request.Context(), c.Query("project_id"), limit)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, gin.H{"conversations": list})
	})
	cg.GET("/:id", func(c *gin.Context) {
		conv, err := convRepo.Get(c.Request.Context(), c.Param("id"))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		if conv == nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "not_found"})
			return
		}
		c.JSON(http.StatusOK, gin.H{"conversation": conv, "messages": []any{}})
	})
	cg.POST("", func(c *gin.Context) {
		var body struct {
			ProjectID string `json:"project_id"`
			Provider  string `json:"provider"`
			Model     string `json:"model"`
			Title     string `json:"title"`
		}
		if err := c.BindJSON(&body); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "bad_body"})
			return
		}
		conv := storage.Conversation{
			ID:        uuid.NewString(),
			ProjectID: body.ProjectID,
			Provider:  body.Provider,
			Model:     body.Model,
			Title:     defaultTitle(body.Title),
			CreatedAt: time.Now(),
			UpdatedAt: time.Now(),
		}
		if err := convRepo.Insert(c.Request.Context(), conv); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, conv)
	})
	cg.PATCH("/:id", func(c *gin.Context) {
		var body struct {
			Title string `json:"title"`
		}
		if err := c.BindJSON(&body); err == nil && body.Title != "" {
			_ = convRepo.UpdateTitle(c.Request.Context(), c.Param("id"), body.Title)
		}
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})
	cg.DELETE("/:id", func(c *gin.Context) {
		_ = convRepo.Delete(c.Request.Context(), c.Param("id"))
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})
	cg.POST("/:id/branch", stub)
	cg.POST("/:id/summarize", stub)
	cg.GET("/:id/export/markdown", stub)
	cg.POST("/:id/fork-to", stub)

	aig := r.Group("/ai")
	aig.GET("/tools", stub)
	aig.GET("/permissions", stub)
	aig.POST("/permissions", stub)
	aig.DELETE("/permissions/:id", stub)
	aig.POST("/permissions/reset", stub)
	aig.GET("/usage", func(c *gin.Context) {
		rows, err := storage.NewUsageRepo(d.DB).List(c.Request.Context(), c.Query("project_id"), c.Query("from"), c.Query("to"))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		var total float64
		for _, r := range rows {
			total += r.CostUSD
		}
		c.JSON(http.StatusOK, gin.H{"daily": rows, "total": total})
	})
	aig.GET("/context-files/:conversation_id", func(c *gin.Context) {
		cid := c.Param("conversation_id")
		rows, err := d.DB.QueryContext(c.Request.Context(), `SELECT path, included FROM context_files WHERE conversation_id = ?`, cid)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		defer rows.Close()
		type entry struct {
			Path     string `json:"path"`
			Included bool   `json:"included"`
		}
		var out []entry
		for rows.Next() {
			var e entry
			var inc int
			if err := rows.Scan(&e.Path, &inc); err == nil {
				e.Included = inc != 0
				out = append(out, e)
			}
		}
		c.JSON(http.StatusOK, gin.H{"files": out})
	})
	aig.POST("/context-files/:conversation_id", func(c *gin.Context) {
		var body struct {
			Path     string `json:"path"`
			Included bool   `json:"included"`
		}
		if err := c.BindJSON(&body); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "bad_body"})
			return
		}
		incInt := 0
		if body.Included {
			incInt = 1
		}
		_, err := d.DB.ExecContext(c.Request.Context(), `
			INSERT INTO context_files(conversation_id, path, included) VALUES (?,?,?)
			ON CONFLICT(conversation_id, path) DO UPDATE SET included = excluded.included
		`, c.Param("conversation_id"), body.Path, incInt)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})
	promptsRepo := storage.NewPromptsRepo(d.DB)
	aig.GET("/prompts", func(c *gin.Context) {
		list, err := promptsRepo.List(c.Request.Context())
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, gin.H{"prompts": list})
	})
	aig.POST("/prompts", func(c *gin.Context) {
		var body struct {
			Title   string `json:"title"`
			Content string `json:"content"`
			Tags    string `json:"tags"`
		}
		if err := c.BindJSON(&body); err != nil || body.Title == "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "bad_body"})
			return
		}
		p := storage.Prompt{
			ID:        uuid.NewString(),
			Title:     body.Title,
			Content:   body.Content,
			Tags:      body.Tags,
			CreatedAt: time.Now(),
			UpdatedAt: time.Now(),
		}
		if err := promptsRepo.Insert(c.Request.Context(), p); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, p)
	})
	aig.DELETE("/prompts/:id", func(c *gin.Context) {
		_ = promptsRepo.Delete(c.Request.Context(), c.Param("id"))
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})
	aig.POST("/analyze-error", stub)
	aig.POST("/explain-code", stub)
	aig.POST("/generate-commit-message", stub)
	aig.POST("/review-diff", stub)
	aig.POST("/suggest-project-setup", stub)
	aig.POST("/speech-to-text", stub)

	wireChatHandlers(d, convRepo)
}

func defaultTitle(in string) string {
	if in != "" {
		return in
	}
	return "Yeni sohbet"
}

// wireChatHandlers registers ws inbound types: chat.input, chat.abort, chat.tool_decision.
func wireChatHandlers(d Deps, convRepo *storage.ConversationsRepo) {
	ws.RegisterInbound("chat.input", func(_ *ws.Client, payload json.RawMessage) {
		var body struct {
			ConversationID string   `json:"conversation_id"`
			Text           string   `json:"text"`
			ContextFiles   []string `json:"context_files"`
			Images         []string `json:"images"`
			Options        struct {
				Model string `json:"model"`
			} `json:"options"`
		}
		if err := json.Unmarshal(payload, &body); err != nil {
			return
		}
		conv, err := convRepo.Get(context.Background(), body.ConversationID)
		if err != nil || conv == nil {
			publishChatError(d.Hub, body.ConversationID, "conversation_missing", "Sohbet bulunamadı")
			return
		}
		projectDir := d.Config.Paths.ProjectsDir
		if p, _ := d.Projects.Get(context.Background(), conv.ProjectID); p != nil {
			projectDir = p.Path
		}
		model := body.Options.Model
		if model == "" {
			model = conv.Model
		}
		sess, err := aiSvc.Chat(context.Background(), ai.ChatRequest{
			ConversationID: body.ConversationID,
			Provider:       conv.Provider,
			Model:          model,
			Text:           body.Text,
			ProjectDir:     projectDir,
			ContextFiles:   body.ContextFiles,
			Images:         body.Images,
		})
		if err != nil {
			publishChatError(d.Hub, body.ConversationID, "cli_error", err.Error())
			return
		}
		go forwardChatEvents(d.Hub, sess)
		convRepo.Touch(context.Background(), body.ConversationID)
	})

	ws.RegisterInbound("chat.abort", func(_ *ws.Client, payload json.RawMessage) {
		var body struct {
			ConversationID string `json:"conversation_id"`
		}
		if err := json.Unmarshal(payload, &body); err != nil {
			return
		}
		aiSvc.Abort(body.ConversationID)
	})

	ws.RegisterInbound("chat.tool_decision", func(_ *ws.Client, payload json.RawMessage) {
		var body struct {
			ConversationID string `json:"conversation_id"`
			ToolUseID      string `json:"tool_use_id"`
			Decision       string `json:"decision"`
		}
		if err := json.Unmarshal(payload, &body); err != nil {
			return
		}
		allow := body.Decision == "allow" || body.Decision == "allow_once" || body.Decision == "allow_always"
		_ = aiSvc.ResolvePermission(body.ConversationID, body.ToolUseID, allow)
	})
}

// forwardChatEvents pumps session events onto the ws `chat` channel until the
// session's Events channel closes.
func forwardChatEvents(hub *ws.Hub, sess *ai.ChatSession) {
	for evt := range sess.Events {
		hub.PublishPayload("chat", evt.Type, evt)
	}
}

func publishChatError(hub *ws.Hub, convID, code, msg string) {
	hub.PublishPayload("chat", "chat.error", map[string]any{
		"conversation_id": convID,
		"error":           code,
		"message":         msg,
	})
}
