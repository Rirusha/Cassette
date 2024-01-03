![com github Rirusha Cassette](https://raw.githubusercontent.com/Rirusha/Cassette/master/data/icons/hicolor/scalable/apps/io.github.Rirusha.Cassette.svg)


# Cassette

GTK/Adwaita приложение, которое позволит вам использовать Я.Музыку на Linux.

## План обновлений
* [X] 0.1: Реализовать работу с плейлистами, проигрывание музыки, работу с очередью воспроизведения
* [ ] 0.2: Реализовать работу с исполнителями и альбомами, подкасты и книги
* [ ] 0.3: Реализовать поиск по сервису
* [ ] 0.4: Реализовать страницу "Главное"
* [ ] 0.5: Реализовать "Мою волну"
* [ ] 0.6: Реализовать компактный режим и Big Picture
* 0.x: …

## Установка
### Репозитории
Cassette доступен в репозиториях:

[![Packaging status](https://repology.org/badge/vertical-allrepos/cassette.svg)](https://repology.org/project/cassette/versions)
### ALT Sisyphus
```
apt-get install cassette
```
### Используя flatpak

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

Утилиты:
* ```meson```
* ```ninja```
* ```cmake```
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
* Чат в телеграме с обсуждением: https://t.me/CassetteGNOME_Discussion
* Сообщить об ошибке: https://github.com/Rirusha/Cassette/issues

## Спасибо
Спасибо [MarshalX](https://github.com/MarshalX). Библиотека [yandex-music-api](https://github.com/MarshalX/yandex-music-api) была использована в качестве документации к api.

#### Cassette - неофициальный клиент, не связан с компанией Яндекс и не одобрен ей
