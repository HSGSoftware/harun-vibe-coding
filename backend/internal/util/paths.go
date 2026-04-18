// Package util contains small leaf helpers shared across internal packages.
package util

import (
	"os"
	"path/filepath"
	"strings"
)

// ExpandHome replaces a leading ~ with the user's home directory.
func ExpandHome(p string) (string, error) {
	if p == "" || !strings.HasPrefix(p, "~") {
		return p, nil
	}
	home, err := os.UserHomeDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(home, strings.TrimPrefix(p, "~")), nil
}

// EnsureDir creates dir (and parents) with mode 0755 if missing.
func EnsureDir(dir string) error {
	return os.MkdirAll(dir, 0o755)
}
