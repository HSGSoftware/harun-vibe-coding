package api

import (
	"context"
	"encoding/json"
	"sync"

	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/domain/ai"
	"github.com/hsgsoftware/harun-vibe-coding/backend/internal/storage"
)

// SetupState is the persisted setup-wizard progress.
type SetupState struct {
	Completed bool              `json:"completed"`
	Step      int               `json:"step"`
	CLI       map[string]string `json:"cli_status"`
	Missing   []string          `json:"missing"`
}

const setupKey = "setup.state"

// setupService is attached once per Deps in RegisterSetup via package-level state
// because Deps is immutable per request. Concurrency-safe.
var (
	setupTasksMu sync.Mutex
	setupTasks   = ai.NewTaskRegistry()
)

// LoadSetupState reads (or initializes) the wizard state from SQLite.
func LoadSetupState(ctx context.Context, s *storage.DB) (*SetupState, error) {
	repo := storage.NewSettingsRepo(s)
	raw, err := repo.Get(ctx, setupKey)
	if err != nil {
		return nil, err
	}
	if raw == "" {
		return &SetupState{Step: 1, CLI: map[string]string{}, Missing: []string{}}, nil
	}
	var st SetupState
	if err := json.Unmarshal([]byte(raw), &st); err != nil {
		return &SetupState{Step: 1, CLI: map[string]string{}, Missing: []string{}}, nil
	}
	if st.CLI == nil {
		st.CLI = map[string]string{}
	}
	if st.Missing == nil {
		st.Missing = []string{}
	}
	return &st, nil
}

// SaveSetupState persists the wizard state.
func SaveSetupState(ctx context.Context, s *storage.DB, st *SetupState) error {
	repo := storage.NewSettingsRepo(s)
	raw, err := json.Marshal(st)
	if err != nil {
		return err
	}
	return repo.Set(ctx, setupKey, string(raw))
}
