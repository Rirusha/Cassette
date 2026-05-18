#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
BREW_PREFIX="$(brew --prefix)"
APP_NAME="Cassette"
APP_BUNDLE="$PROJECT_ROOT/$APP_NAME.app"
CONTENTS="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"
FRAMEWORKS="$CONTENTS/Frameworks"

die()  { echo "error: $*" >&2; exit 1; }
info() { echo "==> $*"; }

list_rpaths() {
    otool -l "$1" | awk '/cmd LC_RPATH/{f=1} f && /path /{print $2; f=0}'
}

is_macho() {
    [ -f "$1" ] && file "$1" | grep -q "Mach-O"
}

delete_all_rpaths() {
    file="$1"
    rpath="$2"
    while list_rpaths "$file" | grep -Fx "$rpath" >/dev/null 2>&1; do
        install_name_tool -delete_rpath "$rpath" "$file" 2>/dev/null || break
    done
}

normalize_rpath() {
    file="$1"
    keep="$2"
    for rpath in $(list_rpaths "$file" | sort -u); do
        delete_all_rpaths "$file" "$rpath"
    done
    install_name_tool -add_rpath "$keep" "$file"
}

# ---------------------------------------------------------------------------
# Prerequisites
# ---------------------------------------------------------------------------
command -v brew          >/dev/null 2>&1 || die "Homebrew not found"
command -v dylibbundler  >/dev/null 2>&1 || die "dylibbundler not found — brew install dylibbundler"
command -v rsvg-convert  >/dev/null 2>&1 || die "rsvg-convert not found — brew install librsvg"
command -v gio-querymodules >/dev/null 2>&1 || die "gio-querymodules not found — brew install glib"
[ -f "$BUILD_DIR/src/cassette" ] || die "Binary not found — run ./macos/build.sh first"

# ---------------------------------------------------------------------------
# 1. App bundle structure
# ---------------------------------------------------------------------------
info "Creating .app structure..."
rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS_DIR" "$RESOURCES" "$FRAMEWORKS"

# ---------------------------------------------------------------------------
# 2. Binary
# ---------------------------------------------------------------------------
info "Copying binary..."
cp "$BUILD_DIR/src/cassette" "$MACOS_DIR/cassette"

# ---------------------------------------------------------------------------
# 3. GStreamer plugins (filtered set without GTK3 sink, same as run.sh)
# ---------------------------------------------------------------------------
info "Copying GStreamer plugins..."
GST_DEST="$RESOURCES/lib/gstreamer-1.0"
mkdir -p "$GST_DEST"
GST_SRC="$BREW_PREFIX/lib/gstreamer-1.0-gtk4"
GST_PLUGINS="
  coreelements playback typefindfunctions
  app gio soup
  audioconvert audioresample volume autodetect osxaudio applemedia
  id3demux audioparsers mpg123 faad fdkaac
  opus ogg vorbis flac wavparse
  isomp4 isobmff mpegtsdemux adaptivedemux2 hls dash
  pbtypes
"
for name in $GST_PLUGINS; do
    p="$GST_SRC/libgst$name.dylib"
    [ -f "$p" ] && cp "$p" "$GST_DEST/" || info "Skipping missing GStreamer plugin: $name"
done

