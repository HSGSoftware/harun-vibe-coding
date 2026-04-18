// Package terminal owns PTY sessions. Each session exposes an input channel (stdin),
// an output channel (stdout+stderr as UTF-8 chunks), and is closed on process exit.
package terminal

import (
	"context"
	"fmt"
	"io"
	"os"
	"os/exec"
	"sync"
	"time"

	"github.com/creack/pty"
	"github.com/google/uuid"
)

// Session is a running PTY.
type Session struct {
	ID        string    `json:"id"`
	CWD       string    `json:"cwd"`
	CreatedAt time.Time `json:"created_at"`
	Alive     bool      `json:"alive"`

	cmd   *exec.Cmd
	ptmx  *os.File
	outCh chan []byte
	done  chan struct{}
}

// Write pipes data into stdin.
func (s *Session) Write(p []byte) (int, error) {
	return s.ptmx.Write(p)
}

// Output streams terminal chunks. The channel is closed when the PTY exits.
func (s *Session) Output() <-chan []byte { return s.outCh }

// Resize passes winsize to the PTY.
func (s *Session) Resize(cols, rows uint16) error {
	return pty.Setsize(s.ptmx, &pty.Winsize{Cols: cols, Rows: rows})
}

// Close terminates the process.
func (s *Session) Close() error {
	if s.cmd.Process != nil {
		_ = s.cmd.Process.Kill()
	}
	return s.ptmx.Close()
}

// Manager tracks active sessions keyed by id. Goroutine-safe.
type Manager struct {
	mu       sync.RWMutex
	sessions map[string]*Session
	onOutput func(sessionID string, data []byte)
	onExit   func(sessionID string, code int)
}

func NewManager(onOutput func(string, []byte), onExit func(string, int)) *Manager {
	return &Manager{sessions: map[string]*Session{}, onOutput: onOutput, onExit: onExit}
}

func (m *Manager) List() []*Session {
	m.mu.RLock()
	defer m.mu.RUnlock()
	out := make([]*Session, 0, len(m.sessions))
	for _, s := range m.sessions {
		out = append(out, s)
	}
	return out
}

func (m *Manager) Get(id string) *Session {
	m.mu.RLock()
	defer m.mu.RUnlock()
	return m.sessions[id]
}

// Start launches a new bash PTY under cwd with the given winsize.
func (m *Manager) Start(ctx context.Context, cwd, shell string, cols, rows uint16) (*Session, error) {
	if shell == "" {
		shell = defaultShell()
	}
	cmd := exec.Command(shell, "-l")
	cmd.Dir = cwd
	cmd.Env = append(os.Environ(), "TERM=xterm-256color")
	ptmx, err := pty.Start(cmd)
	if err != nil {
		return nil, fmt.Errorf("pty start: %w", err)
	}
	_ = pty.Setsize(ptmx, &pty.Winsize{Cols: cols, Rows: rows})

	s := &Session{
		ID:        uuid.NewString(),
		CWD:       cwd,
		CreatedAt: time.Now(),
		Alive:     true,
		cmd:       cmd,
		ptmx:      ptmx,
		outCh:     make(chan []byte, 32),
		done:      make(chan struct{}),
	}

	m.mu.Lock()
	m.sessions[s.ID] = s
	m.mu.Unlock()

	go m.pump(s)
	go func() {
		err := cmd.Wait()
		exit := 0
		if ee, ok := err.(*exec.ExitError); ok {
			exit = ee.ExitCode()
		}
		m.mu.Lock()
		delete(m.sessions, s.ID)
		s.Alive = false
		m.mu.Unlock()
		close(s.done)
		if m.onExit != nil {
			m.onExit(s.ID, exit)
		}
	}()
	return s, nil
}

// Close terminates a session by id.
func (m *Manager) Close(id string) error {
	m.mu.RLock()
	s := m.sessions[id]
	m.mu.RUnlock()
	if s == nil {
		return nil
	}
	return s.Close()
}

func (m *Manager) pump(s *Session) {
	buf := make([]byte, 4096)
	for {
		n, err := s.ptmx.Read(buf)
		if n > 0 {
			chunk := make([]byte, n)
			copy(chunk, buf[:n])
			if m.onOutput != nil {
				m.onOutput(s.ID, chunk)
			}
		}
		if err != nil {
			if err != io.EOF {
				// log elsewhere
			}
			return
		}
	}
}

func defaultShell() string {
	if sh := os.Getenv("SHELL"); sh != "" {
		return sh
	}
	return "/data/data/com.termux/files/usr/bin/bash"
}
