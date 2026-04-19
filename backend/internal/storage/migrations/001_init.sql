-- +goose Up
CREATE TABLE IF NOT EXISTS schema_meta (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
);

INSERT OR IGNORE INTO schema_meta (key, value) VALUES ('app', 'harun-vibe-coding');

-- +goose Down
DROP TABLE IF EXISTS schema_meta;
