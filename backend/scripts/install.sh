#!/data/data/com.termux/files/usr/bin/bash
# One-shot installer for Harun Vibe Coding runtime assets.
# - Ensures ~/.harun-vibe/ directory layout exists
# - Writes a default config.yaml if missing
# - Copies start.sh launcher Termux:RunCommand expects
set -euo pipefail

HVC_HOME="$HOME/.harun-vibe"
mkdir -p "$HVC_HOME/logs" "$HOME/HarunVibeCoding/projects" "$HOME/HarunVibeCoding/backups"

CONFIG_FILE="$HVC_HOME/config.yaml"
if [[ ! -f "$CONFIG_FILE" ]]; then
  cat > "$CONFIG_FILE" <<'YAML'
server:
  host: 0.0.0.0
  port: 8080
  cors_origins: ["*"]
  log_level: info
  log_file: ~/.harun-vibe/logs/server.log

paths:
  projects_dir: ~/HarunVibeCoding/projects
  backups_dir: ~/HarunVibeCoding/backups
  data_dir: ~/.harun-vibe

database:
  path: ~/.harun-vibe/data.db
YAML
fi

cat > "$HVC_HOME/start.sh" <<'SH'
#!/data/data/com.termux/files/usr/bin/bash
export HOME=/data/data/com.termux/files/home
cd "$HOME/.harun-vibe"
exec ./harun-vibe-server --config config.yaml
SH
chmod +x "$HVC_HOME/start.sh"

echo "Installed at $HVC_HOME"
echo "Next: build the binary with scripts/build.sh and drop it into $HVC_HOME/harun-vibe-server"
