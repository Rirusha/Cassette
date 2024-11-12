/* Copyright 2023-2024 Vladimir Vaskov
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Cassette.Client;
using Gee;

namespace Cassette {
    /**
     * Интерфейес инициализируемых виджетов. Такие виджеты зависят от id содержимого.
     */
    public interface Initable {
        /**
         * Id контента. Не ставится напрямую, используется метод {@link init_content}
         */
        protected abstract string content_id { get; set; }

        /**
         * Абстрактный метод инициализации контента.
         * Сюда могут входить дополнительные действия
         *
         * @param content_id    id инициализируемого контента
         */
        public abstract void init_content (string content_id);
    }

    /**
     * Перечисление с причинами блокировки виджета
     */
    public enum BlockReason {
        /**
         * Функционал не реализован
         */
        NOT_IMPLEMENTED,
        /**
         * Для работы функционала требуется выполнить авторизацию
         */
        NEED_AUTH,
        /**
         * Для работы функционала требуется активная подписка Букмейт
         */
        NEED_BOOKMATE
    }

    /**
     * Фукция блокировки виджета
     *
     * @param widget    блокируемый виджет
     * @param reason    причина блокировки
     */
    public static void block_widget (Gtk.Widget widget, BlockReason reason) {
        widget.sensitive = false;

        switch (reason) {
            case BlockReason.NOT_IMPLEMENTED:
                widget.tooltip_text = _("Not implemented yet");
                if (application.is_devel) {
                    widget.sensitive = true;
                }
                break;

            case BlockReason.NEED_AUTH:
                widget.tooltip_text = _("Need authorization");
                break;

            case BlockReason.NEED_BOOKMATE:
                widget.tooltip_text = _("Need Bookmate subscription");
                break;

            default:
                assert_not_reached ();
        }
    }

    /**
     * Функция удобства для очистки ``Gtk.FlowBox``.
     */
    public void clear_flow_box (Gtk.FlowBox flow_box) {
        while (flow_box.get_last_child () != null) {
            flow_box.remove (flow_box.get_last_child ());
        }
    }

    /**
     * Открыть окно для добавления трека в плейлист
     *
     * @param track_info    трек, который нужно добавить
     */
    public static void add_track_to_playlist (YaMAPI.Track track_info) {
        if (application.main_window != null) {
            var dialog = new PlaylistChooseDialog (track_info);
            dialog.present (application.main_window);
        }
    }

    public void remove_track_from_playlist (YaMAPI.Track track_info, YaMAPI.Playlist playlist_info) {
        int position = -1;
        for (int i = 0; i < playlist_info.tracks.size; i++) {
            if (track_info.id == playlist_info.tracks[i].id) {
                position = i;
                break;
            }
        }

        yam_talker.remove_tracks_from_playlist.begin (playlist_info.kind, position, playlist_info.revision);
    }

    /**
     * Переключить режим перемешивания на следующий.
     * ON -> OFF
     * OFF -> ON
     */
    public static void roll_shuffle_mode () {
        switch (player.shuffle_mode) {
            case Player.ShuffleMode.OFF:
                player.shuffle_mode = Player.ShuffleMode.ON;
                break;
            case Player.ShuffleMode.ON:
                player.shuffle_mode = Player.ShuffleMode.OFF;
                break;
        }
    }

    /**
     * Переключить режим повтора на следующий.
     * OFF -> REPEAT_ALL
     * REPEAT_ALL -> REPEAT_ONE
     * REPEAT_ONE -> OFF
     */
    public static void roll_repeat_mode () {
        switch (player.repeat_mode) {
            case Player.RepeatMode.OFF:
                if (player.mode is Player.Flow) {
                    player.repeat_mode = Player.RepeatMode.ONE;
                } else {
                    player.repeat_mode = Player.RepeatMode.QUEUE;
                }
                break;

            case Player.RepeatMode.QUEUE:
                player.repeat_mode = Player.RepeatMode.ONE;
                break;

            case Player.RepeatMode.ONE:
                player.repeat_mode = Player.RepeatMode.OFF;
                break;
        }
    }

    /**
     * Поместить ссылку на трек в буфер обмена
     *
     * @param track_info    объект трека, ссылка на который будет скопирована в буфер обмена
     */
    public static void track_share (Cassette.Client.YaMAPI.Track track_info) {
        string url = "https://music.yandex.ru/album/%s/track/%s?utm_medium=copy_link".printf (
            track_info.albums[0].id, track_info.id
        );

        Gdk.Display? display = Gdk.Display.get_default ();
        Gdk.Clipboard clipboard = display.get_clipboard ();
        clipboard.set (Type.STRING, url);
        application.show_message (_("Link copied to clipboard"));
    }

    /**
     * Поместить ссылку на плейлист в буфер обмена
     *
     * @param playlist_info объект плейлиста, ссылка на который будет скопирована в буфер обмена
     */
    public static void playlist_share (Cassette.Client.YaMAPI.Playlist playlist_info) {
        string url = "https://music.yandex.ru/users/%s/playlists/%s?utm_medium=copy_link".printf (
            playlist_info.owner.login, playlist_info.kind
        );

        Gdk.Display? display = Gdk.Display.get_default ();
        Gdk.Clipboard clipboard = display.get_clipboard ();
        clipboard.set (Type.STRING, url);
        application.show_message (_("Link copied to clipboard"));
    }

    /**
     * Асинхронная функция для показа трека по его id.
     *
     * @param track_id  id трека
     */
    public static async void show_track_by_id (string track_id) {
        threader.add (() => {
            var track_infos = yam_talker.get_tracks_info ({track_id});

            if (track_infos != null) {
                application.main_window.window_sidebar.show_track_info (track_infos[0]);
            }

            Idle.add (show_track_by_id.callback);
        });

        yield;
    }

    /**
     * Функция для формирования текстового представления времени.
     * Короткое представление:  66 -> 1:06
     * Длинное:                 Длительность: 1 мин.
     *
     * @param seconds   секунды
     * @param is_short  короткое ли представление нужно
     *
     * @return          строка представления
     */
    public static string sec2str (int seconds, bool is_short) {
        int minutes = (int) seconds / 60;
        int oth_seconds = (seconds - minutes * 60);

        string minutes_str = minutes.to_string ();
        string oth_seconds_str = oth_seconds.to_string ();

        if (is_short) {
            return @"$minutes_str:$(zfill (oth_seconds_str, 2))";
        } else {

            if (minutes > 60) {
                int hours = (int) minutes / 60;
                minutes -= hours * 60;

                string hours_str = hours.to_string ();
                minutes_str = minutes.to_string ();
                return _("Duration: %s h. %s min.").printf (hours_str, minutes_str);
            }
            return _("Duration: %s min.").printf (minutes_str);
        }
    }

    /**
     * Функция для формирования текстового представления времени.
     * ``ms2str (66110, true) ->  "1:06"`` 
     * ``ms2str (66110, false) -> "Длительность: 1 мин."`` 
     *
     * @param ms        миллисекунды
     * @param is_short  короткое ли представление нужно
     *
     * @return          строка представления
     */
    public static string ms2str (int64 ms, bool is_short) {
        int seconds = ms2sec (ms);
        return sec2str (seconds, is_short);
    }

    /**
     * Функция для заполнение строки символами слева.
     * ``zfill ("56", 5) -> "00056"`` 
     * ``zfill ("56", 2) -> "56"`` 
     * ``zfill ("56", 1) -> "56"`` 
     *
     * @param str   исходная строка
     * @param width целевая ширина
     *
     * @return      результат
     */
    public static string zfill (string str, int width) {
        if (str.length >= width) {
            return str;
        } else {
            int padding = width - str.length;
            return string.nfill (padding, '0') + str;
        }
    }

    /**
     * Функция для получения заполненного множества
     * ``range_set (1, 6, 1) -> {1, 2, 3, 4, 5}`` 
     *
     * @param start стартовое значение
     * @param end   целевое значение
     * @param step  размер шага
     *
     * @return      множество
     */
    public static HashSet<int> range_set (int start, int end, int step = 1) {
        var rng = new HashSet<int> ();
        for (int item = start; item < end; item += step) {
            rng.add (item);
        }
        return rng;
    }

    /**
     * Функция для поиска разницы численных множеств
     * ``difference ({1, 2, 3}, {2, 3, 4}) -> {1}`` 
     *
     * @param set_1 первое множество
     * @param set_2 второе множество
     *
     * @return      результирующее множество
     */
    public static HashSet<int> difference (HashSet<int> set_1, HashSet<int> set_2) {
        var out_set = new HashSet<int> ();
        foreach (int el in set_1) {
            if (!(el in set_2)) {
                out_set.add (el);
            }
        }
        return out_set;
    }

    /**
     * Функция для парсинга строки определенного вида в миллисекунды.
     * ``parse_time ("[2:23.24]") -> 143240`` 
     *
     * @param time_str  строка вида [hh:mm.ms]
     *
     * @return          миллисекунды
     */
    public static int64 parse_time (owned string time_str) {
        time_str.strip ();
        time_str = time_str[1:time_str.length - 1];

        string[] data_min_secms = time_str.split (":");
        string[] data_sec_ms = data_min_secms[1].split (".");

        int64 mins_ms = int64.parse (data_min_secms[0], 10) * 60000;
        int64 secs_ms = int64.parse (data_sec_ms[0], 10) * 1000;
        int64 pure_ms = int64.parse (data_sec_ms[1], 10) * 10;

        return mins_ms + secs_ms + pure_ms;
    }

    /**
     * Функция для получения человеческого "когда?".
     * get_when ("2006-04-30T03:01:38") -> "30.04.2006"
     * get_when ("2006-04-30T03:01:38") -> "yesterday"
     *
     * @param iso8601_datetime_str  временная метка в формате iso8601
     *
     * @return                      человеческое "когда?"
     */
    public static string get_when (string iso8601_datetime_str) {
        var dt = new DateTime.from_iso8601 (iso8601_datetime_str, null);
        var now_dt = new DateTime.now ();

        var days = (int) (now_dt.difference (dt) / TimeSpan.DAY);

        if (days < 1) {
            return _("today");
        } else if (days < 2) {
            return _("yesterday");
        } else {
            return dt.format ("%x").replace ("/", ".");
        }
    }

    /**
     * Функция для создания отступов между тысячами в числе в строковом формате.
     * prettify_num (5124421) -> "5 124 421"
     *
     * @param num   число
     *
     * @return      преобразованное число в строковом формате
     */
    public static string prettify_num (int num) {
        string num_str = num.to_string ();

        return prettify_chunk (num_str, num_str.length - 3, "");
    }

    /**
     * Функция для создания отступов между тысячами одной секции.
     *
     * @param num_str   строка, содержащая числовое значение
     * @param start_pos начальная позиция куска в строке
     * @param res_str   рекурсивный аргумент 
     *
     * @return          строка с отступами
     */
    static string prettify_chunk (string num_str, int start_pos, string res_str) {
        if (start_pos == -3) {
            return res_str;
        }

        int end_pos = start_pos + 3;

        if (start_pos < 0) {
            start_pos = 0;
        }

        return prettify_chunk (num_str, start_pos - 3, num_str[start_pos:end_pos] + " " + res_str);
    }

    /**
     * Функция для нахождения меньшего значения из двух ``double`` чисел
     *
     * @param a первое число
     * @param b второе число
     *
     * @return  меньшее из двух чисел
     */
    static double min (double a, double b) {
        return a < b ? a : b;
    }

    /**
     * Функция для нахождения большего значения из двух ``double`` чисел
     *
     * @param a первое число
     * @param b второе число
     *
     * @return  большее из двух чисел
     */
    static double max (double a, double b) {
        return a > b ? a : b;
    }
}
