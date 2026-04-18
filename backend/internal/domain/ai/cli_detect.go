// Package ai hosts the CLI subprocess wrappers for Claude Code and Gemini.
// No AI SDKs are imported here — all provider interaction is exec.Cmd based.
// See plan.md §11.0 for the contract.
package ai

import (
	"context"
	"os/exec"
	"strings"
)

// CLIInfo is the result of probing a CLI on PATH.
type CLIInfo struct {
	Provider  string `json:"provider"`
	Installed bool   `json:"installed"`
	Version   string `json:"version,omitempty"`
	Path      string `json:"path,omitempty"`
	LoggedIn  bool   `json:"logged_in"`
}

// DetectCLI locates `bin` on PATH, runs `bin --version`, and returns the parsed
// result. Login status is probed by the caller (depends on provider semantics).
func DetectCLI(ctx context.Context, provider, bin string) CLIInfo {
	info := CLIInfo{Provider: provider}
	path, err := exec.LookPath(bin)
	if err != nil {
		return info
	}
	info.Installed = true
	info.Path = path

	versionCtx, cancel := contextWithTimeout(ctx, 5)
	defer cancel()
	out, err := exec.CommandContext(versionCtx, bin, "--version").Output()
	if err == nil {
		info.Version = strings.TrimSpace(string(out))
	}
	return info
}

// ProbeClaudeLogin runs a fast, non-interactive command to decide if the user
// is logged in. `claude models list` returns exit 0 when authenticated.
func ProbeClaudeLogin(ctx context.Context, bin string) bool {
	c, cancel := contextWithTimeout(ctx, 6)
	defer cancel()
	cmd := exec.CommandContext(c, bin, "models", "list")
	return cmd.Run() == nil
}

// ProbeGeminiLogin runs `gemini auth status` (exit 0 == authed).
func ProbeGeminiLogin(ctx context.Context, bin string) bool {
	c, cancel := contextWithTimeout(ctx, 6)
	defer cancel()
	cmd := exec.CommandContext(c, bin, "auth", "status")
	return cmd.Run() == nil
}
