#!/bin/sh
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BREW_PREFIX="$(brew --prefix)"
export XDG_DATA_DIRS="$BREW_PREFIX/share"
export GSETTINGS_SCHEMA_DIR="$PROJECT_ROOT/build/schemas"
export GST_PLUGIN_PATH="$BREW_PREFIX/lib/gstreamer-1.0-gtk4"
export GST_REGISTRY_FORK=no
exec "$PROJECT_ROOT/build/src/cassette" "$@"
