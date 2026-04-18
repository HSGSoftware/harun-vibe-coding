package api

import "github.com/gin-gonic/gin"

// RegisterAI mounts /conversations/* and /ai/* endpoints. Faz 5–6 fill these in.
// Message send + stream happens over WebSocket, not REST (see ws package).
func RegisterAI(r *gin.RouterGroup, d Deps) {
	cg := r.Group("/conversations")
	cg.GET("", stub)
	cg.GET("/:id", stub)
	cg.POST("", stub)
	cg.PATCH("/:id", stub)
	cg.DELETE("/:id", stub)
	cg.POST("/:id/branch", stub)
	cg.POST("/:id/summarize", stub)
	cg.GET("/:id/export/markdown", stub)
	cg.POST("/:id/fork-to", stub)

	ai := r.Group("/ai")
	ai.GET("/tools", stub)
	ai.GET("/permissions", stub)
	ai.POST("/permissions", stub)
	ai.DELETE("/permissions/:id", stub)
	ai.POST("/permissions/reset", stub)
	ai.GET("/usage", stub)
	ai.GET("/context-files/:conversation_id", stub)
	ai.POST("/context-files/:conversation_id", stub)
	ai.GET("/prompts", stub)
	ai.POST("/prompts", stub)
	ai.DELETE("/prompts/:id", stub)

	ai.POST("/analyze-error", stub)
	ai.POST("/explain-code", stub)
	ai.POST("/generate-commit-message", stub)
	ai.POST("/review-diff", stub)
	ai.POST("/suggest-project-setup", stub)
	ai.POST("/speech-to-text", stub)
}
