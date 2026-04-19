// Package runner manages dev-server subprocesses for a project. Each project
// gets at most one running process. Output lines are fanned out to subscribers
// over the WebSocket `events` channel via the hub.
package runner

import (
	"bufio"
	"context"
	"fmt"
	"io"
	"os/exec"
	"strings"
	"sync"
	"time"

	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/domain/project"
)

// LogEntry is a single line emitted by a running project.
type LogEntry struct {
	ProjectID string    `json:"project_id"`
	Line      string    `json:"line"`
	Stream    string    `json:"stream"`
	Timestamp time.Time `json:"timestamp"`
}

// processHandle tracks one running project.
type processHandle struct {
	project project.Project
	cmd     *exec.Cmd
	cancel  context.CancelFunc
	status  string
	port    int
	started time.Time
	logs    []string // ring buffer of recent lines for quick GET /logs
}

// Sink receives a single project log line. Typically wired to the WS hub.
type Sink func(LogEntry)

// StatusSink is called when a project status transitions (starting -> running -> stopped).
type StatusSink func(projectID, status string, port int)

// Runner is the package's single entry point. Safe for concurrent use.
type Runner struct {
	mu       sync.RWMutex
	handles  map[string]*processHandle
	logSink  Sink
	statSink StatusSink
}

func New(logSink Sink, statSink StatusSink) *Runner {
	return &Runner{handles: map[string]*processHandle{}, logSink: logSink, statSink: statSink}
}

// Running returns a list of project ids currently running.
func (r *Runner) Running() []string {
	r.mu.RLock()
	defer r.mu.RUnlock()
	out := make([]string, 0, len(r.handles))
	for id := range r.handles {
		out = append(out, id)
	}
	return out
}

// Status returns the runtime status + port for a project, or ("stopped", 0).
func (r *Runner) Status(id string) (string, int) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	if h, ok := r.handles[id]; ok {
		return h.status, h.port
	}
	return project.StatusStopped, 0
}

// Tail returns up to `n` recent log lines in chronological order.
func (r *Runner) Tail(id string, n int) []string {
	r.mu.RLock()
	defer r.mu.RUnlock()
	h, ok := r.handles[id]
	if !ok {
		return nil
	}
	if n <= 0 || n >= len(h.logs) {
		out := make([]string, len(h.logs))
		copy(out, h.logs)
		return out
	}
	return append([]string(nil), h.logs[len(h.logs)-n:]...)
}

// Start launches the project's entry command. Returns an error if already running.
func (r *Runner) Start(ctx context.Context, p project.Project) error {
	r.mu.Lock()
	if _, ok := r.handles[p.ID]; ok {
		r.mu.Unlock()
		return fmt.Errorf("already running")
	}
	r.mu.Unlock()

	entry := p.EntryCmd
	if strings.TrimSpace(entry) == "" {
		return fmt.Errorf("no entry command configured")
	}

	runCtx, cancel := context.WithCancel(context.Background())
	cmd := exec.CommandContext(runCtx, "sh", "-lc", entry)
	cmd.Dir = p.Path

	stdout, err := cmd.StdoutPipe()
	if err != nil {
		cancel()
		return fmt.Errorf("stdout: %w", err)
	}
	stderr, err := cmd.StderrPipe()
	if err != nil {
		cancel()
		return fmt.Errorf("stderr: %w", err)
	}
	if err := cmd.Start(); err != nil {
		cancel()
		return fmt.Errorf("start: %w", err)
	}

	h := &processHandle{
		project: p,
		cmd:     cmd,
		cancel:  cancel,
		status:  project.StatusStarting,
		port:    p.Port,
		started: time.Now(),
		logs:    make([]string, 0, 512),
	}
	r.mu.Lock()
	r.handles[p.ID] = h
	r.mu.Unlock()
	r.emitStatus(p.ID, project.StatusStarting, p.Port)

	var wg sync.WaitGroup
	wg.Add(2)
	go r.pump(p.ID, stdout, "stdout", &wg)
	go r.pump(p.ID, stderr, "stderr", &wg)

	go func() {
		wg.Wait()
		_ = cmd.Wait()
		r.mu.Lock()
		delete(r.handles, p.ID)
		r.mu.Unlock()
		r.emitStatus(p.ID, project.StatusStopped, 0)
	}()
	return nil
}

// Stop terminates a running project. Returns nil if not running.
func (r *Runner) Stop(id string) error {
	r.mu.Lock()
	h, ok := r.handles[id]
	r.mu.Unlock()
	if !ok {
		return nil
	}
	h.cancel()
	return nil
}

// Restart stops + starts a project.
func (r *Runner) Restart(ctx context.Context, p project.Project) error {
	_ = r.Stop(p.ID)
	time.Sleep(300 * time.Millisecond)
	return r.Start(ctx, p)
}

// Write pipes stdin to a running project (§5.3 POST /projects/:id/input).
func (r *Runner) Write(id, text string) error {
	r.mu.RLock()
	h, ok := r.handles[id]
	r.mu.RUnlock()
	if !ok {
		return fmt.Errorf("not running")
	}
	if h.cmd.Stdin == nil {
		return fmt.Errorf("stdin unavailable")
	}
	_, err := io.WriteString(h.cmd.Stdin.(io.Writer), text)
	return err
}

func (r *Runner) pump(id string, reader io.Reader, stream string, wg *sync.WaitGroup) {
	defer wg.Done()
	scanner := bufio.NewScanner(reader)
	scanner.Buffer(make([]byte, 64*1024), 1024*1024)
	for scanner.Scan() {
		line := scanner.Text()
		r.mu.Lock()
		if h, ok := r.handles[id]; ok {
			h.logs = append(h.logs, line)
			if len(h.logs) > 500 {
				h.logs = h.logs[len(h.logs)-500:]
			}
			if h.status == project.StatusStarting && looksReady(line) {
				h.status = project.StatusRunning
				r.statSink(id, project.StatusRunning, h.port)
			}
		}
		r.mu.Unlock()
		if r.logSink != nil {
			r.logSink(LogEntry{ProjectID: id, Line: line, Stream: stream, Timestamp: time.Now()})
		}
	}
}

func (r *Runner) emitStatus(id, status string, port int) {
	if r.statSink != nil {
		r.statSink(id, status, port)
	}
}

// looksReady is a very conservative heuristic per env. Flutter, Vite, Next,
// Django all print a recognizable marker; everything else stays "starting" until
// it prints output for a few seconds. Good enough for personal use.
func looksReady(line string) bool {
	lower := strings.ToLower(line)
	for _, marker := range []string{
		"ready in", "compiled successfully", "running on", "listening on",
		"development server", "local:", "flutter run key commands", "server started",
	} {
		if strings.Contains(lower, marker) {
			return true
		}
	}
	return false
}