# ---------------------------------------------------------------------------
# 4. GDK-Pixbuf loaders (for album art / JPEG / PNG in GdkTexture)
# ---------------------------------------------------------------------------
info "Copying GDK-Pixbuf loaders..."
PB_CACHE_REL=""
PB_ARGS=""
GDK_PIXBUF_PREFIX="$(brew --prefix gdk-pixbuf 2>/dev/null || echo "$BREW_PREFIX")"
PB_VER="$(find -L "$GDK_PIXBUF_PREFIX/lib/gdk-pixbuf-2.0" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | head -1 | xargs basename 2>/dev/null)"
if [ -n "$PB_VER" ]; then
    PB_SRC="$GDK_PIXBUF_PREFIX/lib/gdk-pixbuf-2.0/$PB_VER/loaders"
    PB_DEST="$RESOURCES/lib/gdk-pixbuf-2.0/$PB_VER/loaders"
    PB_CACHE="$RESOURCES/lib/gdk-pixbuf-2.0/$PB_VER/loaders.cache"
    PB_CACHE_REL="lib/gdk-pixbuf-2.0/$PB_VER/loaders.cache"
    if [ -d "$PB_SRC" ]; then
        mkdir -p "$PB_DEST"
        cp "$PB_SRC"/*.so    "$PB_DEST/" 2>/dev/null || true
        cp "$PB_SRC"/*.dylib "$PB_DEST/" 2>/dev/null || true
        for p in "$PB_DEST"/*; do
            [ -f "$p" ] && PB_ARGS="$PB_ARGS -x $p"
        done
    fi
fi

# ---------------------------------------------------------------------------
# 5. GIO modules (TLS backend for libsoup HTTPS requests)
# ---------------------------------------------------------------------------
info "Copying GIO modules..."
GIO_ARGS=""
GIO_DEST="$RESOURCES/lib/gio/modules"
GLIB_NETWORKING_PREFIX="$(brew --prefix glib-networking 2>/dev/null || true)"
if [ -n "$GLIB_NETWORKING_PREFIX" ] && [ -d "$GLIB_NETWORKING_PREFIX/lib/gio/modules" ]; then
    mkdir -p "$GIO_DEST"
    cp "$GLIB_NETWORKING_PREFIX/lib/gio/modules"/*.so "$GIO_DEST/" 2>/dev/null || true
    for p in "$GIO_DEST"/*.so; do
        [ -f "$p" ] && GIO_ARGS="$GIO_ARGS -x $p"
    done
fi

# ---------------------------------------------------------------------------
# 6. Bundle all dylibs recursively
# ---------------------------------------------------------------------------
info "Bundling dylibs (may take a while)..."
GST_ARGS=""
for p in "$GST_DEST"/*.dylib; do
    [ -f "$p" ] && GST_ARGS="$GST_ARGS -x $p"
done

# shellcheck disable=SC2086
dylibbundler -b -cd \
    -x "$MACOS_DIR/cassette" \
    $GST_ARGS \
    $PB_ARGS \
    $GIO_ARGS \
    -d "$FRAMEWORKS/" \
    -p "@executable_path/../Frameworks/" \
    -s "$BREW_PREFIX/lib"

for p in "$GST_DEST"/*.dylib; do
    [ -f "$p" ] && install_name_tool -id "@executable_path/../Resources/lib/gstreamer-1.0/$(basename "$p")" "$p" 2>/dev/null || true
done
for p in "$RESOURCES"/lib/gdk-pixbuf-2.0/*/loaders/* "$GIO_DEST"/*.so; do
    if [ -f "$p" ]; then
        rel="${p#$RESOURCES/}"
        install_name_tool -id "@executable_path/../Resources/$rel" "$p" 2>/dev/null || true
    fi
done

# ---------------------------------------------------------------------------
# 7. Build module caches
# ---------------------------------------------------------------------------
if [ -n "$PB_CACHE_REL" ] && [ -d "$PB_DEST" ]; then
    info "Creating GDK-Pixbuf loader cache..."
    PB_LOADER_REL="lib/gdk-pixbuf-2.0/$PB_VER/loaders"
    GDK_PIXBUF_MODULEDIR="$PB_SRC" \
        gdk-pixbuf-query-loaders "$PB_SRC"/* \
        | sed "s#\"$PB_SRC/#\"@executable_path/../Resources/$PB_LOADER_REL/#" \
        > "$PB_CACHE"
fi

if [ -d "$GIO_DEST" ]; then
    info "Creating GIO module cache..."
    gio-querymodules "$GIO_DEST"
fi

# ---------------------------------------------------------------------------
# 8. GSettings schemas (only what GTK4/Adwaita/app need)
# ---------------------------------------------------------------------------
info "Bundling GSettings schemas..."
SCHEMAS="$RESOURCES/share/glib-2.0/schemas"
mkdir -p "$SCHEMAS"
SRC_SCHEMAS="$BREW_PREFIX/share/glib-2.0/schemas"
for pat in "org.gtk.gtk4.*" "org.gtk.Settings.*" "org.gnome.desktop.*" "org.gnome.system.locale*"; do
    for f in "$SRC_SCHEMAS"/$pat; do
        [ -f "$f" ] && cp "$f" "$SCHEMAS/"
    done
done
cp "$PROJECT_ROOT/data/space.rirusha.Cassette.gschema.xml" "$SCHEMAS/"
glib-compile-schemas "$SCHEMAS/"

# ---------------------------------------------------------------------------
# 9. Icon themes (scalable + symbolic only to keep size reasonable)
# ---------------------------------------------------------------------------
info "Bundling icon themes..."
ICONS="$RESOURCES/share/icons"
mkdir -p "$ICONS"

for theme in hicolor Adwaita; do
    SRC="$BREW_PREFIX/share/icons/$theme"
    [ -d "$SRC" ] || continue
    DST="$ICONS/$theme"
    mkdir -p "$DST"
    [ -f "$SRC/index.theme" ] && cp "$SRC/index.theme" "$DST/"
    for sub in scalable symbolic; do
        [ -d "$SRC/$sub" ] && cp -r "$SRC/$sub" "$DST/"
    done
    gtk4-update-icon-cache -f "$DST" 2>/dev/null || true
done

# App icon (also fixes About dialog + status page icons)
mkdir -p "$ICONS/hicolor/scalable/apps" "$ICONS/hicolor/symbolic/apps"
cp "$PROJECT_ROOT/data/icons/hicolor/scalable/apps/space.rirusha.Cassette.svg" \
   "$ICONS/hicolor/scalable/apps/"
cp "$PROJECT_ROOT/data/icons/hicolor/symbolic/apps/space.rirusha.Cassette-symbolic.svg" \
   "$ICONS/hicolor/symbolic/apps/"
gtk4-update-icon-cache -f "$ICONS/hicolor" 2>/dev/null || true

# ---------------------------------------------------------------------------
# 10. ICNS icon
# ---------------------------------------------------------------------------
info "Creating ICNS icon..."
SVG="$PROJECT_ROOT/data/icons/hicolor/scalable/apps/space.rirusha.Cassette.svg"
TMP_DIR="$(mktemp -d)"
ICONSET="$TMP_DIR/Cassette.iconset"
mkdir -p "$ICONSET"

for size in 16 32 128 256 512; do
    rsvg-convert -w "$size"         -h "$size"         -o "$ICONSET/icon_${size}x${size}.png"    "$SVG"
    rsvg-convert -w "$((size * 2))" -h "$((size * 2))" -o "$ICONSET/icon_${size}x${size}@2x.png" "$SVG"
done
if ! iconutil -c icns "$ICONSET" -o "$RESOURCES/cassette.icns" 2>/dev/null; then
    TIFFS=""
    for size in 16 32 128 256 512; do
        tiff="$TMP_DIR/icon_${size}.tiff"
        sips -s format tiff "$ICONSET/icon_${size}x${size}.png" --out "$tiff" >/dev/null
        TIFFS="$TIFFS $tiff"
    done
    # shellcheck disable=SC2086
    tiffutil -cat $TIFFS -out "$TMP_DIR/cassette.tiff" >/dev/null
    tiff2icns "$TMP_DIR/cassette.tiff" "$RESOURCES/cassette.icns"
fi
[ -f "$RESOURCES/cassette.icns" ] || die "Failed to create cassette.icns"
ICON_WIDTH="$(sips -g pixelWidth "$RESOURCES/cassette.icns" | awk '/pixelWidth/ {print $2; exit}')"
[ "${ICON_WIDTH:-0}" -ge 512 ] || die "cassette.icns is too small (${ICON_WIDTH:-unknown}px)"
rm -rf "$TMP_DIR"

# ---------------------------------------------------------------------------
# 11. Info.plist
# ---------------------------------------------------------------------------
info "Creating Info.plist..."
VERSION="$(grep "^  version:" "$PROJECT_ROOT/meson.build" | sed "s/.*'\(.*\)'.*/\1/")"
cat > "$CONTENTS/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>               <string>Cassette</string>
  <key>CFBundleDisplayName</key>        <string>Cassette</string>
  <key>CFBundleIdentifier</key>         <string>space.rirusha.Cassette</string>
  <key>CFBundleVersion</key>            <string>$VERSION</string>
  <key>CFBundleShortVersionString</key> <string>$VERSION</string>
  <key>CFBundlePackageType</key>        <string>APPL</string>
  <key>CFBundleExecutable</key>         <string>cassette-launcher</string>
  <key>CFBundleIconFile</key>           <string>cassette.icns</string>
  <key>NSHighResolutionCapable</key>    <true/>
  <key>NSHumanReadableCopyright</key>   <string>© 2023-2024 Vladimir Vaskov</string>
  <key>LSMinimumSystemVersion</key>     <string>12.0</string>
  <key>NSPrincipalClass</key>           <string>NSApplication</string>
  <key>NSSupportsAutomaticGraphicsSwitching</key><true/>
