-- +goose Up
CREATE TABLE IF NOT EXISTS projects (
    id           TEXT PRIMARY KEY,
    name         TEXT NOT NULL,
    path         TEXT NOT NULL,
    env          TEXT NOT NULL DEFAULT '',
    port         INTEGER NOT NULL DEFAULT 0,
    entry_cmd    TEXT NOT NULL DEFAULT '',
    source       TEXT NOT NULL DEFAULT 'empty',
    git_repo     TEXT NOT NULL DEFAULT '',
    git_branch   TEXT NOT NULL DEFAULT '',
    proj_group   TEXT NOT NULL DEFAULT '',
    favorite     INTEGER NOT NULL DEFAULT 0,
    last_opened  INTEGER NOT NULL DEFAULT 0,
    created_at   INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_projects_last_opened ON projects(last_opened DESC);
CREATE INDEX IF NOT EXISTS idx_projects_favorite    ON projects(favorite);

-- +goose Down
DROP INDEX IF EXISTS idx_projects_favorite;
DROP INDEX IF EXISTS idx_projects_last_opened;
DROP TABLE IF EXISTS projects;
