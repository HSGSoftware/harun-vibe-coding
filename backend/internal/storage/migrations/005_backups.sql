-- +goose Up
CREATE TABLE IF NOT EXISTS backups (
    id          TEXT PRIMARY KEY,
    project_id  TEXT NOT NULL,
    type        TEXT NOT NULL,
    created_at  INTEGER NOT NULL,
    size_bytes  INTEGER NOT NULL DEFAULT 0,
    path        TEXT NOT NULL DEFAULT '',
    cloud_url   TEXT NOT NULL DEFAULT '',
    commit_hash TEXT NOT NULL DEFAULT '',
    trigger     TEXT NOT NULL DEFAULT 'manual',
    note        TEXT NOT NULL DEFAULT ''
);

CREATE INDEX IF NOT EXISTS idx_backups_project ON backups(project_id, created_at DESC);

-- +goose Down
DROP INDEX IF EXISTS idx_backups_project;
DROP TABLE IF EXISTS backups;
