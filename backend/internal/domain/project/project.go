// Package project owns the Project entity + lifecycle orchestration.
// Runtime fields (Status, RunningPort, TunnelURL) are not persisted — they
// are assembled from the runner + tunnel services at read time.
package project

import "time"

// Project matches the JSON shape in plan.md §4.3.
type Project struct {
	ID          string    `json:"id"`
	Name        string    `json:"name"`
	Path        string    `json:"path"`
	Env         string    `json:"env"`
	Port        int       `json:"port"`
	EntryCmd    string    `json:"entry_cmd"`
	Source      string    `json:"source"`
	GitRepo     string    `json:"git_repo,omitempty"`
	GitBranch   string    `json:"git_branch,omitempty"`
	Group       string    `json:"group,omitempty"`
	Favorite    bool      `json:"favorite"`
	LastOpened  time.Time `json:"last_opened"`
	CreatedAt   time.Time `json:"created_at"`
	Status      string    `json:"status"`
	RunningPort int       `json:"running_port,omitempty"`
	TunnelURL   string    `json:"tunnel_url,omitempty"`
}

// Valid project statuses. The DB never stores these — they are runtime-only.
const (
	StatusStopped  = "stopped"
	StatusStarting = "starting"
	StatusRunning  = "running"
	StatusError    = "error"
)
