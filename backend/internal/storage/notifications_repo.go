package storage

import (
	"context"
	"encoding/json"
	"time"

	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/notifications"
)

type NotificationsRepo struct{ db *DB }

func NewNotificationsRepo(db *DB) *NotificationsRepo { return &NotificationsRepo{db: db} }

func (r *NotificationsRepo) Insert(ctx context.Context, n notifications.Notification) error {
	actions, _ := json.Marshal(n.Actions)
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO notifications(id, category, title, body, importance, deep_link, actions, read, created_at)
		VALUES (?,?,?,?,?,?,?,?,?)
	`, n.ID, string(n.Category), n.Title, n.Body, n.Importance, n.DeepLink, string(actions), boolToInt(n.Read), n.CreatedAt.UnixMilli())
	return err
}

func (r *NotificationsRepo) List(ctx context.Context, unreadOnly bool) ([]notifications.Notification, error) {
	query := `SELECT id, category, title, body, importance, deep_link, actions, read, created_at FROM notifications`
	if unreadOnly {
		query += ` WHERE read = 0`
	}
	query += ` ORDER BY created_at DESC LIMIT 200`
	rows, err := r.db.QueryContext(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]notifications.Notification, 0)
	for rows.Next() {
		var (
			n         notifications.Notification
			category  string
			actions   string
			readInt   int
			createdAt int64
		)
		if err := rows.Scan(&n.ID, &category, &n.Title, &n.Body, &n.Importance, &n.DeepLink, &actions, &readInt, &createdAt); err != nil {
			return nil, err
		}
		n.Category = notifications.Category(category)
		n.Read = readInt != 0
		n.CreatedAt = time.UnixMilli(createdAt)
		_ = json.Unmarshal([]byte(actions), &n.Actions)
		out = append(out, n)
	}
	return out, rows.Err()
}

func (r *NotificationsRepo) MarkRead(ctx context.Context, id string) error {
	_, err := r.db.ExecContext(ctx, `UPDATE notifications SET read = 1 WHERE id = ?`, id)
	return err
}

func (r *NotificationsRepo) MarkAllRead(ctx context.Context) error {
	_, err := r.db.ExecContext(ctx, `UPDATE notifications SET read = 1`)
	return err
}

func (r *NotificationsRepo) Delete(ctx context.Context, id string) error {
	_, err := r.db.ExecContext(ctx, `DELETE FROM notifications WHERE id = ?`, id)
	return err
}