</dict>
</plist>
EOF

# ---------------------------------------------------------------------------
# 12. Launcher script (sets env, then execs the real binary)
# ---------------------------------------------------------------------------
info "Creating launcher script..."
LAUNCHER="$MACOS_DIR/cassette-launcher"

cat > "$LAUNCHER" << 'LAUNCHER_BODY'
#!/bin/sh
BUNDLE="$(cd "$(dirname "$0")/../.." && pwd)"
RES="$BUNDLE/Contents/Resources"
export XDG_DATA_DIRS="$RES/share"
export GSETTINGS_SCHEMA_DIR="$RES/share/glib-2.0/schemas"
export GST_PLUGIN_PATH="$RES/lib/gstreamer-1.0"
export GST_REGISTRY_FORK=no
[ -d "$RES/lib/gio/modules" ] && export GIO_MODULE_DIR="$RES/lib/gio/modules"
LAUNCHER_BODY

if [ -n "$PB_CACHE_REL" ]; then
    # shellcheck disable=SC2016
    printf '[ -f "$RES/%s" ] && export GDK_PIXBUF_MODULE_FILE="$RES/%s"\n' "$PB_CACHE_REL" "$PB_CACHE_REL" >> "$LAUNCHER"
    # shellcheck disable=SC2016
    printf '[ -d "$RES/lib/gdk-pixbuf-2.0/%s/loaders" ] && export GDK_PIXBUF_MODULEDIR="$RES/lib/gdk-pixbuf-2.0/%s/loaders"\n' "$PB_VER" "$PB_VER" >> "$LAUNCHER"
