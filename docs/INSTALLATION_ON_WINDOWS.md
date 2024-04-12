# Установка в Windows (WSL)

> [!WARNING]
> Данный способ использует WSL (Windows Subsystem for Linux) и не гарантирует полную работоспособность приложения.

## Установка системы

Перед установкой приложения необходимо поставить подсистему Ubuntu.

#### В PowerShell:
```
wsl --install Ubuntu
```

После этого в меню «Пуск» появится приложение `ubuntu`, заходим. Откроется терминал и начнётся процесс донастройки системы, по окончании вводим логин и пароль нового пользователя.

Далее обновляем систему и устанавливаем менеджер приложений Flatpak.

#### В терминале Ubuntu:
```
sudo apt update
sudo apt upgrade
sudo apt install flatpak
```

Перезапускаем WSL:

#### В PowerShell:
```
wsl -t Ubuntu
```

## Установка приложения

### latest версия

> [!NOTE]
> Данная версия является стабильной и может не содержать самых новых функций.

Подключаем репозиторий `flathub` и устанавливаем приложение:

#### В терминале Ubuntu:
```
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sudo flatpak install io.github.Rirusha.Cassette
```

> [!NOTE]
> После перезагрузки Windows в меню «Пуск» появиться ярлык приложения Cassette, но его также можно запустить из терминала Ubuntu так:
> ```
> flatpak run io.github.Rirusha.Cassette
> ```

### nightly версия

> [!WARNING]
> Данная версия каждые сутки собирается и обновляется из dev ветки приложения, поэтому может оказаться нестабильной.

Подключаем репозитории и устанавливаем приложение:

#### В терминале Ubuntu:

<!-- Подключаем репоизторий `gnome-nightly`:

```
sudo flatpak remote-add --if-not-exists gnome-nightly https://nightly.gnome.org/gnome-nightly.flatpakrepo
``` -->

Подключаем репозиторий `cassette-nightly`:

```
sudo flatpak remote-add --if-not-exists cassette-nightly https://rirusha.github.io/Cassette/index.flatpakrepo
```

Устанавливаем зависимости и приложение:

```
sudo flatpak install org.gnome.Platform//46
sudo flatpak install cassette-nightly io.github.Rirusha.Cassette-Devel
```

> [!NOTE]
> После перезагрузки Windows в меню «Пуск» появиться ярлык приложения Cassette-Devel, но его также можно запустить из терминала Ubuntu так:
> ```
> flatpak run io.github.Rirusha.Cassette-Devel
> ```

