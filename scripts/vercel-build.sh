#!/usr/bin/env bash
set -euo pipefail

export FLUTTER_SUPPRESS_ANALYTICS=1
export FLUTTER_ALLOW_SUPERUSER=true
export PATH="$HOME/flutter/bin:$PATH"
export PUB_CACHE="$HOME/.pub-cache"

# Clean build cache to avoid corruption issues
echo "→ Cleaning build artifacts..."
flutter clean

# Re-fetch and upgrade web package (fixes JSObject compilation errors)
echo "→ Fetching dependencies..."
flutter pub get
echo "→ Upgrading web renderer package..."
flutter pub upgrade web

# Build web app (Flutter 3.22+ removed --web-renderer)
echo "→ Building Flutter web application..."
if [ -n "${GPG_BACKEND_URL:-}" ]; then
  flutter build web --release \
    --dart-define=GPG_BACKEND_URL="$GPG_BACKEND_URL"
else
  flutter build web --release
fi

echo "✓ Build complete: build/web"
