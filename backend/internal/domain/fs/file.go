package fs

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/util"
)

// MaxReadBytes caps the size of files returned via GET /file. Larger files
// should be fetched via streaming — plan.md §5.4.
const MaxReadBytes = 5 * 1024 * 1024

// Content holds the result of a file read.
type Content struct {
	Content  string    `json:"content"`
	Size     int64     `json:"size"`
	Language string    `json:"language"`
	Encoding string    `json:"encoding"`
	Mtime    time.Time `json:"mtime"`
}

func Read(root, rel string) (*Content, error) {
	abs, err := util.SafeJoin(root, rel)
	if err != nil {
		return nil, err
	}
	info, err := os.Stat(abs)
	if err != nil {
		return nil, err
	}
	if info.Size() > MaxReadBytes {
		return nil, fmt.Errorf("file too large: %d", info.Size())
	}
	data, err := os.ReadFile(abs)
	if err != nil {
		return nil, err
	}
	return &Content{
		Content:  string(data),
		Size:     info.Size(),
		Language: LanguageFor(rel),
		Encoding: "utf-8",
		Mtime:    info.ModTime(),
	}, nil
}

func Write(root, rel, content string, createDirs bool) (int64, error) {
	abs, err := util.SafeJoin(root, rel)
	if err != nil {
		return 0, err
	}
	if createDirs {
		if err := os.MkdirAll(filepath.Dir(abs), 0o755); err != nil {
			return 0, err
		}
	}
	if err := os.WriteFile(abs, []byte(content), 0o644); err != nil {
		return 0, err
	}
	return int64(len(content)), nil
}

func CreateFile(root, rel string, isDir bool) error {
	abs, err := util.SafeJoin(root, rel)
	if err != nil {
		return err
	}
	if isDir {
		return os.MkdirAll(abs, 0o755)
	}
	if err := os.MkdirAll(filepath.Dir(abs), 0o755); err != nil {
		return err
	}
	f, err := os.OpenFile(abs, os.O_WRONLY|os.O_CREATE|os.O_EXCL, 0o644)
	if err != nil {
		return err
	}
	return f.Close()
}

func Delete(root, rel string) error {
	abs, err := util.SafeJoin(root, rel)
	if err != nil {
		return err
	}
	return os.RemoveAll(abs)
}

func Rename(root, oldRel, newRel string) error {
	oldAbs, err := util.SafeJoin(root, oldRel)
	if err != nil {
		return err
	}
	newAbs, err := util.SafeJoin(root, newRel)
	if err != nil {
		return err
	}
	if err := os.MkdirAll(filepath.Dir(newAbs), 0o755); err != nil {
		return err
	}
	return os.Rename(oldAbs, newAbs)
}

// LanguageFor returns a Monaco-language-id guess for the given path.
func LanguageFor(path string) string {
	lower := strings.ToLower(filepath.Base(path))
	ext := strings.ToLower(filepath.Ext(path))
	switch ext {
	case ".dart":
		return "dart"
	case ".go":
		return "go"
	case ".kt", ".kts":
		return "kotlin"
	case ".py":
		return "python"
	case ".js", ".cjs", ".mjs":
		return "javascript"
	case ".ts":
		return "typescript"
	case ".tsx", ".jsx":
		return "typescriptreact"
	case ".json":
		return "json"
	case ".yaml", ".yml":
		return "yaml"
	case ".md":
		return "markdown"
	case ".html", ".htm":
		return "html"
	case ".css":
		return "css"
	case ".rs":
		return "rust"
	}
	if lower == "dockerfile" {
		return "dockerfile"
	}
	return "plaintext"
}
