// Package server wires the Gin router, WebSocket hub, and HTTP lifecycle.
package server

import (
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"

	"github.com/rs/zerolog"
)

// NewLogger constructs a zerolog.Logger that multiplexes to stderr and an optional log file.
// Level values: "debug", "info", "warn", "error".
func NewLogger(level, file string) (zerolog.Logger, error) {
	lvl, err := zerolog.ParseLevel(strings.ToLower(level))
	if err != nil {
		return zerolog.Nop(), fmt.Errorf("parse level: %w", err)
	}

	writers := []io.Writer{zerolog.ConsoleWriter{Out: os.Stderr, TimeFormat: "15:04:05"}}
	if file != "" {
		if err := os.MkdirAll(filepath.Dir(file), 0o755); err != nil {
			return zerolog.Nop(), fmt.Errorf("mkdir log dir: %w", err)
		}
		f, err := os.OpenFile(file, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0o644)
		if err != nil {
			return zerolog.Nop(), fmt.Errorf("open log file: %w", err)
		}
		writers = append(writers, f)
	}
	multi := zerolog.MultiLevelWriter(writers...)
	return zerolog.New(multi).With().Timestamp().Logger().Level(lvl), nil
}
