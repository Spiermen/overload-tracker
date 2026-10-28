#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WWW="$ROOT/www"
rm -rf "$WWW"
mkdir -p "$WWW/fonts"
cp "$ROOT/index.html" "$ROOT/manifest.json" "$ROOT/sw.js" "$ROOT/es.js" "$ROOT/native-bridge.js" "$WWW/"
cp "$ROOT"/icon*.png "$ROOT"/icon*.svg "$ROOT/apple-touch-icon.png" "$WWW/" 2>/dev/null || true
cp -R "$ROOT/fonts/"* "$WWW/fonts/"
# Capacitor loads from file:// — disable SW registration noise by stubbing in a flag file
# (native bridge also skips SW). Keep sw.js for parity if opened in browser via live reload.
echo "Synced PWA → www/ ($(du -sh "$WWW" | cut -f1))"
