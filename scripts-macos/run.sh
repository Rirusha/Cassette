#!/bin/sh
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
export XDG_DATA_DIRS=/opt/homebrew/share
export GSETTINGS_SCHEMA_DIR="$PROJECT_ROOT/build/schemas"
export GST_PLUGIN_PATH=/opt/homebrew/lib/gstreamer-1.0-gtk4
export GST_REGISTRY_FORK=no
exec "$PROJECT_ROOT/build/src/cassette" "$@"
