#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/flutter/bin:$PATH"

if [ -n "${GPG_BACKEND_URL:-}" ]; then
	flutter build web --release --dart-define=GPG_BACKEND_URL="$GPG_BACKEND_URL"
else
	flutter build web --release
fi
