#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"

die() { echo "error: $*" >&2; exit 1; }
info() { echo "==> $*"; }

command -v brew >/dev/null || die "Homebrew not found — install from https://brew.sh"

BREW_PREFIX="$(brew --prefix)"
GST_PLUGIN_DIR="$BREW_PREFIX/lib/gstreamer-1.0-gtk4"

# ---------------------------------------------------------------------------
# Dependencies
# ---------------------------------------------------------------------------
info "Installing Homebrew dependencies..."
brew install \
  meson ninja pkg-config \
  vala blueprint-compiler \
  dylibbundler librsvg \
  gtk4 libadwaita \
  libgee libsoup json-glib \
  gstreamer glib-networking \
  desktop-file-utils

# ---------------------------------------------------------------------------
# Fix Vala vapi search path
# valac looks in share/vala-X.Y/vapi/ but Homebrew puts files in share/vala/vapi/.
# Workaround: symlink into Cellar. Re-run this script after `brew upgrade vala`.
# ---------------------------------------------------------------------------
VALA_VERSION="$(valac --version | awk '{print $2}')"
VALA_MINOR="${VALA_VERSION%.*}"
VALA_VAPI_SRC="$BREW_PREFIX/share/vala/vapi"
VALA_VAPI_DST="$BREW_PREFIX/Cellar/vala/${VALA_VERSION}/share/vala-${VALA_MINOR}/vapi"

if [ -d "$VALA_VAPI_DST" ]; then
  info "Linking vapi files into valac search path ($VALA_MINOR)..."
  for f in "$VALA_VAPI_SRC"/*; do
    name="$(basename "$f")"
    target="$VALA_VAPI_DST/$name"
    [ ! -e "$target" ] && ln -s "$f" "$target" && echo "  linked: $name"
  done
else
  die "Could not find valac vapi directory: $VALA_VAPI_DST"
fi

# ---------------------------------------------------------------------------
# GStreamer plugin directory without GTK3 sink
# libgstgtk.dylib (GTK3) conflicts with GTK4 Objective-C classes at runtime
# ---------------------------------------------------------------------------
info "Creating filtered GStreamer plugin directory..."
mkdir -p "$GST_PLUGIN_DIR"
for f in "$BREW_PREFIX"/Cellar/gstreamer/*/lib/gstreamer-1.0/libgst*.dylib; do
  name="$(basename "$f")"
  [ "$name" != "libgstgtk.dylib" ] && ln -sf "$f" "$GST_PLUGIN_DIR/$name"
done

# ---------------------------------------------------------------------------
# Configure
# ---------------------------------------------------------------------------
info "Configuring with Meson..."
XDG_DATA_DIRS="$BREW_PREFIX/share" \
meson setup "$BUILD_DIR" \
  -Dwith_webkit=false \
  --reconfigure 2>/dev/null || \
meson setup "$BUILD_DIR" \
  -Dwith_webkit=false

# ---------------------------------------------------------------------------
# Build
# ---------------------------------------------------------------------------
info "Building..."
XDG_DATA_DIRS="$BREW_PREFIX/share" ninja -C "$BUILD_DIR"

# ---------------------------------------------------------------------------
# Compile GSettings schema
# ---------------------------------------------------------------------------
info "Compiling GSettings schema..."
mkdir -p "$BUILD_DIR/schemas"
cp "$PROJECT_ROOT/data/space.rirusha.Cassette.gschema.xml" "$BUILD_DIR/schemas/"
glib-compile-schemas "$BUILD_DIR/schemas"

echo ""
echo "Build complete. Run with: ./macos/run.sh"
