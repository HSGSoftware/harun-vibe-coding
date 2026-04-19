package ai

import "encoding/json"

// Event is the unified chat event pushed on the WebSocket `chat` channel.
// Claude Code's `stream-json` and Gemini's structured JSON are both translated
// into this shape by event_translator.go.
type Event struct {
	Type           string          `json:"type"`
	ConversationID string          `json:"conversation_id"`
	MessageID      string          `json:"message_id,omitempty"`
	Delta          string          `json:"delta,omitempty"`
	Model          string          `json:"model,omitempty"`
	ToolUseID      string          `json:"tool_use_id,omitempty"`
	ToolName       string          `json:"tool_name,omitempty"`
	Input          json.RawMessage `json:"input,omitempty"`
	PartialJSON    string          `json:"partial_json,omitempty"`
	Output         string          `json:"output,omitempty"`
	IsError        bool            `json:"is_error,omitempty"`
	DurationMs     int64           `json:"duration_ms,omitempty"`
	StopReason     string          `json:"stop_reason,omitempty"`
	DangerLevel    string          `json:"danger_level,omitempty"`
	Preview        json.RawMessage `json:"preview,omitempty"`
	Stats          *Stats          `json:"stats,omitempty"`
	Error          string          `json:"error,omitempty"`
	Message        string          `json:"message,omitempty"`
}

// Stats mirrors plan.md §6.5.1 chat.done stats.
type Stats struct {
	InputTokens  int     `json:"input_tokens"`
	OutputTokens int     `json:"output_tokens"`
	CacheTokens  int     `json:"cache_tokens"`
	TotalCost    float64 `json:"total_cost"`
	DurationMs   int64   `json:"duration_ms"`
}

// Event type constants — mirror Flutter WsTypes.
const (
	EvtStart            = "chat.start"
	EvtThinking         = "chat.thinking"
	EvtText             = "chat.text"
	EvtToolCallStart    = "chat.tool_call_start"
	EvtToolInputDelta   = "chat.tool_input_delta"
	EvtToolCallEnd      = "chat.tool_call_end"
	EvtPermissionRequest = "chat.permission_request"
	EvtToolResult       = "chat.tool_result"
	EvtDone             = "chat.done"
	EvtError            = "chat.error"
)
