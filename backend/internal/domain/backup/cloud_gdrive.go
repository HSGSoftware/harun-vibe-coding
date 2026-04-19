package backup

import (
	"context"
	"fmt"
)

// CloudProvider is the subset of operations a cloud backend must implement.
// plan.md §12.3 / §19 "Faz 9" treats cloud as opsiyonel — we ship the interface
// and a no-op Google Drive implementation. Wiring the real OAuth flow is the
// user's next session task.
type CloudProvider interface {
	Name() string
	Connect(ctx context.Context, token string) error
	Disconnect(ctx context.Context) error
	Upload(ctx context.Context, localPath, remoteName string) (remoteURL string, err error)
	Download(ctx context.Context, remoteURL, localPath string) error
}

// GDrive is the Google Drive provider. The OAuth token is supplied by the
// client after it completes the Google sign-in flow inside Flutter; backend
// never handles the OAuth dance in-process.
type GDrive struct {
	token string
}

func (g *GDrive) Name() string { return "gdrive" }

func (g *GDrive) Connect(_ context.Context, token string) error {
	if token == "" {
		return fmt.Errorf("empty token")
	}
	g.token = token
	return nil
}

func (g *GDrive) Disconnect(_ context.Context) error {
	g.token = ""
	return nil
}

// Upload is a placeholder — the real implementation should use a resumable
// upload request against https://www.googleapis.com/upload/drive/v3/files.
// For personal use the user can trigger manual uploads via share_plus on Flutter.
func (g *GDrive) Upload(_ context.Context, _, _ string) (string, error) {
	return "", fmt.Errorf("cloud upload not wired yet")
}

func (g *GDrive) Download(_ context.Context, _, _ string) error {
	return fmt.Errorf("cloud download not wired yet")
}
