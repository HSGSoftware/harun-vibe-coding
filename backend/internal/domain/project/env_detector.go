package project

import (
	"os"
	"path/filepath"
)

// DetectEnv inspects path and returns a best-effort environment label.
// Returned values align with Flutter's env_colors.dart mapping.
func DetectEnv(path string) string {
	exists := func(rel string) bool {
		_, err := os.Stat(filepath.Join(path, rel))
		return err == nil
	}

	switch {
	case exists("pubspec.yaml"):
		return "flutter"
	case exists("package.json"):
		return "nodejs"
	case exists("next.config.js") || exists("next.config.mjs"):
		return "nextjs"
	case exists("vite.config.js") || exists("vite.config.ts"):
		return "vite"
	case exists("requirements.txt") || exists("pyproject.toml"):
		return "python"
	case exists("manage.py"):
		return "django"
	case exists("go.mod"):
		return "go"
	case exists("Cargo.toml"):
		return "rust"
	case exists("build.gradle") || exists("build.gradle.kts"):
		return "kotlin"
	default:
		return "generic"
	}
}

// DefaultEntryCmd returns a reasonable dev-server command for an env.
func DefaultEntryCmd(env string) string {
	switch env {
	case "flutter":
		return "flutter run -d web-server --web-port=3000"
	case "nodejs", "vite", "nextjs":
		return "npm run dev"
	case "python":
		return "python -m http.server 3000"
	case "django":
		return "python manage.py runserver 0.0.0.0:3000"
	case "go":
		return "go run ./..."
	case "rust":
		return "cargo run"
	default:
		return ""
	}
}
