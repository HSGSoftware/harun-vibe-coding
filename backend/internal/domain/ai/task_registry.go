package ai

import "sync"

// TaskRegistry tracks running install/login tasks by id so Flutter can abort by id.
type TaskRegistry struct {
	mu    sync.Mutex
	tasks map[string]*Task
}

func NewTaskRegistry() *TaskRegistry {
	return &TaskRegistry{tasks: map[string]*Task{}}
}

func (r *TaskRegistry) Add(t *Task) {
	r.mu.Lock()
	r.tasks[t.ID] = t
	r.mu.Unlock()
}

func (r *TaskRegistry) Get(id string) *Task {
	r.mu.Lock()
	defer r.mu.Unlock()
	return r.tasks[id]
}

func (r *TaskRegistry) Remove(id string) {
	r.mu.Lock()
	delete(r.tasks, id)
	r.mu.Unlock()
}

func (r *TaskRegistry) Cancel(id string) bool {
	r.mu.Lock()
	t, ok := r.tasks[id]
	r.mu.Unlock()
	if !ok {
		return false
	}
	t.Cancel()
	return true
}
