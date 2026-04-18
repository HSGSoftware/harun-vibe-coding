package storage

import (
	"context"
	"fmt"
	"time"
)

// Prompt mirrors the `prompts` table. Tags are a comma-separated string for simplicity.
type Prompt struct {
	ID        string
	Title     string
	Content   string
	Tags      string
	CreatedAt time.Time
	UpdatedAt time.Time
}

type PromptsRepo struct{ db *DB }

func NewPromptsRepo(db *DB) *PromptsRepo { return &PromptsRepo{db: db} }

func (r *PromptsRepo) List(ctx context.Context) ([]Prompt, error) {
	rows, err := r.db.QueryContext(ctx, `SELECT id, title, content, tags, created_at, updated_at FROM prompts ORDER BY updated_at DESC`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]Prompt, 0)
	for rows.Next() {
		p, err := scanPrompt(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, *p)
	}
	return out, rows.Err()
}

func (r *PromptsRepo) Insert(ctx context.Context, p Prompt) error {
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO prompts(id, title, content, tags, created_at, updated_at)
		VALUES (?,?,?,?,?,?)
	`, p.ID, p.Title, p.Content, p.Tags, p.CreatedAt.UnixMilli(), p.UpdatedAt.UnixMilli())
	if err != nil {
		return fmt.Errorf("insert prompt: %w", err)
	}
	return nil
}

func (r *PromptsRepo) Delete(ctx context.Context, id string) error {
	_, err := r.db.ExecContext(ctx, `DELETE FROM prompts WHERE id = ?`, id)
	return err
}

func scanPrompt(s scanner) (*Prompt, error) {
	var (
		p         Prompt
		createdAt int64
		updatedAt int64
	)
	err := s.Scan(&p.ID, &p.Title, &p.Content, &p.Tags, &createdAt, &updatedAt)
	if err != nil {
		return nil, err
	}
	p.CreatedAt = time.UnixMilli(createdAt)
	p.UpdatedAt = time.UnixMilli(updatedAt)
	return &p, nil
}
