<h1 align="center">
  <img src="data/icons/hicolor/scalable/apps/io.github.Rirusha.Cassette.svg" alt="Cassette"/>
  <br/>
  Cassette
</h1>

<p align="center">
    GTK4/Adwaita приложение, которое позволит вам использовать Я.Музыку на Linux.
</p>

<br/>

<p align="center">
  <a href="https://stopthemingmy.app">
    <img src="https://stopthemingmy.app/badge.svg"/>
  </a>
</p>

<p align="center">
  <a href="https://flathub.org/apps/details/io.github.Rirusha.Cassette">
      <img width="200" src="https://flathub.org/assets/badges/flathub-badge-en.png" alt="Download on Flathub">
  </a>
</p>

<p align="center">
    <img src="data/images/first.png" alt="Screenshot"/>
</p>

## План основных версий
* [ ] 0.2: Моя волна
* [ ] 0.3: Альбомы и исполнители
* [ ] 0.4: Поиск по сервису
* [ ] 0.5: Подкасты и книги

Все запланированные фичи можете [посмотреть в бэклоге](https://github.com/users/Rirusha/projects/2)

## Установка
### Через репозиторий...
Приложение Cassette доступно здесь:

[![Packaging status](https://repology.org/badge/vertical-allrepos/cassette.svg)](https://repology.org/project/cassette/versions)
### ALT Sisyphus
```
apt-get install cassette
```
### ... или используя flatpak
Вы можете скачать по [ссылке](https://flathub.org/apps/details/io.github.Rirusha.Cassette) или используя терминал
```
flatpak install flathub io.github.Rirusha.Cassette
```

### Сборка из исходного кода

Зависимости:
* ```gtk4```, version >= 4.5
* ```libadwaita-1```, version >= 1.4
* ```libsoup-3.0```
* ```gdk-pixbuf-2.0```
* ```json-glib-1.0```
* ```sqlite3```
* ```gee-0.8```
* ```libxml-2.0```
* ```gstreamer-1.0```
* ```webkitgtk-6.0```
* ```gio-2.0```

Утилиты для сборки:
* ```meson```
* ```ninja```
* ```cmake```
* ```blueprint-compiler```
* ```gcc```
* ```valac```
* ```pkg```
* ```appstream-utils```

Сборка:
```
meson setup builddir
ninja -C builddir test
ninja -C builddir install
```

## Полезные ссылки
* Телеграм-канал с девлогами: https://t.me/CassetteGNOME_Devlog
* Чат с обсуждением новых фичей и проблем: https://t.me/CassetteGNOME_Discussion
* Сообщить об ошибке: https://github.com/Rirusha/Cassette/issues

## Поддержка
Вы можете поддержать несколькими способами:
* Создать ишью с проблемой или предложением по улучшению;
* Сделать pul request с фиксом или добавлением функционала;
* Поддержать рублём (Просьба указывать в "Сообщении получателю" свой никнейм при отправлении через Тинькофф):
<p>
  <a href="https://www.tinkoff.ru/cf/21GCxLuFuE9">
      <img height="36" src="https://github.com/Rirusha/Cassette/assets/95986183/87496207-aa1c-40fc-a511-57bac188bc72" alt="Tinkoff">
  </a>
</p>
<p>
  <a href="https://boosty.to/rirusha/donate">
      <img height="36" src="https://github.com/Rirusha/Cassette/assets/95986183/313ee5af-d374-4f95-af62-9445d1c27347" alt="boosty.to">
  </a>
</p>

## Благодарность
Спасибо [MarshalX](https://github.com/MarshalX). Библиотека [yandex-music-api](https://github.com/MarshalX/yandex-music-api) была использована в качестве документации к api.

#### Cassette - неофициальный клиент, не связан с компанией Яндекс и не одобрен ей
