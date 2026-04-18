#!/data/data/com.termux/files/usr/bin/bash
# Build the Harun Vibe Coding server inside Termux.
# Usage: ./scripts/build.sh [output_path]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUT="${1:-$HOME/.harun-vibe/harun-vibe-server}"

mkdir -p "$(dirname "$OUT")"

cd "$ROOT"
export CGO_ENABLED=1
GO_LDFLAGS="-s -w -X github.com/hsgsoftware/harun-vibe-coding/backend/pkg/version.GitCommit=$(git rev-parse --short HEAD 2>/dev/null || echo dev) -X github.com/hsgsoftware/harun-vibe-coding/backend/pkg/version.BuildDate=$(date -u +%Y-%m-%dT%H:%M:%SZ)"

echo "Building -> $OUT"
go build -trimpath -ldflags "$GO_LDFLAGS" -o "$OUT" ./cmd/server

echo "Binary size:"
ls -lh "$OUT"
