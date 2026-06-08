<div align="center">
  <h1>
  <img src="data/icons/hicolor/scalable/apps/space.rirusha.Cassette.svg" width="128">
  </br>
  Cassette
  </h1>
  <p>Unofficial Yandex Music client</p>

  <a href="https://stopthemingmy.app">
    <img src="https://stopthemingmy.app/badge.svg"/>
  </a>

  <div>
  <a href="https://alt-gnome.altlinux.team/matrix-to/#/#cassette-discussion:altlinux.org">
    <img alt="Link to matrix chat" src="https://img.shields.io/badge/Чат-black?style=flat&logo=matrix">
  </a>

  <a href="https://translate.alt-gnome.ru/engage/cassette/">
    <img src="https://translate.alt-gnome.ru/widget/cassette/cassette/svg-badge.svg" alt="Translation state">
  </a>

  <a href="https://t.me/CassetteGNOME_Devlog">
    <img alt="Link to devlog telegram channel" src="https://img.shields.io/badge/Канал-blue?style=flat&logo=telegram">
  </a>

  <a href="https://t.me/CassetteGNOME_Discussion">
    <img alt="Link to telegram chat" src="https://img.shields.io/badge/Чат-blue?style=flat&logo=telegram">
  </a>
  </div>
</div>

<div align="center"><h4>GTK4/Adwaita application that allows you to use Yandex Music service on Linux operating systems.</h4></div>

<div align="center">
  <img src="data/images/1-liked-view.png" alt="Preview"/>
</div>

## Install

**Flathub:**

<a href="https://flathub.org/apps/details/space.rirusha.Cassette">
  <img width='240' alt='Download on Flathub' src='https://flathub.org/assets/badges/flathub-badge-en.svg'/>
</a>

**Distribution repositories:**

[![Packaging status](https://repology.org/badge/vertical-allrepos/cassette.svg)](https://repology.org/project/cassette/versions)

## Building

You can use [GNOME Builder](https://flathub.org/en/apps/org.gnome.Builder), [VSC/odium with `flatpak` plugin](https://marketplace.visualstudio.com/items?itemName=bilelmoussaoui.flatpak-vscode) or just via [flatpak-builder](https://docs.flatpak.org/en/latest/first-build.html#build-and-install)

Also you can build via meson with manual dependency resolving. You can read about build options [here](meson.options)

### Platforms

Cassette available on many platforms besides Linux. They are located in the corresponding directories in the root of the repository. `windows` and `macos` presented for now.

## Devel version

> This version is built and updated with every commit, so it may be unstable.

You need to add `cassette-nightly` and `gnome-nightly` repositories:

```shell
flatpak remote-add --if-not-exists gnome-nightly https://nightly.gnome.org/gnome-nightly.flatpakrepo
flatpak remote-add --if-not-exists cassette-nightly https://rirusha.space/nightly-repo.flatpakrepo
```

Install application:

```shell
flatpak install cassette-nightly space.rirusha.Cassette.Devel
```

## Libraries created during development

- [`libtape`](https://altlinux.space/rirusha/libtape) - Tape library for your Cassette application (Unofficial Yandex Music SDK)
- [`libcase`](https://altlinux.space/rirusha/libcase) - Library with various useful widgets

## Support

You can support in several ways:
- Create an issue with a problem or a suggestion for improvement
- Submit a merge request with a fix or new functionality
- Support financially (Please include your nickname in the "Message to the recipient" when sending via T-Bank)

Donate links (QR-codes also clickable!):
<details>
  <summary>T-Bank</summary>
  <a href="https://www.tbank.ru/cf/21GCxLuFuE9">
    <img alt="Link to T-Bank support" height="200" src="assets/tbank.png">
  </a>
</details>

<details>
  <summary>Boosty</summary>
  <a href="https://boosty.to/rirusha/donate">
    <img alt="Link to boosty support" height="200" src="assets/boosty.png">
  </a>
</details>

<br>

> [!IMPORTANT] 
> Cassette is an unofficial client, not affiliated with Yandex and not approved by it.
