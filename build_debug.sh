#!/data/data/com.termux/files/usr/bin/bash
# Debug APK build for arm64 only — optimized for Termux / low-RAM Android builds.
set -euo pipefail

cd "$(dirname "$0")/mobile"
flutter build apk --debug --target-platform android-arm64 --split-per-abi
