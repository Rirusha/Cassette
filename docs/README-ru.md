Язык README: \
[![En](https://img.shields.io/badge/en-gray)](README.md)
[![Ru](https://img.shields.io/badge/ru-green)](docs/README-ru.md)

<div align="center">
  <h1>
    <img
      src="data/icons/hicolor/scalable/apps/space.rirusha.Cassette.svg"
      height="64"
    />
    Cassette
  </h1>

  <a href="https://stopthemingmy.app">
    <img src="https://stopthemingmy.app/badge.svg"/>
  </a>

  <a href="https://t.me/CassetteGNOME_Devlog">
    <img alt="Static Badge" src="https://img.shields.io/badge/Канал-blue?style=flat&logo=telegram">
  </a>

  <a href="https://t.me/CassetteGNOME_Devlog">
    <img alt="Static Badge" src="https://img.shields.io/badge/Чат-blue?style=flat&logo=telegram">
  </a>
</div>

<div align="center"><h4>GTK4/Adwaita приложение, которое позволит вам использовать Я.Музыку на Linux.</h4></div>

<div align="center">
  <img src="data/images/1-liked-view.png" alt="Preview"/>
</div>

## Установка

**Flathub:**

<a href="https://flathub.org/apps/details/space.rirusha.Cassette">
  <img width='240' alt='Скачать на Flathub' src='https://flathub.org/assets/badges/flathub-badge-en.svg'/>
</a>

```shell
flatpak install space.rirusha.Cassette
```

**Репозитории дистрибутивов:**

[![Состояние упаковки](https://repology.org/badge/vertical-allrepos/cassette.svg)](https://repology.org/project/cassette/versions)

### ALT Linux
```shell
su -
apt-get install cassette
```

### Arch Linux

> Большинство помощников AUR поддерживают флаги в стиле Pacman, например, yay.

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

## Сборка

#### Зависимости:

* `gtk4`, версия: `>= 4.14`
* `libadwaita-1`, версия: `>= 1.5`
* `libsoup-3.0`
* `gdk-pixbuf-2.0`
* `json-glib-1.0`
* `sqlite3`
* `gee-0.8`
* `libxml-2.0`
* `gstreamer-1.0`
* `webkitgtk-6.0`
* `gio-2.0`, версия: `>= 2.72`
* `git`, только для `devel`

#### Утилиты для сборки:

* `meson`
* `ninja`
* `cmake`
* `blueprint-compiler`
* `gcc`
* `valac`
* `pkg`
* `appstream-utils`

### ПредРелиз

> В данной версии будут недоступны нестабильные функции, находящиеся в разработке.
```shell
meson setup _build
```

### Флаг `is_devel`

> В данной версии будут доступны все функции, находящиеся в разработке.
```shell
meson setup _build -Dis_devel=true
```

#### Установка
```shell
sudo ninja install -C _build
```

#### Тестирование
```shell
ninja -C _build test
```

#### Удаление
```shell
sudo ninja uninstall -C _build
```

## Версия "В разработке"

> Эта версия обновляется после каждого изменения, так что она может быть нестабильна.

Нужно добавить `cassette-nightly` и `gnome-nightly` репозиторий:

```shell
flatpak remote-add --if-not-exists gnome-nightly https://nightly.gnome.org/gnome-nightly.flatpakrepo
flatpak remote-add --if-not-exists cassette-nightly https://rirusha.space/repos/cassette-nightly.flatpakrepo
```

Установка приложения:

```shell
flatpak install cassette-nightly space.rirusha.Cassette.Devel
```

## Для разработчиков

> Репозиторий имеет рекомендуемые расширения для разработки с Visual Studio Code.

### Зависимости

#### репозиторий [gnome-nightly](https://wiki.gnome.org/Apps/Nightly):
```shell
flatpak remote-add --if-not-exists gnome-nightly https://nightly.gnome.org/gnome-nightly.flatpakrepo
```

#### Для запуска 
`org.gnome.Platform//master`
```shell
flatpak install org.gnome.Platform//master
```

#### Для сборки
`org.gnome.Sdk//master` \
`org.freedesktop.Sdk.Extension.vala//23.08beta`
```shell
flatpak install org.gnome.Sdk//master org.freedesktop.Sdk.Extension.vala//23.08beta
```

## Поддержка

Вы можете поддержать несколькими способами:
- Создать issue с проблемой или предложением по улучшению
- Отправить merge request с фиксом или добавлением функционала
- Поддержать рублём (Просьба указывать в "Сообщении получателю" свой никнейм при отправлении через Т-Банк):

<br>

<div align="center">
  <a href="https://www.tbank.ru/cf/21GCxLuFuE9" style="margin-right: 100px;">
    <img height="200" src="../assets/tbank.png" alt="Tinkoff">
  </a>
  <a href="https://boosty.to/rirusha/donate">
    <img height="200" src="../assets/boosty.png" alt="boosty.to">
  </a>
</div>

## Благодарность
Спасибо [MarshalX](https://github.com/MarshalX). Библиотека [yandex-music-api](https://github.com/MarshalX/yandex-music-api) была использована в качестве документации к api.

> Внимание!
> Cassette - неофициальный клиент, не связан с компанией Яндекс и не одобрен ей.
