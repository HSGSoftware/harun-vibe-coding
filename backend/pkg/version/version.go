// Package version exposes build-time version metadata for the server binary.
package version

var (
	// AppName is the product name.
	AppName = "Harun Vibe Coding Server"

	// Version is the semver string. Replaced at link time via -ldflags.
	Version = "0.1.0"

	// GitCommit is the short commit hash. Replaced at link time.
	GitCommit = "dev"

	// BuildDate is an ISO-8601 timestamp. Replaced at link time.
	BuildDate = "unknown"
)

// String returns a compact human-readable version string.
func String() string {
	return AppName + " " + Version + " (" + GitCommit + ", " + BuildDate + ")"
}
