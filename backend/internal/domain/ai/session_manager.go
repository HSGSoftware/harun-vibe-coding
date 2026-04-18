package ai

import (
	"context"
	"fmt"
	"io"
	"os"
	"os/exec"
	"sync"

	"github.com/creack/pty"
	"github.com/google/uuid"
)

// ChatSession represents a single long-lived CLI subprocess (claude or gemini)
// attached to one Flutter conversation.
type ChatSession struct {
	ID             string
	ConversationID string
	Provider       string
	Model          string
	Cmd            *exec.Cmd
	Ptmx           *os.File
	Stdin          io.Writer
	Events         chan Event
	// permissionResponses is closed when a decision arrives for a given tool_use_id.
	permissionMu     sync.Mutex
	permissionPending map[string]chan bool
	cancel           context.CancelFunc
}

// SessionManager tracks running CLI processes keyed by conversation id.
type SessionManager struct {
	mu       sync.RWMutex
	sessions map[string]*ChatSession
}

func NewSessionManager() *SessionManager {
	return &SessionManager{sessions: map[string]*ChatSession{}}
}

// Get returns the active session for a conversation (nil if none).
func (m *SessionManager) Get(convID string) *ChatSession {
	m.mu.RLock()
	defer m.mu.RUnlock()
	return m.sessions[convID]
}

// Remove drops a session from the registry and closes its PTY.
func (m *SessionManager) Remove(convID string) {
	m.mu.Lock()
	s := m.sessions[convID]
	delete(m.sessions, convID)
	m.mu.Unlock()
	if s != nil {
		s.cancel()
		_ = s.Ptmx.Close()
	}
}

// StartClaude boots a Claude Code CLI subprocess in stream-json mode.
// The CLI reads JSON events from stdin and writes JSON events to stdout.
// See plan.md §11.0.1 for the exact CLI flags.
func (m *SessionManager) StartClaude(parent context.Context, bin, convID, model, projectDir string) (*ChatSession, error) {
	return m.startPTY(parent, "claude", convID, model, bin, []string{
		"--print",
		"--output-format", "stream-json",
		"--input-format", "stream-json",
		"--model", model,
		"--permission-mode", "plan",
		"--add-dir", projectDir,
		"--session-id", convID,
	})
}

// StartGemini boots a Gemini CLI subprocess.
func (m *SessionManager) StartGemini(parent context.Context, bin, convID, model, projectDir string) (*ChatSession, error) {
	return m.startPTY(parent, "gemini", convID, model, bin, []string{
		"--output-format", "json",
		"--model", model,
		"--yolo=false",
		"--checkpointing",
		"--session-resume", convID,
		"--include-directories", projectDir,
	})
}

func (m *SessionManager) startPTY(parent context.Context, provider, convID, model, bin string, args []string) (*ChatSession, error) {
	ctx, cancel := context.WithCancel(parent)
	cmd := exec.CommandContext(ctx, bin, args...)
	ptmx, err := pty.Start(cmd)
	if err != nil {
		cancel()
		return nil, fmt.Errorf("pty start: %w", err)
	}
	s := &ChatSession{
		ID:                uuid.NewString(),
		ConversationID:    convID,
		Provider:          provider,
		Model:             model,
		Cmd:               cmd,
		Ptmx:              ptmx,
		Stdin:             ptmx,
		Events:            make(chan Event, 64),
		permissionPending: map[string]chan bool{},
		cancel:            cancel,
	}
	m.mu.Lock()
	m.sessions[convID] = s
	m.mu.Unlock()
	return s, nil
}

// AwaitPermission registers a waiter for the given tool_use_id. The call blocks
// until ResolvePermission is invoked for the same id (or ctx is cancelled).
func (s *ChatSession) AwaitPermission(ctx context.Context, toolUseID string) bool {
	ch := make(chan bool, 1)
	s.permissionMu.Lock()
	s.permissionPending[toolUseID] = ch
	s.permissionMu.Unlock()
	select {
	case v := <-ch:
		return v
	case <-ctx.Done():
		return false
	}
}

// ResolvePermission delivers the Flutter decision to a waiting tool_use_id.
func (s *ChatSession) ResolvePermission(toolUseID string, allow bool) {
	s.permissionMu.Lock()
	ch, ok := s.permissionPending[toolUseID]
	delete(s.permissionPending, toolUseID)
	s.permissionMu.Unlock()
	if ok {
		ch <- allow
		close(ch)
	}
}
