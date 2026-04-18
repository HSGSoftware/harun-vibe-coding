package fs

import (
	"context"
	"os"
	"path/filepath"
	"strings"

	"github.com/fsnotify/fsnotify"
	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/util"
)

// ChangeKind is the kind of fs event translated to WS `fs.change`.
type ChangeKind string

const (
	ChangeCreate ChangeKind = "create"
	ChangeModify ChangeKind = "modify"
	ChangeDelete ChangeKind = "delete"
	ChangeRename ChangeKind = "rename"
)

// Change is one file-system change normalized from fsnotify events.
type Change struct {
	ProjectID string     `json:"project_id"`
	Path      string     `json:"path"`
	Kind      ChangeKind `json:"kind"`
	Size      int64      `json:"size"`
}

// Watch recursively watches root for changes and pushes them to out until
// ctx is cancelled. Build/artifact dirs are skipped.
func Watch(ctx context.Context, projectID, root string, out chan<- Change) error {
	w, err := fsnotify.NewWatcher()
	if err != nil {
		return err
	}
	defer w.Close()

	walk := filepath.Walk
	_ = walk(root, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return nil
		}
		if info.IsDir() {
			if isSkipped(info.Name()) {
				return filepath.SkipDir
			}
			return w.Add(path)
		}
		return nil
	})

	for {
		select {
		case <-ctx.Done():
			return nil
		case ev, ok := <-w.Events:
			if !ok {
				return nil
			}
			change := toChange(projectID, root, ev)
			if change.Kind == "" {
				continue
			}
			select {
			case out <- change:
			case <-ctx.Done():
				return nil
			}
			// Watch new subdirectories on the fly.
			if ev.Op&fsnotify.Create != 0 {
				if info, err := os.Stat(ev.Name); err == nil && info.IsDir() && !isSkipped(info.Name()) {
					_ = w.Add(ev.Name)
				}
			}
		case <-w.Errors:
			// tolerate transient watcher errors (Termux sometimes hiccups on SD)
		}
	}
}

func toChange(projectID, root string, ev fsnotify.Event) Change {
	rel, _ := util.RelativeTo(root, ev.Name)
	c := Change{ProjectID: projectID, Path: filepath.ToSlash(rel)}
	info, _ := os.Stat(ev.Name)
	if info != nil {
		c.Size = info.Size()
	}
	switch {
	case ev.Op&fsnotify.Create != 0:
		c.Kind = ChangeCreate
	case ev.Op&fsnotify.Write != 0:
		c.Kind = ChangeModify
	case ev.Op&fsnotify.Remove != 0:
		c.Kind = ChangeDelete
	case ev.Op&fsnotify.Rename != 0:
		c.Kind = ChangeRename
	default:
		return Change{}
	}
	if strings.HasPrefix(c.Path, "..") {
		return Change{}
	}
	return c
}
