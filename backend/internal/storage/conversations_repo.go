package storage

import (
	"context"
	"database/sql"
	"fmt"
	"time"
)

// Conversation is the row shape of the `conversations` table.
type Conversation struct {
	ID        string
	ProjectID string
	Provider  string
	Model     string
	Title     string
	Archived  bool
	CreatedAt time.Time
	UpdatedAt time.Time
}

type ConversationsRepo struct{ db *DB }

func NewConversationsRepo(db *DB) *ConversationsRepo { return &ConversationsRepo{db: db} }

func (r *ConversationsRepo) Insert(ctx context.Context, c Conversation) error {
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO conversations(id, project_id, provider, model, title, archived, created_at, updated_at, stats_json)
		VALUES (?,?,?,?,?,?,?,?, '{}')
	`, c.ID, c.ProjectID, c.Provider, c.Model, c.Title, boolToInt(c.Archived),
		c.CreatedAt.UnixMilli(), c.UpdatedAt.UnixMilli())
	if err != nil {
		return fmt.Errorf("insert conversation: %w", err)
	}
	return nil
}

func (r *ConversationsRepo) Touch(ctx context.Context, id string) {
	_, _ = r.db.ExecContext(ctx, `UPDATE conversations SET updated_at = ? WHERE id = ?`,
		time.Now().UnixMilli(), id)
}

func (r *ConversationsRepo) Get(ctx context.Context, id string) (*Conversation, error) {
	row := r.db.QueryRowContext(ctx, `SELECT id, project_id, provider, model, title, archived, created_at, updated_at FROM conversations WHERE id = ?`, id)
	return scanConversation(row)
}

func (r *ConversationsRepo) List(ctx context.Context, projectID string, limit int) ([]Conversation, error) {
	if limit <= 0 {
		limit = 50
	}
	var rows *sql.Rows
	var err error
	if projectID == "" {
		rows, err = r.db.QueryContext(ctx,
			`SELECT id, project_id, provider, model, title, archived, created_at, updated_at FROM conversations ORDER BY updated_at DESC LIMIT ?`,
			limit)
	} else {
		rows, err = r.db.QueryContext(ctx,
			`SELECT id, project_id, provider, model, title, archived, created_at, updated_at FROM conversations WHERE project_id = ? ORDER BY updated_at DESC LIMIT ?`,
			projectID, limit)
	}
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]Conversation, 0)
	for rows.Next() {
		c, err := scanConversation(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, *c)
	}
	return out, rows.Err()
}

func (r *ConversationsRepo) Delete(ctx context.Context, id string) error {
	_, err := r.db.ExecContext(ctx, `DELETE FROM conversations WHERE id = ?`, id)
	return err
}

func (r *ConversationsRepo) UpdateTitle(ctx context.Context, id, title string) error {
	_, err := r.db.ExecContext(ctx, `UPDATE conversations SET title = ?, updated_at = ? WHERE id = ?`, title, time.Now().UnixMilli(), id)
	return err
}

func scanConversation(s scanner) (*Conversation, error) {
	var (
		c          Conversation
		archived   int
		createdAt  int64
		updatedAt  int64
	)
	err := s.Scan(&c.ID, &c.ProjectID, &c.Provider, &c.Model, &c.Title, &archived, &createdAt, &updatedAt)
	if err != nil {
		return nil, err
	}
	c.Archived = archived != 0
	c.CreatedAt = time.UnixMilli(createdAt)
	c.UpdatedAt = time.UnixMilli(updatedAt)
	return &c, nil
}
