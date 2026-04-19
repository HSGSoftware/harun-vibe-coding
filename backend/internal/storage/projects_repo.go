package storage

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/domain/project"
)

// ProjectsRepo persists Project entities. Runtime fields (Status, RunningPort,
// TunnelURL) are never stored here — they're computed by the runner/tunnel
// services and merged at read time by the api package.
type ProjectsRepo struct{ db *DB }

func NewProjectsRepo(db *DB) *ProjectsRepo { return &ProjectsRepo{db: db} }

func (r *ProjectsRepo) Insert(ctx context.Context, p project.Project) error {
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO projects(id,name,path,env,port,entry_cmd,source,git_repo,git_branch,proj_group,favorite,last_opened,created_at)
		VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)
	`, p.ID, p.Name, p.Path, p.Env, p.Port, p.EntryCmd, p.Source, p.GitRepo, p.GitBranch, p.Group,
		boolToInt(p.Favorite), p.LastOpened.UnixMilli(), p.CreatedAt.UnixMilli())
	if err != nil {
		return fmt.Errorf("insert: %w", err)
	}
	return nil
}

func (r *ProjectsRepo) Get(ctx context.Context, id string) (*project.Project, error) {
	row := r.db.QueryRowContext(ctx, `SELECT id,name,path,env,port,entry_cmd,source,git_repo,git_branch,proj_group,favorite,last_opened,created_at FROM projects WHERE id = ?`, id)
	return scanProject(row)
}

func (r *ProjectsRepo) List(ctx context.Context) ([]project.Project, error) {
	rows, err := r.db.QueryContext(ctx, `SELECT id,name,path,env,port,entry_cmd,source,git_repo,git_branch,proj_group,favorite,last_opened,created_at FROM projects ORDER BY last_opened DESC, created_at DESC`)
	if err != nil {
		return nil, fmt.Errorf("list: %w", err)
	}
	defer rows.Close()
	out := make([]project.Project, 0)
	for rows.Next() {
		p, err := scanProject(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, *p)
	}
	return out, rows.Err()
}

func (r *ProjectsRepo) Update(ctx context.Context, p project.Project) error {
	_, err := r.db.ExecContext(ctx, `
		UPDATE projects SET name=?, path=?, env=?, port=?, entry_cmd=?, proj_group=?, favorite=?, last_opened=?
		WHERE id = ?`,
		p.Name, p.Path, p.Env, p.Port, p.EntryCmd, p.Group, boolToInt(p.Favorite), p.LastOpened.UnixMilli(), p.ID)
	if err != nil {
		return fmt.Errorf("update: %w", err)
	}
	return nil
}

func (r *ProjectsRepo) Delete(ctx context.Context, id string) error {
	_, err := r.db.ExecContext(ctx, `DELETE FROM projects WHERE id = ?`, id)
	return err
}

// scanner accepts both *sql.Row and *sql.Rows because Go doesn't share a scanner interface.
type scanner interface {
	Scan(dest ...any) error
}

func scanProject(s scanner) (*project.Project, error) {
	var (
		p                                   project.Project
		favorite                            int
		lastOpened, createdAt               int64
		gitRepo, gitBranch, group, entryCmd sql.NullString
	)
	err := s.Scan(&p.ID, &p.Name, &p.Path, &p.Env, &p.Port, &entryCmd, &p.Source, &gitRepo, &gitBranch, &group, &favorite, &lastOpened, &createdAt)
	if err != nil {
		return nil, err
	}
	p.EntryCmd = entryCmd.String
	p.GitRepo = gitRepo.String
	p.GitBranch = gitBranch.String
	p.Group = group.String
	p.Favorite = favorite != 0
	p.LastOpened = time.UnixMilli(lastOpened)
	p.CreatedAt = time.UnixMilli(createdAt)
	return &p, nil
}

func boolToInt(b bool) int {
	if b {
		return 1
	}
	return 0
}
