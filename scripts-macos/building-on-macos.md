# Building Cassette on macOS

> Tested on macOS 15+ (Apple Silicon). Intel Macs should work the same way.

## Prerequisites

Install build dependencies via Homebrew:

```sh
brew install \
  meson ninja pkg-config \
  vala blueprint-compiler \
  gtk4 libadwaita \
  libgee libsoup json-glib \
  gstreamer \
  desktop-file-utils
```

## One-time setup

### 1. Fix Vala vapi search path

Homebrew installs `.vapi` files to `share/vala/vapi/`, but `valac` looks in
`share/vala-0.56/vapi/`. Run this once after installing vala:

```sh
VALA_VERSION=$(valac --version | awk '{print $2}')
for f in /opt/homebrew/share/vala/vapi/*; do
  name=$(basename "$f")
  target="/opt/homebrew/Cellar/vala/${VALA_VERSION}/share/vala-${VALA_VERSION%.*}/vapi/$name"
  [ ! -e "$target" ] && ln -s "$f" "$target"
done
```

### 2. GStreamer plugin directory without GTK3 sink

GTK3 and GTK4 define conflicting Objective-C classes. GStreamer ships a GTK3
sink plugin (`libgstgtk.dylib`) that triggers the conflict. Create a filtered
plugin directory:

```sh
mkdir -p /opt/homebrew/lib/gstreamer-1.0-gtk4
for f in /opt/homebrew/Cellar/gstreamer/*/lib/gstreamer-1.0/libgst*.dylib; do
  name=$(basename "$f")
  [ "$name" != "libgstgtk.dylib" ] && \
    ln -sf "$f" "/opt/homebrew/lib/gstreamer-1.0-gtk4/$name"
done
```

## Configure

```sh
meson setup build -Dwith_webkit=false
```

> `webkitgtk-6.0` is not available in Homebrew, so webkit auth is disabled.
> Use token-based auth instead.

## Build

```sh
# GIR files are in a non-standard location on macOS
export XDG_DATA_DIRS=/opt/homebrew/share

# metainfo.xml must be built before resources (missing dependency in meson.build)
ninja -C build "data/space.rirusha.Cassette.Devel.metainfo.xml"
ninja -C build src/cassette
```

### Compile GSettings schema (first build only)

```sh
mkdir -p build/schemas
cp data/gschema.xml build/schemas/space.rirusha.Cassette.Devel.gschema.xml
glib-compile-schemas build/schemas
```

## Run

Use the provided script:

```sh
./run.sh
```

Or set the environment manually:

```sh
XDG_DATA_DIRS=/opt/homebrew/share \
GSETTINGS_SCHEMA_DIR=build/schemas \
GST_PLUGIN_PATH=/opt/homebrew/lib/gstreamer-1.0-gtk4 \
GST_REGISTRY_FORK=no \
./build/src/cassette
```

## Known issues and patches

### libtape API renames

The `libtape` subproject (pulled from `main`) renamed properties in `Tape.Client`:

| Old name | New name |
|---|---|
| `.cachier` | `.cm` |
| `.yam_helper` | `.ym` |

If you see build errors like `The name 'cachier' does not exist in the context of 'Tape.Client'`,
apply this patch:

```sh
sed -i '' 's/\.cachier\./.cm./g; s/\.yam_helper\./.ym./g' \
  src/ui/auth.vala \
  src/ui/account/account-button.vala \
  src/ui/account/account-info-dialog.vala
```

### Vala 0.56: `token` property not writable

Vala 0.56 generates `G_PARAM_READABLE`-only for `private set construct` properties,
breaking `g_object_new()` calls. In
`subprojects/libtape/lib/yandex-music/yandex-music.vala`, change:

```diff
-    public string token { internal get; private set construct; default = ""; }
+    public string token { internal get; set construct; default = ""; }
```

### Expected harmless warnings

- **GTK CSS theme warnings** — GTK4's default theme has minor CSS issues on macOS, does not affect functionality.
