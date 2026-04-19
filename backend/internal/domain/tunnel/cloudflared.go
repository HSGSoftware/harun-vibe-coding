// Package tunnel manages public-URL tunnels (cloudflared primary, ngrok fallback).
package tunnel

import (
	"bufio"
	"context"
	"fmt"
	"io"
	"os/exec"
	"regexp"
	"sync"
)

// Tunnel is one active tunnel handle.
type Tunnel struct {
	ProjectID string
	URL       string
	Provider  string
	cmd       *exec.Cmd
	cancel    context.CancelFunc
}

// Service tracks tunnels per project. At most one per project at any time.
type Service struct {
	mu      sync.Mutex
	tunnels map[string]*Tunnel
	readyFn func(projectID, url string)
}

func NewService(readyFn func(projectID, url string)) *Service {
	return &Service{tunnels: map[string]*Tunnel{}, readyFn: readyFn}
}

// StartCloudflared launches `cloudflared tunnel --url http://localhost:<port>` and
// blocks on the first trycloudflare URL in stdout, returning it.
func (s *Service) StartCloudflared(ctx context.Context, projectID string, port int) (*Tunnel, error) {
	s.mu.Lock()
	if _, ok := s.tunnels[projectID]; ok {
		s.mu.Unlock()
		return nil, fmt.Errorf("tunnel already active")
	}
	s.mu.Unlock()

	runCtx, cancel := context.WithCancel(context.Background())
	cmd := exec.CommandContext(runCtx, "cloudflared", "tunnel", "--url", fmt.Sprintf("http://localhost:%d", port))
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

	urlCh := make(chan string, 1)
	go s.scanForURL(stdout, urlCh)
	go s.scanForURL(stderr, urlCh)

	go func() {
		_ = cmd.Wait()
		s.mu.Lock()
		delete(s.tunnels, projectID)
		s.mu.Unlock()
	}()

	var url string
	select {
	case url = <-urlCh:
	case <-ctx.Done():
		cancel()
		return nil, ctx.Err()
	}

	t := &Tunnel{ProjectID: projectID, URL: url, Provider: "cloudflared", cmd: cmd, cancel: cancel}
	s.mu.Lock()
	s.tunnels[projectID] = t
	s.mu.Unlock()
	if s.readyFn != nil {
		s.readyFn(projectID, url)
	}
	return t, nil
}

// Stop terminates the active tunnel for a project.
func (s *Service) Stop(projectID string) {
	s.mu.Lock()
	t, ok := s.tunnels[projectID]
	s.mu.Unlock()
	if !ok {
		return
	}
	t.cancel()
}

// Get returns the active tunnel for a project or nil.
func (s *Service) Get(projectID string) *Tunnel {
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.tunnels[projectID]
}

var cloudflareURLRe = regexp.MustCompile(`https://[^\s]+\.trycloudflare\.com`)

func (s *Service) scanForURL(r io.Reader, out chan<- string) {
	scanner := bufio.NewScanner(r)
	scanner.Buffer(make([]byte, 64*1024), 1024*1024)
	sent := false
	for scanner.Scan() {
		if sent {
			continue
		}
		if m := cloudflareURLRe.FindString(scanner.Text()); m != "" {
			out <- m
			sent = true
		}
	}
}
