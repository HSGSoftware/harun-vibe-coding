package util

import (
	"errors"
	"fmt"
	"path/filepath"
	"strings"
)

// ErrPathEscape is returned when a requested file path escapes the project root.
var ErrPathEscape = errors.New("path escapes project root")

// SafeJoin normalizes rel against root, rejecting .. traversal and absolute paths
// that would leak outside root. Symlinks are not resolved here — the caller should
// refuse to follow symlinks pointing outside root.
func SafeJoin(root, rel string) (string, error) {
	if root == "" {
		return "", fmt.Errorf("empty root")
	}
	cleanRoot, err := filepath.Abs(filepath.Clean(root))
	if err != nil {
		return "", fmt.Errorf("abs root: %w", err)
	}
	cleanRel := filepath.Clean("/" + rel)
	candidate := filepath.Join(cleanRoot, cleanRel)
	absCandidate, err := filepath.Abs(candidate)
	if err != nil {
		return "", fmt.Errorf("abs candidate: %w", err)
	}
	if !strings.HasPrefix(absCandidate, cleanRoot+string(filepath.Separator)) && absCandidate != cleanRoot {
		return "", ErrPathEscape
	}
	return absCandidate, nil
}

// RelativeTo returns path relative to root, or an error if path is outside root.
func RelativeTo(root, path string) (string, error) {
	cleanRoot, err := filepath.Abs(filepath.Clean(root))
	if err != nil {
		return "", err
	}
	cleanPath, err := filepath.Abs(filepath.Clean(path))
	if err != nil {
		return "", err
	}
	rel, err := filepath.Rel(cleanRoot, cleanPath)
	if err != nil {
		return "", err
	}
	if strings.HasPrefix(rel, "..") {
		return "", ErrPathEscape
	}
	return rel, nil
}
