package ai

import (
	"bufio"
	"context"
	"fmt"
	"io"
	"os/exec"
	"sync"
)

// TaskOutput is a single streamed line from a background CLI install/login task.
type TaskOutput struct {
	Line      string `json:"line"`
	Kind      string `json:"kind"` // "stdout" | "stderr" | "status"
	Completed bool   `json:"completed,omitempty"`
	ExitCode  int    `json:"exit_code,omitempty"`
	AuthURL   string `json:"auth_url,omitempty"`
	Err       string `json:"err,omitempty"`
}

// Task is a handle to a background CLI process with a streaming output channel.
type Task struct {
	ID     string
	Cmd    *exec.Cmd
	Output <-chan TaskOutput
	Cancel context.CancelFunc
	done   chan struct{}
}

// Wait blocks until the task completes.
func (t *Task) Wait() { <-t.done }

// InstallClaudeCLI launches `npm install -g @anthropic-ai/claude-code` and
// streams output. The caller owns the id and forwards TaskOutput to Flutter.
func InstallClaudeCLI(ctx context.Context, id string) (*Task, error) {
	return runStreamed(ctx, id, "npm", "install", "-g", "@anthropic-ai/claude-code")
}

// InstallGeminiCLI launches `npm install -g @google/gemini-cli`.
func InstallGeminiCLI(ctx context.Context, id string) (*Task, error) {
	return runStreamed(ctx, id, "npm", "install", "-g", "@google/gemini-cli")
}

func runStreamed(parent context.Context, id, name string, args ...string) (*Task, error) {
	ctx, cancel := context.WithCancel(parent)
	cmd := exec.CommandContext(ctx, name, args...)
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		cancel()
		return nil, fmt.Errorf("stdout: %w", err)
	}
	stderr, err := cmd.StderrPipe()
	if err != nil {
		cancel()
		return nil, fmt.Errorf("stderr: %w", err)
	}
	if err := cmd.Start(); err != nil {
		cancel()
		return nil, fmt.Errorf("start: %w", err)
	}
	out := make(chan TaskOutput, 64)
	done := make(chan struct{})
	var wg sync.WaitGroup
	wg.Add(2)
	go pumpLines(stdout, "stdout", out, &wg)
	go pumpLines(stderr, "stderr", out, &wg)
	go func() {
		wg.Wait()
		exitCode := 0
		if werr := cmd.Wait(); werr != nil {
			if ee, ok := werr.(*exec.ExitError); ok {
				exitCode = ee.ExitCode()
			} else {
				exitCode = -1
			}
		}
		out <- TaskOutput{Completed: true, ExitCode: exitCode, Kind: "status"}
		close(out)
		close(done)
	}()
	return &Task{ID: id, Cmd: cmd, Output: out, Cancel: cancel, done: done}, nil
}

func pumpLines(r io.Reader, kind string, out chan<- TaskOutput, wg *sync.WaitGroup) {
	defer wg.Done()
	scanner := bufio.NewScanner(r)
	scanner.Buffer(make([]byte, 64*1024), 1024*1024)
	for scanner.Scan() {
		out <- TaskOutput{Line: scanner.Text(), Kind: kind}
	}
}
