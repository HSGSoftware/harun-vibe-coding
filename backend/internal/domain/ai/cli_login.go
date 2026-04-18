package ai

import (
	"bufio"
	"context"
	"fmt"
	"io"
	"os/exec"
	"regexp"
	"sync"

	"github.com/creack/pty"
)

// authURLRe matches Claude / Google auth URLs in CLI stdout.
var authURLRe = regexp.MustCompile(`https?://\S+(?:login|auth|oauth)\S*`)

// LoginClaudeCLI runs `claude login` under a PTY, extracting the first auth URL
// it prints and emitting it as a TaskOutput with AuthURL set.
func LoginClaudeCLI(parent context.Context, id, bin string) (*Task, error) {
	return runPTY(parent, id, bin, "login")
}

// LoginGeminiCLI runs `gemini auth login` under a PTY.
func LoginGeminiCLI(parent context.Context, id, bin string) (*Task, error) {
	return runPTY(parent, id, bin, "auth", "login")
}

// LogoutClaudeCLI runs `claude logout` synchronously.
func LogoutClaudeCLI(ctx context.Context, bin string) error {
	c, cancel := contextWithTimeout(ctx, 10)
	defer cancel()
	return exec.CommandContext(c, bin, "logout").Run()
}

// LogoutGeminiCLI runs `gemini auth logout` synchronously.
func LogoutGeminiCLI(ctx context.Context, bin string) error {
	c, cancel := contextWithTimeout(ctx, 10)
	defer cancel()
	return exec.CommandContext(c, bin, "auth", "logout").Run()
}

func runPTY(parent context.Context, id, name string, args ...string) (*Task, error) {
	ctx, cancel := context.WithCancel(parent)
	cmd := exec.CommandContext(ctx, name, args...)
	ptmx, err := pty.Start(cmd)
	if err != nil {
		cancel()
		return nil, fmt.Errorf("pty start: %w", err)
	}
	out := make(chan TaskOutput, 64)
	done := make(chan struct{})
	var wg sync.WaitGroup
	wg.Add(1)
	go pumpPTY(ptmx, out, &wg)
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
		_ = ptmx.Close()
		out <- TaskOutput{Completed: true, ExitCode: exitCode, Kind: "status"}
		close(out)
		close(done)
	}()
	return &Task{ID: id, Cmd: cmd, Output: out, Cancel: cancel, done: done}, nil
}

func pumpPTY(r io.Reader, out chan<- TaskOutput, wg *sync.WaitGroup) {
	defer wg.Done()
	scanner := bufio.NewScanner(r)
	scanner.Buffer(make([]byte, 64*1024), 1024*1024)
	sentAuth := false
	for scanner.Scan() {
		line := scanner.Text()
		event := TaskOutput{Line: line, Kind: "stdout"}
		if !sentAuth {
			if m := authURLRe.FindString(line); m != "" {
				event.AuthURL = m
				sentAuth = true
			}
		}
		out <- event
	}
}
