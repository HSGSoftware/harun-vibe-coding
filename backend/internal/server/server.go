package server

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/rs/zerolog"

	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/api"
	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/config"
	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/domain/project"
	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/domain/runner"
	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/domain/terminal"
	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/domain/tunnel"
	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/storage"
	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/ws"
)

// App bundles the dependencies a running server needs.
type App struct {
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

// New constructs the App and all domain services that depend on cfg/db.
func New(cfg *config.Config, db *storage.DB, log zerolog.Logger) *App {
	hub := ws.NewHub(log)
	projRepo := storage.NewProjectsRepo(db)
	projectsSvc := project.NewService(projRepo, cfg.Paths.ProjectsDir)

	logSink := func(e runner.LogEntry) {
		raw, _ := json.Marshal(map[string]any{
			"project_id": e.ProjectID,
			"line":       e.Line,
			"stream":     e.Stream,
			"timestamp":  e.Timestamp.UnixMilli(),
		})
		hub.PublishPayload("events", "events.project_log", json.RawMessage(raw))
	}
	statSink := func(id, status string, port int) {
		raw, _ := json.Marshal(map[string]any{
			"project_id": id,
			"status":     status,
			"port":       port,
		})
		hub.PublishPayload("events", "events.project_status", json.RawMessage(raw))
	}
	tunReady := func(id, url string) {
		raw, _ := json.Marshal(map[string]any{"project_id": id, "url": url})
		hub.PublishPayload("events", "events.tunnel_ready", json.RawMessage(raw))
	}
	termOut := func(sid string, data []byte) {
		hub.PublishPayload("terminal", "terminal.data", map[string]any{
			"terminal_id": sid,
			"data":        string(data),
		})
	}
	termExit := func(sid string, code int) {
		hub.PublishPayload("terminal", "terminal.exit", map[string]any{
			"terminal_id": sid,
			"exit_code":   code,
		})
	}

	return &App{
		Config:    cfg,
		Log:       log,
		DB:        db,
		Hub:       hub,
		Projects:  projectsSvc,
		Runner:    runner.New(logSink, statSink),
		Tunnel:    tunnel.NewService(tunReady),
		Terminals: terminal.NewManager(termOut, termExit),
		StartedAt: time.Now(),
	}
}

// Router builds and returns the Gin engine with all routes mounted.
func (a *App) Router() *gin.Engine {
	gin.SetMode(gin.ReleaseMode)
	r := gin.New()
	r.Use(gin.Recovery())
	r.Use(RequestLogger(a.Log))

	corsCfg := cors.Config{
		AllowOrigins:     a.Config.Server.CorsOrigins,
		AllowMethods:     []string{"GET", "POST", "PATCH", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization", "X-Harun-Token"},
		AllowCredentials: false,
		MaxAge:           12 * time.Hour,
	}
	if len(a.Config.Server.CorsOrigins) == 1 && a.Config.Server.CorsOrigins[0] == "*" {
		corsCfg.AllowOrigins = nil
		corsCfg.AllowAllOrigins = true
	}
	r.Use(cors.New(corsCfg))

	auth := AuthGuard(a.Config.Server.AuthToken)

	apiGroup := r.Group("/api", auth)
	deps := api.Deps{
		Config:    a.Config,
		Log:       a.Log,
		DB:        a.DB,
		Hub:       a.Hub,
		Projects:  a.Projects,
		Runner:    a.Runner,
		Tunnel:    a.Tunnel,
		Terminals: a.Terminals,
		StartedAt: a.StartedAt,
	}
	api.RegisterSystem(apiGroup, deps)
	api.RegisterSetup(apiGroup, deps)
	api.RegisterProjects(apiGroup, deps)
	api.RegisterFiles(apiGroup, deps)
	api.RegisterGit(apiGroup, deps)
	api.RegisterBackup(apiGroup, deps)
	api.RegisterAI(apiGroup, deps)
	api.RegisterTerminal(apiGroup, deps)
	api.RegisterTunnel(apiGroup, deps)
	api.RegisterSettings(apiGroup, deps)
	api.RegisterNotifications(apiGroup, deps)

	r.GET("/ws", auth, a.Hub.HandleUpgrade)

	return r
}

// Run starts the HTTP server and blocks until ctx is cancelled.
func (a *App) Run(ctx context.Context) error {
	addr := fmt.Sprintf("%s:%d", a.Config.Server.Host, a.Config.Server.Port)
	srv := &http.Server{
		Addr:              addr,
		Handler:           a.Router(),
		ReadHeaderTimeout: 10 * time.Second,
	}
	go a.Hub.Run(ctx)

	errCh := make(chan error, 1)
	go func() {
		a.Log.Info().Str("addr", addr).Msg("server starting")
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			errCh <- err
		}
	}()

	select {
	case <-ctx.Done():
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		if err := srv.Shutdown(shutdownCtx); err != nil {
			return fmt.Errorf("shutdown: %w", err)
		}
		return nil
	case err := <-errCh:
		return err
	}
}
