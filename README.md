README language: \
[![En](https://img.shields.io/badge/en-green)](README.md)
[![Ru](https://img.shields.io/badge/ru-gray)](docs/README-ru.md)

<div align="center">
  <h1>
    <img
      src="data/icons/hicolor/scalable/apps/io.github.Rirusha.Cassette.svg"
      height="64"
    />
    Cassette
  </h1>

  <a href="https://stopthemingmy.app">
    <img src="https://stopthemingmy.app/badge.svg"/>
  </a>

  <a href="https://t.me/CassetteGNOME_Devlog">
    <img alt="Static Badge" src="https://img.shields.io/badge/Channel-blue?style=flat&logo=telegram">
  </a>

  <a href="https://t.me/CassetteGNOME_Devlog">
    <img alt="Static Badge" src="https://img.shields.io/badge/Chat-blue?style=flat&logo=telegram">
  </a>
</div>

<div align="center"><h4>GTK4/Adwaita application that allows you to use Yandex Music service on Linux operating systems.</h4></div>

<div align="center">
  <img src="data/images/1-liked.png" alt="Preview"/>
</div>

## Install

**Flathub**

<a href="https://flathub.org/apps/details/io.github.Rirusha.Cassette">
  <img width='240' alt='Download on Flathub' src='https://flathub.org/assets/badges/flathub-badge-en.svg'/>
</a>

```shell
flatpak install io.github.Rirusha.Cassette
```

**Distribution repositories**

[![Packaging status](https://repology.org/badge/vertical-allrepos/cassette.svg)](https://repology.org/project/cassette/versions)

### ALT Linux
```shell
su -
apt-get install cassette
```

### Arch Linux

> Most AUR Helpers support Pacman-style flags, for example, yay.

#### yay
```shell
yay -S cassette
```

#### pamac
```shell
pamac install cassette
```

### NixOS Unstable	
```shell
nix-shell -p cassette
```

## Building

#### Dependencies:

* `gtk4`, version: `>= 4.14`
* `libadwaita-1`, version: `>= 1.5`
* `libsoup-3.0`
* `gdk-pixbuf-2.0`
* `json-glib-1.0`
* `sqlite3`
* `gee-0.8`
* `libxml-2.0`
* `gstreamer-1.0`
* `webkitgtk-6.0`
* `gio-2.0`, version: `>= 2.72`
* `git`, only for `devel`

#### Building utilities:

* `meson`
* `ninja`
* `cmake`
* `blueprint-compiler`
* `gcc`
* `valac`
* `pkg`
* `appstream-utils`

#### latest

> Unstable features under development will not be available in this version.
```shell
meson setup builddir
```

#### devel

> In this version, all devel functions will be available, the application may work unstable.
```shell
meson setup builddir
meson configure -Dprofile=development builddir
```

### Testing
```shell
ninja -C builddir test
```

### Installation:
```shell
sudo ninja -C builddir install
```

### Delete:
```shell
sudo ninja -C builddir uninstall
```

## For developers

### Using Visual Studio Code
The repository has recommended extensions for checking and running the application with gdb.

### Dependencies

#### repository [gnome-nightly](https://wiki.gnome.org/Apps/Nightly):
```shell
flatpak remote-add --if-not-exists gnome-nightly https://nightly.gnome.org/gnome-nightly.flatpakrepo
```

#### To run
`org.gnome.Platform//master`
```shell
flatpak install org.gnome.Platform//master
```

#### To build
`org.gnome.Sdk//master` \
`org.freedesktop.Sdk.Extension.vala//23.08beta`
```shell
flatpak install org.gnome.Sdk//master org.freedesktop.Sdk.Extension.vala//23.08beta
```

## Support

You can support in several ways:
- Create an issue with a problem or a suggestion for improvement
- Submit a merge request with a fix or new functionality
- Support financially (Please include your nickname in the "Message to the recipient" when sending via T-Bank)

<br>

<div align="center">
  <a href="https://www.tbank.ru/cf/21GCxLuFuE9">
    <img height="200" src="data/assets/tbank.png" alt="Tinkoff">
  </a>
  <a href="https://boosty.to/rirusha/donate">
    <img height="200" src="data/assets/boosty.png" alt="boosty.to">
  </a>
</div>

## Gratitude
Thank you [MarshalX](https://github.com/MarshalX ). The [yandex-music-api](https://github.com/MarshalX/yandex-music-api) library was used as api documentation.

> Cassette is an unofficial client, not affiliated with Yandex and not approved by it.
