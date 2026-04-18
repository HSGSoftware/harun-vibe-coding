package project

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"time"

	"github.com/google/uuid"
)

// Service creates/manages Project entities on disk. Persistence is delegated to
// a Repo interface so the api layer can stay thin.
type Service struct {
	repo        Repo
	projectsDir string
}

// Repo is the subset of storage.ProjectsRepo that Service needs. Keeps tests easy.
type Repo interface {
	Insert(ctx context.Context, p Project) error
	Get(ctx context.Context, id string) (*Project, error)
	List(ctx context.Context) ([]Project, error)
	Update(ctx context.Context, p Project) error
	Delete(ctx context.Context, id string) error
}

func NewService(repo Repo, projectsDir string) *Service {
	return &Service{repo: repo, projectsDir: projectsDir}
}

// CreateEmpty scaffolds an empty project directory + DB row.
func (s *Service) CreateEmpty(ctx context.Context, name, env string, port int) (*Project, error) {
	id := uuid.NewString()
	path := filepath.Join(s.projectsDir, sanitizeName(name))
	if err := os.MkdirAll(path, 0o755); err != nil {
		return nil, fmt.Errorf("mkdir project: %w", err)
	}
	detected := env
	if detected == "" {
		detected = DetectEnv(path)
	}
	p := Project{
		ID:         id,
		Name:       name,
		Path:       path,
		Env:        detected,
		Port:       port,
		EntryCmd:   DefaultEntryCmd(detected),
		Source:     "empty",
		CreatedAt:  time.Now(),
		LastOpened: time.Now(),
	}
	if err := s.repo.Insert(ctx, p); err != nil {
		return nil, fmt.Errorf("persist: %w", err)
	}
	return &p, nil
}

// List returns every stored project; runtime fields (Status, RunningPort, TunnelURL)
// are filled in by the api layer using the runner+tunnel services.
func (s *Service) List(ctx context.Context) ([]Project, error) {
	return s.repo.List(ctx)
}

// Get returns a single project.
func (s *Service) Get(ctx context.Context, id string) (*Project, error) {
	return s.repo.Get(ctx, id)
}

// Delete removes the DB row. If keepFiles is false the on-disk directory is
// also removed — callers should confirm with the user first.
func (s *Service) Delete(ctx context.Context, id string, keepFiles bool) error {
	p, err := s.repo.Get(ctx, id)
	if err != nil {
		return err
	}
	if p == nil {
		return nil
	}
	if !keepFiles {
		if err := os.RemoveAll(p.Path); err != nil {
			return fmt.Errorf("rm path: %w", err)
		}
	}
	return s.repo.Delete(ctx, id)
}

// Update applies a partial patch. Non-empty string fields / non-zero ints override.
func (s *Service) Update(ctx context.Context, id string, patch Project) (*Project, error) {
	p, err := s.repo.Get(ctx, id)
	if err != nil {
		return nil, err
	}
	if p == nil {
		return nil, fmt.Errorf("not found")
	}
	if patch.Name != "" {
		p.Name = patch.Name
	}
	if patch.Env != "" {
		p.Env = patch.Env
	}
	if patch.Port != 0 {
		p.Port = patch.Port
	}
	if patch.EntryCmd != "" {
		p.EntryCmd = patch.EntryCmd
	}
	if patch.Group != "" {
		p.Group = patch.Group
	}
	p.Favorite = patch.Favorite || p.Favorite
	if err := s.repo.Update(ctx, *p); err != nil {
		return nil, err
	}
	return p, nil
}

// Touch updates last_opened to now.
func (s *Service) Touch(ctx context.Context, id string) error {
	p, err := s.repo.Get(ctx, id)
	if err != nil || p == nil {
		return err
	}
	p.LastOpened = time.Now()
	return s.repo.Update(ctx, *p)
}

// sanitizeName produces a directory-safe name. Keep ASCII-only for Termux paths.
func sanitizeName(name string) string {
	out := make([]rune, 0, len(name))
	for _, r := range name {
		switch {
		case r >= 'a' && r <= 'z', r >= 'A' && r <= 'Z', r >= '0' && r <= '9', r == '-', r == '_':
			out = append(out, r)
		case r == ' ':
			out = append(out, '-')
		}
	}
	if len(out) == 0 {
		return uuid.NewString()
	}
	return string(out)
}
