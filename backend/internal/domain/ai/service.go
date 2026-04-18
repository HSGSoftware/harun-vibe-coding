package ai

import (
	"context"
	"encoding/json"
	"fmt"
	"os/exec"
)

// ChatRequest is the input to Service.Chat.
type ChatRequest struct {
	ConversationID string
	Provider       string
	Model          string
	Text           string
	ProjectDir     string
	ContextFiles   []string
	Images         []string
}

// Service is the unified CLI-subprocess entry point. It creates sessions lazily
// per conversation id and pipes user messages over stdin as stream-json.
type Service struct {
	Manager *SessionManager
}

func NewService() *Service { return &Service{Manager: NewSessionManager()} }

// Chat starts (or re-uses) a session and sends the user message.
// Events are delivered on the session's Events channel; callers forward them to
// the WebSocket hub.
func (s *Service) Chat(ctx context.Context, req ChatRequest) (*ChatSession, error) {
	sess := s.Manager.Get(req.ConversationID)
	if sess == nil {
		bin, err := exec.LookPath(req.Provider)
		if err != nil {
			return nil, fmt.Errorf("%s CLI not found", req.Provider)
		}
		switch req.Provider {
		case "claude":
			sess, err = s.Manager.StartClaude(ctx, bin, req.ConversationID, req.Model, req.ProjectDir)
		case "gemini":
			sess, err = s.Manager.StartGemini(ctx, bin, req.ConversationID, req.Model, req.ProjectDir)
		default:
			return nil, fmt.Errorf("unknown provider %q", req.Provider)
		}
		if err != nil {
			return nil, err
		}
		go ParseClaudeStream(sess.Ptmx, req.ConversationID, sess.Events)
	}

	// stream-json expects one envelope per user turn.
	userMsg := map[string]any{
		"type":    "user",
		"message": map[string]any{"role": "user", "content": req.Text},
	}
	raw, err := json.Marshal(userMsg)
	if err != nil {
		return sess, err
	}
	raw = append(raw, '\n')
	if _, err := sess.Stdin.Write(raw); err != nil {
		return sess, fmt.Errorf("stdin write: %w", err)
	}
	return sess, nil
}

// Abort stops the active session for a conversation.
func (s *Service) Abort(convID string) {
	s.Manager.Remove(convID)
}

// ResolvePermission forwards the Flutter tool decision to the backing CLI.
// Writes a `permission_response` envelope to stdin AND unblocks any internal
// waiter (future enforce-in-process flows).
func (s *Service) ResolvePermission(convID, toolUseID string, allow bool) error {
	sess := s.Manager.Get(convID)
	if sess == nil {
		return fmt.Errorf("no active session")
	}
	sess.ResolvePermission(toolUseID, allow)
	payload := map[string]any{
		"type":        "permission_response",
		"tool_use_id": toolUseID,
		"allow":       allow,
	}
	raw, _ := json.Marshal(payload)
	raw = append(raw, '\n')
	_, err := sess.Stdin.Write(raw)
	return err
}
