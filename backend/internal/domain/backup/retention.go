package backup

import (
	"context"
	"os"
	"sort"
)

// ApplyRetention keeps only the newest max backups per project and deletes the rest.
func ApplyRetention(ctx context.Context, svc *Service, projectID string, max int) error {
	if max <= 0 {
		return nil
	}
	items, err := svc.List(ctx, projectID)
	if err != nil {
		return err
	}
	sort.SliceStable(items, func(i, j int) bool {
		return items[i].CreatedAt.After(items[j].CreatedAt)
	})
	if len(items) <= max {
		return nil
	}
	for _, old := range items[max:] {
		if old.Path != "" {
			_ = os.Remove(old.Path)
		}
		if err := svc.Delete(ctx, old.ID); err != nil {
			return err
		}
	}
	return nil
}
