// Package config loads and validates the YAML configuration at ~/.harun-vibe/config.yaml.
package config

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"gopkg.in/yaml.v3"
)

// Config is the root of the YAML configuration file.
type Config struct {
	Server        ServerConfig        `yaml:"server"`
	Paths         PathsConfig         `yaml:"paths"`
	Database      DatabaseConfig      `yaml:"database"`
	AI            AIConfig            `yaml:"ai"`
	Backup        BackupConfig        `yaml:"backup"`
	Notifications NotificationsConfig `yaml:"notifications"`
	Tunnel        TunnelConfig        `yaml:"tunnel"`
}

// ServerConfig controls HTTP/WebSocket server binding and logging.
type ServerConfig struct {
	Host        string   `yaml:"host"`
	Port        int      `yaml:"port"`
	CorsOrigins []string `yaml:"cors_origins"`
	LogLevel    string   `yaml:"log_level"`
	LogFile     string   `yaml:"log_file"`
	AuthToken   string   `yaml:"auth_token"`
}

// PathsConfig holds user-visible directories.
type PathsConfig struct {
	ProjectsDir string `yaml:"projects_dir"`
	BackupsDir  string `yaml:"backups_dir"`
	DataDir     string `yaml:"data_dir"`
}

// DatabaseConfig points at the SQLite file.
type DatabaseConfig struct {
	Path string `yaml:"path"`
}

// AIConfig configures the Claude/Gemini CLI wrappers. No API keys are accepted.
type AIConfig struct {
	Providers       map[string]ProviderConfig `yaml:"providers"`
	MaxOutputTokens int                       `yaml:"max_output_tokens"`
	TimeoutSeconds  int                       `yaml:"timeout_seconds"`
	Streaming       bool                      `yaml:"streaming"`
}

// ProviderConfig describes a single CLI provider runtime state.
type ProviderConfig struct {
	CLIPath          string `yaml:"cli_path"`
	DefaultModel     string `yaml:"default_model"`
	ExtendedThinking bool   `yaml:"extended_thinking"`
	LoginStatus      string `yaml:"login_status"`
}

// BackupConfig drives local/git/cloud backup behavior.
type BackupConfig struct {
	AutoEnabled      bool   `yaml:"auto_enabled"`
	IntervalMinutes  int    `yaml:"interval_minutes"`
	MaxLocalBackups  int    `yaml:"max_local_backups"`
	GitCheckpoint    bool   `yaml:"git_checkpoint"`
	CloudEnabled     bool   `yaml:"cloud_enabled"`
	CloudProvider    string `yaml:"cloud_provider"`
	PreAIAutoEnabled bool   `yaml:"pre_ai_auto_enabled"`
}

// NotificationsConfig toggles server-side notification emission.
type NotificationsConfig struct {
	Enabled              bool `yaml:"enabled"`
	AIResponseSound      bool `yaml:"ai_response_sound"`
	ServerErrorVibrate   bool `yaml:"server_error_vibrate"`
	TunnelReadyAlert     bool `yaml:"tunnel_ready_alert"`
	BackupCompleteSilent bool `yaml:"backup_complete_silent"`
}

// TunnelConfig selects the tunnel provider.
type TunnelConfig struct {
	Provider         string `yaml:"provider"`
	CloudflaredPath  string `yaml:"cloudflared_path"`
	NgrokAuthToken   string `yaml:"ngrok_auth_token"`
	PreferredSubnets string `yaml:"preferred_subnets"`
}

// Load reads the YAML file at path, applies defaults, and returns the merged config.
// If path is empty, Default() is returned.
func Load(path string) (*Config, error) {
	cfg := Default()
	if path == "" {
		return cfg, nil
	}
	expanded, err := expandPath(path)
	if err != nil {
		return nil, fmt.Errorf("expand config path: %w", err)
	}
	data, err := os.ReadFile(expanded)
	if err != nil {
		if os.IsNotExist(err) {
			return cfg, nil
		}
		return nil, fmt.Errorf("read config: %w", err)
	}
	if err := yaml.Unmarshal(data, cfg); err != nil {
		return nil, fmt.Errorf("parse yaml: %w", err)
	}
	if err := cfg.normalize(); err != nil {
		return nil, fmt.Errorf("normalize config: %w", err)
	}
	return cfg, nil
}

// Save writes the current config back to path, creating parent dirs as needed.
func (c *Config) Save(path string) error {
	expanded, err := expandPath(path)
	if err != nil {
		return fmt.Errorf("expand: %w", err)
	}
	if err := os.MkdirAll(filepath.Dir(expanded), 0o755); err != nil {
		return fmt.Errorf("mkdir: %w", err)
	}
	data, err := yaml.Marshal(c)
	if err != nil {
		return fmt.Errorf("marshal: %w", err)
	}
	if err := os.WriteFile(expanded, data, 0o600); err != nil {
		return fmt.Errorf("write: %w", err)
	}
	return nil
}

// normalize expands ~ in paths and validates required fields.
func (c *Config) normalize() error {
	var err error
	if c.Server.LogFile, err = expandPath(c.Server.LogFile); err != nil {
		return err
	}
	if c.Paths.ProjectsDir, err = expandPath(c.Paths.ProjectsDir); err != nil {
		return err
	}
	if c.Paths.BackupsDir, err = expandPath(c.Paths.BackupsDir); err != nil {
		return err
	}
	if c.Paths.DataDir, err = expandPath(c.Paths.DataDir); err != nil {
		return err
	}
	if c.Database.Path, err = expandPath(c.Database.Path); err != nil {
		return err
	}
	if c.Server.Port == 0 {
		c.Server.Port = 8080
	}
	if c.Server.Host == "" {
		c.Server.Host = "0.0.0.0"
	}
	return nil
}

func expandPath(p string) (string, error) {
	if p == "" {
		return "", nil
	}
	if strings.HasPrefix(p, "~") {
		home, err := os.UserHomeDir()
		if err != nil {
			return "", err
		}
		p = filepath.Join(home, strings.TrimPrefix(p, "~"))
	}
	return filepath.Clean(p), nil
}
