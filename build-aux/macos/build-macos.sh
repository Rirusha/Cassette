#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
GST_PLUGIN_DIR=/opt/homebrew/lib/gstreamer-1.0-gtk4
BREW_PREFIX="$(brew --prefix)"

die() { echo "error: $*" >&2; exit 1; }
info() { echo "==> $*"; }

# ---------------------------------------------------------------------------
# 1. Check Homebrew
# ---------------------------------------------------------------------------
command -v brew >/dev/null || die "Homebrew not found — install from https://brew.sh"

# ---------------------------------------------------------------------------
# 2. Install dependencies
# ---------------------------------------------------------------------------
info "Installing Homebrew dependencies..."
brew install \
  meson ninja pkg-config \
  vala blueprint-compiler \
  gtk4 libadwaita \
  libgee libsoup json-glib \
  gstreamer \
  desktop-file-utils

# ---------------------------------------------------------------------------
# 3. Fix Vala vapi search path
#    valac looks in share/vala-X.Y/vapi/ but Homebrew puts files in share/vala/vapi/
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
# 4. GStreamer plugin directory without GTK3 sink
#    libgstgtk.dylib (GTK3) conflicts with GTK4 Objective-C classes at runtime
# ---------------------------------------------------------------------------
info "Creating filtered GStreamer plugin directory..."
mkdir -p "$GST_PLUGIN_DIR"
for f in "$BREW_PREFIX"/Cellar/gstreamer/*/lib/gstreamer-1.0/libgst*.dylib; do
  name="$(basename "$f")"
  [ "$name" != "libgstgtk.dylib" ] && ln -sf "$f" "$GST_PLUGIN_DIR/$name"
done

# ---------------------------------------------------------------------------
# 5. Configure
# ---------------------------------------------------------------------------
info "Configuring with Meson..."
XDG_DATA_DIRS="$BREW_PREFIX/share" \
meson setup "$BUILD_DIR" \
  -Dwith_webkit=false \
  --reconfigure 2>/dev/null || \
meson setup "$BUILD_DIR" \
  -Dwith_webkit=false

# ---------------------------------------------------------------------------
# 6. Build
# ---------------------------------------------------------------------------
info "Building..."
# metainfo.xml must exist before resources compile (undeclared dep in meson.build)
XDG_DATA_DIRS="$BREW_PREFIX/share" \
  ninja -C "$BUILD_DIR" "data/space.rirusha.Cassette.Devel.metainfo.xml"

XDG_DATA_DIRS="$BREW_PREFIX/share" \
  ninja -C "$BUILD_DIR" src/cassette

# ---------------------------------------------------------------------------
# 7. Compile GSettings schema
# ---------------------------------------------------------------------------
info "Compiling GSettings schema..."
mkdir -p "$BUILD_DIR/schemas"
cp "$PROJECT_ROOT/data/gschema.xml" \
   "$BUILD_DIR/schemas/space.rirusha.Cassette.Devel.gschema.xml"
glib-compile-schemas "$BUILD_DIR/schemas"

# ---------------------------------------------------------------------------
# 8. Write run.sh next to the script
# ---------------------------------------------------------------------------
info "Writing run.sh..."
cat > "$SCRIPT_DIR/run.sh" << EOF
#!/bin/sh
SCRIPT_DIR="\$(cd "\$(dirname "\$0")" && pwd)"
PROJECT_ROOT="\$(cd "\$SCRIPT_DIR/.." && pwd)"
export XDG_DATA_DIRS=$BREW_PREFIX/share
export GSETTINGS_SCHEMA_DIR="\$PROJECT_ROOT/build/schemas"
export GST_PLUGIN_PATH=$GST_PLUGIN_DIR
export GST_REGISTRY_FORK=no
exec "\$PROJECT_ROOT/build/src/cassette" "\$@"
EOF
chmod +x "$SCRIPT_DIR/run.sh"

echo ""
echo "Build complete. Run with: ./scripts-macos/run.sh"
