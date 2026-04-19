// Package fs exposes the file-tree, file CRUD, content search, and fsnotify
// watcher services. All paths are sandboxed through util.SafeJoin.
package fs

import (
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"sort"
	"strings"

	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/util"
)

// Node is a single tree entry. Children is nil for files and empty for empty dirs.
type Node struct {
	Name     string  `json:"name"`
	Path     string  `json:"path"`
	IsDir    bool    `json:"is_dir"`
	Size     int64   `json:"size"`
	Children []*Node `json:"children,omitempty"`
}

// Tree walks root up to `depth` levels deep. Hidden entries (".git", "node_modules",
// "build", "dist") are skipped by default to keep trees small on mobile.
func Tree(root string, startPath string, depth int) (*Node, error) {
	base, err := util.SafeJoin(root, startPath)
	if err != nil {
		return nil, err
	}
	info, err := os.Stat(base)
	if err != nil {
		return nil, fmt.Errorf("stat: %w", err)
	}
	return buildNode(root, base, info, depth)
}

func buildNode(root, abs string, info fs.FileInfo, depth int) (*Node, error) {
	rel, err := util.RelativeTo(root, abs)
	if err != nil {
		return nil, err
	}
	n := &Node{
		Name:  filepath.Base(abs),
		Path:  filepath.ToSlash(rel),
		IsDir: info.IsDir(),
		Size:  info.Size(),
	}
	if !info.IsDir() || depth <= 0 {
		return n, nil
	}
	entries, err := os.ReadDir(abs)
	if err != nil {
		return n, nil // partial tree on permission errors
	}
	children := make([]*Node, 0, len(entries))
	for _, e := range entries {
		if isSkipped(e.Name()) {
			continue
		}
		full := filepath.Join(abs, e.Name())
		sub, err := e.Info()
		if err != nil {
			continue
		}
		child, err := buildNode(root, full, sub, depth-1)
		if err != nil {
			continue
		}
		children = append(children, child)
	}
	sort.SliceStable(children, func(i, j int) bool {
		if children[i].IsDir != children[j].IsDir {
			return children[i].IsDir
		}
		return strings.ToLower(children[i].Name) < strings.ToLower(children[j].Name)
	})
	n.Children = children
	return n, nil
}

func isSkipped(name string) bool {
	switch name {
	case ".git", ".svn", ".hg", "node_modules", "build", "dist", ".dart_tool", ".idea", ".vscode", "target", "__pycache__":
		return true
	}
	return false
}
