// Package backup creates / lists / restores project snapshots.
// Three layers per plan.md §12: local zip, git checkpoint, optional cloud.
package backup

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"time"

	"github.com/google/uuid"

	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/domain/git"
	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/util"
)

// Backup is the row shape (mirrors §4.3 Backup struct).
type Backup struct {
	ID         string    `json:"id"`
	ProjectID  string    `json:"project_id"`
	Type       string    `json:"type"`
	CreatedAt  time.Time `json:"created_at"`
	SizeBytes  int64     `json:"size_bytes"`
	Path       string    `json:"path,omitempty"`
	CommitHash string    `json:"commit_hash,omitempty"`
	Trigger    string    `json:"trigger"`
	Note       string    `json:"note,omitempty"`
}

// Repo is the persistence subset that Service depends on.
type Repo interface {
	Insert(ctx context.Context, b Backup) error
	List(ctx context.Context, projectID string) ([]Backup, error)
	Get(ctx context.Context, id string) (*Backup, error)
	Delete(ctx context.Context, id string) error
}

// Service orchestrates local zip + git checkpoint backups.
type Service struct {
	repo       Repo
	backupsDir string
}

func NewService(repo Repo, backupsDir string) *Service {
	return &Service{repo: repo, backupsDir: backupsDir}
}

// CreateLocalZip zips the project dir into backupsDir/<project>/<id>.zip.
func (s *Service) CreateLocalZip(ctx context.Context, projectID, projectPath, trigger, note string) (*Backup, error) {
	dir := filepath.Join(s.backupsDir, projectID)
	if err := os.MkdirAll(dir, 0o755); err != nil {
		return nil, fmt.Errorf("mkdir: %w", err)
	}
	id := uuid.NewString()
	out := filepath.Join(dir, fmt.Sprintf("%s.zip", id))
	if err := util.ZipDir(projectPath, out, []string{".git", "node_modules", "build", "dist", ".dart_tool"}); err != nil {
		return nil, err
	}
	info, _ := os.Stat(out)
	b := Backup{
		ID:        id,
		ProjectID: projectID,
		Type:      "local_zip",
		CreatedAt: time.Now(),
		SizeBytes: info.Size(),
		Path:      out,
		Trigger:   trigger,
		Note:      note,
	}
	if err := s.repo.Insert(ctx, b); err != nil {
		_ = os.Remove(out)
		return nil, err
	}
	return &b, nil
}

// CreateGitCheckpoint runs `git commit -m "[checkpoint] note"` in projectPath.
func (s *Service) CreateGitCheckpoint(ctx context.Context, projectID, projectPath, note string) (*Backup, error) {
	hash, err := git.Checkpoint(projectPath, note)
	if err != nil {
		return nil, err
	}
	b := Backup{
		ID:         uuid.NewString(),
		ProjectID:  projectID,
		Type:       "git_checkpoint",
		CreatedAt:  time.Now(),
		CommitHash: hash,
		Trigger:    "manual",
		Note:       note,
	}
	if err := s.repo.Insert(ctx, b); err != nil {
		return nil, err
	}
	return &b, nil
}

func (s *Service) List(ctx context.Context, projectID string) ([]Backup, error) {
	return s.repo.List(ctx, projectID)
}

func (s *Service) Get(ctx context.Context, id string) (*Backup, error) {
	return s.repo.Get(ctx, id)
}

func (s *Service) Delete(ctx context.Context, id string) error {
	b, err := s.repo.Get(ctx, id)
	if err != nil {
		return err
	}
	if b == nil {
		return nil
	}
	if b.Path != "" {
		_ = os.Remove(b.Path)
	}
	return s.repo.Delete(ctx, id)
}
