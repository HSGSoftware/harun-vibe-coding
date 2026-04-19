package util

import (
	"os"
	"strings"
)

// IsTermux returns true when running inside Termux (detected via PREFIX env).
func IsTermux() bool {
	prefix := os.Getenv("PREFIX")
	return strings.Contains(prefix, "com.termux")
}

// TermuxHome returns Termux's home directory when present, else the process home.
func TermuxHome() string {
	if home := os.Getenv("HOME"); home != "" {
		return home
	}
	if IsTermux() {
		return "/data/data/com.termux/files/home"
	}
	h, _ := os.UserHomeDir()
	return h
}
