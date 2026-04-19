// Command server is the Harun Vibe Coding Go backend entrypoint.
// It is intended to run inside Termux on Android, reading its configuration from
// ~/.harun-vibe/config.yaml and serving HTTP + WebSocket on port 8080 by default.
package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"os/signal"
	"syscall"

	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/config"
	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/server"
	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/storage"
	"github.com/hsgsoftware/harun-vibe-coding/backend/pkg/version"
)

func main() {
	configPath := flag.String("config", "~/.harun-vibe/config.yaml", "path to config.yaml")
	showVersion := flag.Bool("version", false, "print version and exit")
	flag.Parse()

	if *showVersion {
		fmt.Println(version.String())
		return
	}

	cfg, err := config.Load(*configPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "load config: %v\n", err)
		os.Exit(1)
	}

	log, err := server.NewLogger(cfg.Server.LogLevel, cfg.Server.LogFile)
	if err != nil {
		fmt.Fprintf(os.Stderr, "init logger: %v\n", err)
		os.Exit(1)
	}
	log.Info().Str("version", version.Version).Msg("starting")

	db, err := storage.Open(cfg.Database.Path)
	if err != nil {
		log.Error().Err(err).Msg("open db")
		os.Exit(1)
	}
	defer db.Close()
	if err := db.Migrate(); err != nil {
		log.Error().Err(err).Msg("migrate")
		os.Exit(1)
	}

	app := server.New(cfg, db, log)

	ctx, cancel := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer cancel()
	if err := app.Run(ctx); err != nil {
		log.Error().Err(err).Msg("server exit")
		os.Exit(1)
	}
}
