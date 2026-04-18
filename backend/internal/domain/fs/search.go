package fs

import (
	"bufio"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/util"
)

// SearchHit is one match in one file.
type SearchHit struct {
	Path string `json:"path"`
	Line int    `json:"line"`
	Text string `json:"text"`
}

// Opts controls search behavior.
type Opts struct {
	Query         string
	CaseSensitive bool
	Regex         bool
	Glob          string
	MaxHits       int
}

// Search walks root and returns matching lines. Hidden / build dirs are skipped.
func Search(root string, opts Opts) ([]SearchHit, error) {
	if opts.MaxHits == 0 {
		opts.MaxHits = 1000
	}
	var re *regexp.Regexp
	if opts.Regex {
		var err error
		pattern := opts.Query
		if !opts.CaseSensitive {
			pattern = "(?i)" + pattern
		}
		re, err = regexp.Compile(pattern)
		if err != nil {
			return nil, err
		}
	}
	hits := make([]SearchHit, 0, 128)
	err := filepath.Walk(root, func(path string, info os.FileInfo, werr error) error {
		if werr != nil {
			return nil
		}
		if info.IsDir() {
			if isSkipped(info.Name()) {
				return filepath.SkipDir
			}
			return nil
		}
		if opts.Glob != "" {
			matched, _ := filepath.Match(opts.Glob, filepath.Base(path))
			if !matched {
				return nil
			}
		}
		f, err := os.Open(path)
		if err != nil {
			return nil
		}
		defer f.Close()
		scanner := bufio.NewScanner(f)
		scanner.Buffer(make([]byte, 64*1024), 1024*1024)
		ln := 0
		for scanner.Scan() {
			ln++
			line := scanner.Text()
			var matched bool
			if re != nil {
				matched = re.MatchString(line)
			} else {
				if opts.CaseSensitive {
					matched = strings.Contains(line, opts.Query)
				} else {
					matched = strings.Contains(strings.ToLower(line), strings.ToLower(opts.Query))
				}
			}
			if !matched {
				continue
			}
			rel, _ := util.RelativeTo(root, path)
			hits = append(hits, SearchHit{Path: filepath.ToSlash(rel), Line: ln, Text: line})
			if len(hits) >= opts.MaxHits {
				return filepath.SkipAll
			}
		}
		return nil
	})
	return hits, err
}
