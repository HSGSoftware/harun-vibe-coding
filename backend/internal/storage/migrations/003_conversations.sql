-- +goose Up
CREATE TABLE IF NOT EXISTS conversations (
    id          TEXT PRIMARY KEY,
    project_id  TEXT NOT NULL,
    provider    TEXT NOT NULL,
    model       TEXT NOT NULL,
    title       TEXT NOT NULL DEFAULT '',
    archived    INTEGER NOT NULL DEFAULT 0,
    created_at  INTEGER NOT NULL,
    updated_at  INTEGER NOT NULL,
    stats_json  TEXT NOT NULL DEFAULT '{}'
);

CREATE INDEX IF NOT EXISTS idx_conv_project ON conversations(project_id, updated_at DESC);

CREATE TABLE IF NOT EXISTS messages (
    id              TEXT PRIMARY KEY,
    conversation_id TEXT NOT NULL,
    role            TEXT NOT NULL,
    content_json    TEXT NOT NULL,
    timestamp       INTEGER NOT NULL,
    FOREIGN KEY(conversation_id) REFERENCES conversations(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_messages_conv ON messages(conversation_id, timestamp ASC);

CREATE TABLE IF NOT EXISTS context_files (
    conversation_id TEXT NOT NULL,
    path            TEXT NOT NULL,
    included        INTEGER NOT NULL DEFAULT 1,
    PRIMARY KEY(conversation_id, path),
    FOREIGN KEY(conversation_id) REFERENCES conversations(id) ON DELETE CASCADE
);

-- +goose Down
DROP TABLE IF EXISTS context_files;
DROP INDEX IF EXISTS idx_messages_conv;
DROP TABLE IF EXISTS messages;
DROP INDEX IF EXISTS idx_conv_project;
DROP TABLE IF EXISTS conversations;
