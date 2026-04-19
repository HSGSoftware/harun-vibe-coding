package storage

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/domain/backup"
)

type BackupsRepo struct{ db *DB }

func NewBackupsRepo(db *DB) *BackupsRepo { return &BackupsRepo{db: db} }

func (r *BackupsRepo) Insert(ctx context.Context, b backup.Backup) error {
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO backups(id, project_id, type, created_at, size_bytes, path, cloud_url, commit_hash, trigger, note)
		VALUES (?,?,?,?,?,?,?,?,?,?)
	`, b.ID, b.ProjectID, b.Type, b.CreatedAt.UnixMilli(), b.SizeBytes, b.Path, "", b.CommitHash, b.Trigger, b.Note)
	if err != nil {
		return fmt.Errorf("insert backup: %w", err)
	}
	return nil
}

func (r *BackupsRepo) List(ctx context.Context, projectID string) ([]backup.Backup, error) {
	var rows *sql.Rows
	var err error
	if projectID == "" {
		rows, err = r.db.QueryContext(ctx, `SELECT id, project_id, type, created_at, size_bytes, path, commit_hash, trigger, note FROM backups ORDER BY created_at DESC`)
	} else {
		rows, err = r.db.QueryContext(ctx, `SELECT id, project_id, type, created_at, size_bytes, path, commit_hash, trigger, note FROM backups WHERE project_id = ? ORDER BY created_at DESC`, projectID)
	}
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]backup.Backup, 0)
	for rows.Next() {
		b, err := scanBackup(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, *b)
	}
	return out, rows.Err()
}

func (r *BackupsRepo) Get(ctx context.Context, id string) (*backup.Backup, error) {
	row := r.db.QueryRowContext(ctx, `SELECT id, project_id, type, created_at, size_bytes, path, commit_hash, trigger, note FROM backups WHERE id = ?`, id)
	return scanBackup(row)
}

func (r *BackupsRepo) Delete(ctx context.Context, id string) error {
	_, err := r.db.ExecContext(ctx, `DELETE FROM backups WHERE id = ?`, id)
	return err
}

func scanBackup(s scanner) (*backup.Backup, error) {
	var (
		b         backup.Backup
		createdAt int64
	)
	err := s.Scan(&b.ID, &b.ProjectID, &b.Type, &createdAt, &b.SizeBytes, &b.Path, &b.CommitHash, &b.Trigger, &b.Note)
	if err != nil {
		return nil, err
	}
	b.CreatedAt = time.UnixMilli(createdAt)
	return &b, nil
}
