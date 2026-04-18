// Package api contains the Gin HTTP handlers grouped by domain.
// Register* functions mount routes onto a route group and share a Deps struct
// so cross-cutting resources (config, db, ws hub) are plumbed consistently.
package api

import (
	"time"

	"github.com/rs/zerolog"

	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/config"
	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/domain/project"
	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/domain/runner"
	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/domain/terminal"
	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/domain/tunnel"
	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/storage"
	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/ws"
)

// Deps is the shared handler dependency bundle.
type Deps struct {
	Config    *config.Config
	Log       zerolog.Logger
	DB        *storage.DB
	Hub       *ws.Hub
	Projects  *project.Service
	Runner    *runner.Runner
	Tunnel    *tunnel.Service
	Terminals *terminal.Manager
	StartedAt time.Time
}