fi

# shellcheck disable=SC2016
printf 'exec "$BUNDLE/Contents/MacOS/cassette" "$@"\n' >> "$LAUNCHER"
chmod +x "$LAUNCHER"

# ---------------------------------------------------------------------------
# 13. Verify and ad-hoc sign
# ---------------------------------------------------------------------------
# dylibbundler adds one LC_RPATH per -x binary. Normalize every loadable
# module too, because dyld rejects duplicate LC_RPATH values while dlopen-ing.
info "Normalizing LC_RPATH entries..."
for f in "$MACOS_DIR/cassette" "$FRAMEWORKS"/*.dylib "$GST_DEST"/*.dylib "$RESOURCES"/lib/gdk-pixbuf-2.0/*/loaders/* "$GIO_DEST"/*.so; do
    is_macho "$f" && normalize_rpath "$f" "@executable_path/../Frameworks/"
done

info "Checking for non-portable Homebrew library references..."
BAD_REFS="$(mktemp)"
for f in "$MACOS_DIR/cassette" "$FRAMEWORKS"/*.dylib "$GST_DEST"/*.dylib "$RESOURCES"/lib/gdk-pixbuf-2.0/*/loaders/* "$GIO_DEST"/*.so; do
    [ -f "$f" ] || continue
    otool -L "$f" 2>/dev/null | grep -E "$BREW_PREFIX|/usr/local/(Cellar|opt|lib)" >> "$BAD_REFS" || true
    list_rpaths "$f" 2>/dev/null | grep -E "$BREW_PREFIX|/usr/local/(Cellar|opt|lib)" >> "$BAD_REFS" || true
done
if [ -s "$BAD_REFS" ]; then
    cat "$BAD_REFS" >&2
    rm -f "$BAD_REFS"
    die "Bundle still contains Homebrew paths"
fi
rm -f "$BAD_REFS"

sign_macho() {
    f="$1"
    is_macho "$f" || return 0
    codesign --force --sign - "$f" >/dev/null
}

info "Ad-hoc signing nested Mach-O files..."
xattr -cr "$APP_BUNDLE" 2>/dev/null || true
for f in "$FRAMEWORKS"/*.dylib "$GST_DEST"/*.dylib "$RESOURCES"/lib/gdk-pixbuf-2.0/*/loaders/* "$GIO_DEST"/*.so "$MACOS_DIR/cassette"; do
    sign_macho "$f"
done

info "Ad-hoc signing app bundle..."
codesign --force --sign - "$APP_BUNDLE" >/dev/null

# ---------------------------------------------------------------------------
echo ""
echo "Bundle created: $APP_BUNDLE"
echo "To run:         open '$APP_BUNDLE'"
echo "To install:     cp -r '$APP_BUNDLE' /Applications/"
