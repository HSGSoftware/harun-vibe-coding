-- +goose Up
CREATE TABLE IF NOT EXISTS prompts (
    id         TEXT PRIMARY KEY,
    title      TEXT NOT NULL,
    content    TEXT NOT NULL,
    tags       TEXT NOT NULL DEFAULT '',
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_prompts_updated ON prompts(updated_at DESC);

CREATE TABLE IF NOT EXISTS usage_daily (
    day        TEXT NOT NULL,
    provider   TEXT NOT NULL,
    model      TEXT NOT NULL,
    project_id TEXT NOT NULL DEFAULT '',
    tokens_in  INTEGER NOT NULL DEFAULT 0,
    tokens_out INTEGER NOT NULL DEFAULT 0,
    cache_tokens INTEGER NOT NULL DEFAULT 0,
    cost_usd   REAL NOT NULL DEFAULT 0,
    PRIMARY KEY(day, provider, model, project_id)
);

CREATE TABLE IF NOT EXISTS notifications (
    id         TEXT PRIMARY KEY,
    category   TEXT NOT NULL,
    title      TEXT NOT NULL,
    body       TEXT NOT NULL,
    importance TEXT NOT NULL DEFAULT 'normal',
    deep_link  TEXT NOT NULL DEFAULT '',
    actions    TEXT NOT NULL DEFAULT '[]',
    read       INTEGER NOT NULL DEFAULT 0,
    created_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_notifications_unread ON notifications(read, created_at DESC);

CREATE TABLE IF NOT EXISTS memory (
    key        TEXT PRIMARY KEY,
    value      TEXT NOT NULL,
    scope      TEXT NOT NULL DEFAULT 'global',
    updated_at INTEGER NOT NULL
);

-- +goose Down
DROP TABLE IF EXISTS memory;
DROP INDEX IF EXISTS idx_notifications_unread;
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS usage_daily;
DROP INDEX IF EXISTS idx_prompts_updated;
DROP TABLE IF EXISTS prompts;
