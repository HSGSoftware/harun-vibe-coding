// Package git wraps go-git for the operations Harun Vibe Coding needs:
// status, log, diff, commit, branch, pull, push, stash, restore, checkpoint.
package git

import (
	"fmt"
	"time"

	gogit "github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/plumbing"
	"github.com/go-git/go-git/v5/plumbing/object"
)

// Status mirrors plan.md §5.5 GET /git/status.
type Status struct {
	Branch    string   `json:"branch"`
	Ahead     int      `json:"ahead"`
	Behind    int      `json:"behind"`
	Staged    []string `json:"staged"`
	Unstaged  []string `json:"unstaged"`
	Untracked []string `json:"untracked"`
}

// Commit is one entry in the log.
type Commit struct {
	Hash      string    `json:"hash"`
	Author    string    `json:"author"`
	Email     string    `json:"email"`
	Message   string    `json:"message"`
	Timestamp time.Time `json:"timestamp"`
}

// Open returns a repo handle anchored at path. Returns ErrRepositoryNotExists if not a repo.
func Open(path string) (*gogit.Repository, error) {
	return gogit.PlainOpen(path)
}

func GetStatus(path string) (*Status, error) {
	repo, err := Open(path)
	if err != nil {
		return nil, fmt.Errorf("open: %w", err)
	}
	wt, err := repo.Worktree()
	if err != nil {
		return nil, fmt.Errorf("worktree: %w", err)
	}
	st, err := wt.Status()
	if err != nil {
		return nil, fmt.Errorf("status: %w", err)
	}
	head, err := repo.Head()
	branch := ""
	if err == nil {
		branch = head.Name().Short()
	}
	out := &Status{Branch: branch, Staged: []string{}, Unstaged: []string{}, Untracked: []string{}}
	for file, fs := range st {
		if fs.Staging != gogit.Unmodified {
			out.Staged = append(out.Staged, file)
		}
		if fs.Worktree != gogit.Unmodified && fs.Worktree != gogit.Untracked {
			out.Unstaged = append(out.Unstaged, file)
		}
		if fs.Worktree == gogit.Untracked {
			out.Untracked = append(out.Untracked, file)
		}
	}
	return out, nil
}

func GetLog(path string, limit int) ([]Commit, error) {
	repo, err := Open(path)
	if err != nil {
		return nil, err
	}
	ref, err := repo.Head()
	if err != nil {
		return nil, err
	}
	iter, err := repo.Log(&gogit.LogOptions{From: ref.Hash()})
	if err != nil {
		return nil, err
	}
	out := make([]Commit, 0, limit)
	count := 0
	err = iter.ForEach(func(c *object.Commit) error {
		if limit > 0 && count >= limit {
			return fmt.Errorf("done")
		}
		out = append(out, Commit{
			Hash:      c.Hash.String()[:8],
			Author:    c.Author.Name,
			Email:     c.Author.Email,
			Message:   c.Message,
			Timestamp: c.Author.When,
		})
		count++
		return nil
	})
	if err != nil && err.Error() != "done" {
		return out, nil
	}
	return out, nil
}

func Commit(path, message, author, email string) (string, error) {
	repo, err := Open(path)
	if err != nil {
		return "", err
	}
	wt, err := repo.Worktree()
	if err != nil {
		return "", err
	}
	if err := wt.AddGlob("."); err != nil {
		return "", fmt.Errorf("add: %w", err)
	}
	hash, err := wt.Commit(message, &gogit.CommitOptions{
		Author: &object.Signature{
			Name:  fallback(author, "Harun Vibe Coding"),
			Email: fallback(email, "vibe@local"),
			When:  time.Now(),
		},
	})
	if err != nil {
		return "", fmt.Errorf("commit: %w", err)
	}
	return hash.String(), nil
}

func Checkpoint(path, note string) (string, error) {
	if note == "" {
		note = "[checkpoint] auto"
	}
	return Commit(path, note, "", "")
}

func Checkout(path, ref string, create bool) error {
	repo, err := Open(path)
	if err != nil {
		return err
	}
	wt, err := repo.Worktree()
	if err != nil {
		return err
	}
	return wt.Checkout(&gogit.CheckoutOptions{
		Branch: plumbing.NewBranchReferenceName(ref),
		Create: create,
	})
}

func fallback(s, d string) string {
	if s == "" {
		return d
	}
	return s
}
