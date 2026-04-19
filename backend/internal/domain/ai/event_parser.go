package ai

import (
	"bufio"
	"encoding/json"
	"io"
	"strings"
)

// rawClaudeEvent matches a single line of Claude Code `--output-format stream-json`.
// The CLI prints one JSON object per line; unknown fields are preserved as raw.
type rawClaudeEvent struct {
	Type       string          `json:"type"`
	Message    json.RawMessage `json:"message,omitempty"`
	Delta      json.RawMessage `json:"delta,omitempty"`
	ContentBlock json.RawMessage `json:"content_block,omitempty"`
	PartialJSON string         `json:"partial_json,omitempty"`
	ID         string          `json:"id,omitempty"`
	Name       string          `json:"name,omitempty"`
	Input      json.RawMessage `json:"input,omitempty"`
	ToolUseID  string          `json:"tool_use_id,omitempty"`
	Output     json.RawMessage `json:"output,omitempty"`
	IsError    bool            `json:"is_error,omitempty"`
	StopReason string          `json:"stop_reason,omitempty"`
	Usage      json.RawMessage `json:"usage,omitempty"`
}

// ParseClaudeStream reads one JSON event per line and forwards translated
// events to out. Terminates when r is closed.
func ParseClaudeStream(r io.Reader, convID string, out chan<- Event) {
	scanner := bufio.NewScanner(r)
	scanner.Buffer(make([]byte, 1<<16), 1<<22)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" || !strings.HasPrefix(line, "{") {
			continue
		}
		var raw rawClaudeEvent
		if err := json.Unmarshal([]byte(line), &raw); err != nil {
			continue
		}
		evt := translateClaude(convID, raw)
		if evt.Type != "" {
			out <- evt
		}
	}
}

// translateClaude maps Claude's event vocabulary to our unified Event type.
// Only the events plan.md §6.5.1 needs are mapped — unknown types are dropped.
func translateClaude(convID string, r rawClaudeEvent) Event {
	evt := Event{ConversationID: convID}
	switch r.Type {
	case "message_start":
		evt.Type = EvtStart
	case "content_block_start":
		if strings.Contains(string(r.ContentBlock), `"type":"tool_use"`) {
			evt.Type = EvtToolCallStart
			evt.ToolUseID = r.ID
			evt.ToolName = r.Name
		}
	case "content_block_delta":
		if strings.Contains(string(r.Delta), `"text_delta"`) {
			evt.Type = EvtText
			var d struct {
				Text string `json:"text"`
			}
			_ = json.Unmarshal(r.Delta, &d)
			evt.Delta = d.Text
		} else if strings.Contains(string(r.Delta), `"thinking_delta"`) {
			evt.Type = EvtThinking
			var d struct {
				Thinking string `json:"thinking"`
			}
			_ = json.Unmarshal(r.Delta, &d)
			evt.Delta = d.Thinking
		} else if strings.Contains(string(r.Delta), `"input_json_delta"`) {
			evt.Type = EvtToolInputDelta
			var d struct {
				PartialJSON string `json:"partial_json"`
			}
			_ = json.Unmarshal(r.Delta, &d)
			evt.PartialJSON = d.PartialJSON
		}
	case "content_block_stop":
		evt.Type = EvtToolCallEnd
		evt.Input = r.Input
	case "tool_result":
		evt.Type = EvtToolResult
		evt.ToolUseID = r.ToolUseID
		evt.Output = string(r.Output)
		evt.IsError = r.IsError
	case "permission_request":
		evt.Type = EvtPermissionRequest
		evt.ToolUseID = r.ToolUseID
		evt.ToolName = r.Name
		evt.Input = r.Input
	case "message_stop", "result":
		evt.Type = EvtDone
		evt.StopReason = r.StopReason
	case "error":
		evt.Type = EvtError
		evt.Message = string(r.Output)
	}
	return evt
}
