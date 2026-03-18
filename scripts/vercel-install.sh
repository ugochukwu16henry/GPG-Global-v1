#!/usr/bin/env bash
set -euo pipefail

export FLUTTER_SUPPRESS_ANALYTICS=1

FLUTTER_DIR="$HOME/flutter"

if [ ! -d "$FLUTTER_DIR/bin" ]; then
  echo "→ Fetching latest stable Flutter version..."
  FLUTTER_VERSION=$(curl -fsSL \
    "https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json" \
    | python3 -c "
import sys, json
data = json.load(sys.stdin)
h = data['current_release']['stable']
print(next(r['version'] for r in data['releases'] if r['hash'] == h))
")
  echo "→ Downloading Flutter $FLUTTER_VERSION (tarball)..."
  curl -fsSL \
    "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    | tar xJ -C "$HOME"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"
export PUB_CACHE="$HOME/.pub-cache"

# Configure git to trust Flutter directory (pub may invoke git during dependency resolution)
git config --global --add safe.directory "$FLUTTER_DIR"
git config --global --add safe.directory /vercel/flutter

flutter config --no-analytics --enable-web
flutter pub get
