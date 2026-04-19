package config

// Default returns a Config populated with the canonical defaults from plan.md §4.2.
// Paths use ~ placeholders; normalize() expands them at load time.
func Default() *Config {
	return &Config{
		Server: ServerConfig{
			Host:        "0.0.0.0",
			Port:        8080,
			CorsOrigins: []string{"*"},
			LogLevel:    "info",
			LogFile:     "~/.harun-vibe/logs/server.log",
			AuthToken:   "",
		},
		Paths: PathsConfig{
			ProjectsDir: "~/HarunVibeCoding/projects",
			BackupsDir:  "~/HarunVibeCoding/backups",
			DataDir:     "~/.harun-vibe",
		},
		Database: DatabaseConfig{
			Path: "~/.harun-vibe/data.db",
		},
		AI: AIConfig{
			Providers: map[string]ProviderConfig{
				"claude": {
					CLIPath:          "",
					DefaultModel:     "claude-sonnet-4-5",
					ExtendedThinking: false,
					LoginStatus:      "unknown",
				},
				"gemini": {
					CLIPath:      "",
					DefaultModel: "gemini-2.5-pro",
					LoginStatus:  "unknown",
				},
			},
			MaxOutputTokens: 8192,
			TimeoutSeconds:  300,
			Streaming:       true,
		},
		Backup: BackupConfig{
			AutoEnabled:      true,
			IntervalMinutes:  30,
			MaxLocalBackups:  20,
			GitCheckpoint:    true,
			CloudEnabled:     false,
			CloudProvider:    "",
			PreAIAutoEnabled: true,
		},
		Notifications: NotificationsConfig{
			Enabled:              true,
			AIResponseSound:      true,
			ServerErrorVibrate:   true,
			TunnelReadyAlert:     true,
			BackupCompleteSilent: true,
		},
		Tunnel: TunnelConfig{
			Provider:        "cloudflared",
			CloudflaredPath: "",
		},
	}
}
