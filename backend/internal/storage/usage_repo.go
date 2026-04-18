package storage

import (
	"context"
	"time"
)

// UsageRow is one daily usage aggregation per provider/model/project.
type UsageRow struct {
	Day         string
	Provider    string
	Model       string
	ProjectID   string
	TokensIn    int
	TokensOut   int
	CacheTokens int
	CostUSD     float64
}

type UsageRepo struct{ db *DB }

func NewUsageRepo(db *DB) *UsageRepo { return &UsageRepo{db: db} }

// AddTokens increments usage for today's (local) day bucket.
func (r *UsageRepo) AddTokens(ctx context.Context, provider, model, projectID string, tokensIn, tokensOut, cache int, costUSD float64) error {
	day := time.Now().Format("2006-01-02")
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO usage_daily(day, provider, model, project_id, tokens_in, tokens_out, cache_tokens, cost_usd)
		VALUES (?,?,?,?,?,?,?,?)
		ON CONFLICT(day, provider, model, project_id) DO UPDATE SET
			tokens_in = tokens_in + excluded.tokens_in,
			tokens_out = tokens_out + excluded.tokens_out,
			cache_tokens = cache_tokens + excluded.cache_tokens,
			cost_usd = cost_usd + excluded.cost_usd
	`, day, provider, model, projectID, tokensIn, tokensOut, cache, costUSD)
	return err
}

// List returns daily rows optionally filtered by project id.
func (r *UsageRepo) List(ctx context.Context, projectID, from, to string) ([]UsageRow, error) {
	rows, err := r.db.QueryContext(ctx, `
		SELECT day, provider, model, project_id, tokens_in, tokens_out, cache_tokens, cost_usd
		FROM usage_daily
		WHERE (? = '' OR project_id = ?) AND (? = '' OR day >= ?) AND (? = '' OR day <= ?)
		ORDER BY day DESC
	`, projectID, projectID, from, from, to, to)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]UsageRow, 0)
	for rows.Next() {
		var u UsageRow
		if err := rows.Scan(&u.Day, &u.Provider, &u.Model, &u.ProjectID, &u.TokensIn, &u.TokensOut, &u.CacheTokens, &u.CostUSD); err != nil {
			return nil, err
		}
		out = append(out, u)
	}
	return out, rows.Err()
}
