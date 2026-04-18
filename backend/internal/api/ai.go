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
	aig.GET("/usage", stub)
	aig.GET("/context-files/:conversation_id", stub)
	aig.POST("/context-files/:conversation_id", stub)
	aig.GET("/prompts", stub)
	aig.POST("/prompts", stub)
	aig.DELETE("/prompts/:id", stub)
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
