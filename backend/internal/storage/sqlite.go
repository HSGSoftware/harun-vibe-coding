// Package storage owns the SQLite database, migrations, and per-domain repositories.
package storage

import (
	"database/sql"
	"embed"
	"fmt"
	"os"
	"path/filepath"

	"github.com/pressly/goose/v3"
	_ "github.com/mattn/go-sqlite3"
)

//go:embed migrations/*.sql
var migrationFS embed.FS

// DB wraps *sql.DB with the path used to open it (useful for diagnostics).
type DB struct {
	*sql.DB
	Path string
}

// Open creates parent dirs, opens the SQLite file, and returns a ready *DB.
// It does not run migrations — call Migrate separately.
func Open(path string) (*DB, error) {
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return nil, fmt.Errorf("mkdir: %w", err)
	}
	dsn := fmt.Sprintf("file:%s?_journal=WAL&_busy_timeout=5000&_fk=1", path)
	sqldb, err := sql.Open("sqlite3", dsn)
	if err != nil {
		return nil, fmt.Errorf("open: %w", err)
	}
	if err := sqldb.Ping(); err != nil {
		return nil, fmt.Errorf("ping: %w", err)
	}
	sqldb.SetMaxOpenConns(1) // SQLite + WAL: single writer is safest for Termux use
	return &DB{DB: sqldb, Path: path}, nil
}

// Migrate applies all pending migrations embedded in migrations/*.sql.
func (d *DB) Migrate() error {
	goose.SetBaseFS(migrationFS)
	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("dialect: %w", err)
	}
	if err := goose.Up(d.DB, "migrations"); err != nil {
		return fmt.Errorf("up: %w", err)
	}
	return nil
}
