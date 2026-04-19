-- +goose Up
CREATE TABLE IF NOT EXISTS settings (
    key   TEXT PRIMARY KEY,
    value TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS permission_rules (
    id         TEXT PRIMARY KEY,
    tool_name  TEXT NOT NULL,
    scope      TEXT NOT NULL,
    policy     TEXT NOT NULL,
    project_id TEXT NOT NULL DEFAULT '',
    created_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_permission_rules_tool ON permission_rules(tool_name);

-- +goose Down
DROP INDEX IF EXISTS idx_permission_rules_tool;
DROP TABLE IF EXISTS permission_rules;
DROP TABLE IF EXISTS settings;
