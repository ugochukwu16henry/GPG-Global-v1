#!/usr/bin/env bash
set -euo pipefail

if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
fi

export PATH="$HOME/flutter/bin:$PATH"
flutter --version
flutter config --enable-web
flutter pub get
