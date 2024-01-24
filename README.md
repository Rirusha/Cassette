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

## Последний релиз: 0.1.1
* Добавлена новая авторизация через WebView;
* Исправлена ошибка при некорректном выводе кода ошибки при попытке открыть, например, закрытый или несуществующий плейлист;
* Исправлено появление предупреждение в терминал о невозможности прочитать файл страниц при условии, что страницы ещё не были созданы;
* Исправлена ошибка с некорректной записью в логи ошибки апи;
* Исправлена невозможность добавлять любимые треки других пользователей как страницу (всё же такой же плейлист, нет плейлистному расизму);
* Исправлена ошибка с появлением подкастов и книг в любимых треках;
* Исправлена некорректная работа переключения трека в очереди при различных состояниях повтора;
* Исправлена ошибка https://t.me/CassetteGNOME_Discussion/42.

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

## Поддержка
Вы можете поддержать несколькими способами:
* Создать ишью с проблемой или предложением по улучшению;
* Сделать pul request с фиксом или добавлением функционала;
* [Поддержать рублём](https://www.tinkoff.ru/cf/21GCxLuFuE9) (Просьба указывать в сообщении свой никнейм, иначе я не смогу добавить вас в соответствующий блок окна About);
* Похвалить автора в телеграм-чате :3.

## Благодарность
Спасибо [MarshalX](https://github.com/MarshalX). Библиотека [yandex-music-api](https://github.com/MarshalX/yandex-music-api) была использована в качестве документации к api.

#### Cassette - неофициальный клиент, не связан с компанией Яндекс и не одобрен ей
