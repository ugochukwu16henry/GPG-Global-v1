#!/usr/bin/env bash
set -euo pipefail

export FLUTTER_SUPPRESS_ANALYTICS=1
export PATH="$HOME/flutter/bin:$PATH"
export PUB_CACHE="$HOME/.pub-cache"

if [ -n "${GPG_BACKEND_URL:-}" ]; then
  flutter build web --release --dart-define=GPG_BACKEND_URL="$GPG_BACKEND_URL"
else
  flutter build web --release
fi
