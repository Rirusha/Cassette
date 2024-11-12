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


using Gee;


namespace Cassette.Client {

    namespace YaMAPI {
        public const string API_FROM = "unofficial-client-own";
    }

    namespace YaMAPI.Rotor {
        namespace FeedbackType {
            public const string RADIO_STARTED = "radioStarted";
            public const string TRACK_STARTED = "trackStarted";
            public const string SKIP = "skip";
            public const string TRACK_FINISHED = "trackFinished";
            public const string RADIO_FINISHED = "radioFinished";
            public const string LIKE = "like";
            public const string UNLIKE = "unlike";
            public const string DISLIKE = "dislike";
            public const string UNDISLIKE = "undislike";
        }

        namespace StationType {
            public const string ON_YOUR_WAVE = "user:onyourwave";
            public const string COLLECTION = "personal:collection";
        }
    }

    /**
     * Enum with cover sizes
     */
    public enum CoverSize {
        SMALL = 75,
        BIG = 400
    }

    /**
     * Таймаут всех запросов
     */
    public const int TIMEOUT = 10;

    public static Cachier.Cachier cachier;
    public static Cachier.Storager storager;
    public static Threader threader;
    public static YaMTalker yam_talker;
    public static Player.Player player;
    public static Settings settings;

    /**
     * Получение кода языка для передачи в запросах api.
     * Получает язык из системы и делает "ru_RU.UTF-8" -> "ru" штуку
     */
    public static string get_language () {
        string? locale = Environment.get_variable ("LANG");

        if (locale == null) {
            return "en";
        }

        if ("." in locale) {
            locale = locale.split (".")[0];
        } else if ("@" in locale) {
            locale = locale.split ("@")[0];
        }

        if ("_" in locale) {
            locale = locale.split ("_")[0];
        }

        locale = locale.down ();

        if (locale == "c") {
            return "en";
        }

        return locale;
    }

    /**
     * Функция удобства для преобразования миллисекунд в секунды.
     *
     * @param ms    миллисекунды
     *
     * @return      секунды
     */
    public static int ms2sec (int64 ms) {
        return (int) (ms / 1000);
    }

    public static string get_context_type (HasID yam_obj) {
        if (yam_obj is YaMAPI.Playlist) {
            return "playlist";

        } else if (yam_obj is YaMAPI.Album) {
            return "album";

        } else if (yam_obj is YaMAPI.Artist) {
            return "artist";

        } else if (yam_obj is int) {
            return "search";

        } else {
            return "various";
        }
    }

    public static string? get_context_description (HasID yam_obj) {
        if (yam_obj is YaMAPI.Playlist) {
            return ((YaMAPI.Playlist) yam_obj).title;

        } else if (yam_obj is YaMAPI.Album) {
            return ((YaMAPI.Album) yam_obj).title;

        } else if (yam_obj is YaMAPI.Artist) {
            return ((YaMAPI.Artist) yam_obj).name;

        } else {
            return null;
        }
    }

    /**
     * Функция удобства. Получение текущей временной метки.
     */
    public static string get_timestamp () {
        return new DateTime.now_utc ().format_iso8601 ();
    }

    public bool get_debug_mode () {
        return settings.get_boolean ("debug-mode");
    }

    /**
     * Инициализация клиента. Создание синглтонов.
     */
    public static void init (bool is_devel) {
        settings = new Settings ("space.rirusha.Cassette.client");

        cachier = new Cachier.Cachier ();
        storager = new Cachier.Storager ();

        if (is_devel) {
            Logger.log_level = LogLevel.DEVEL;
        } else {
            settings.changed.connect ((key) => {
                if (key == "debug-mode") {
                    if (settings.get_boolean ("debug-mode")) {
                        Logger.log_level = LogLevel.DEBUG;
                    } else {
                        Logger.log_level = LogLevel.USER;
                    }
                }
            });
        }

        threader = new Threader ();
        yam_talker = new YaMTalker ();
        player = new Player.Player ();

        Mpris.init ();
    }

    /**
     * Ошибки клиента.
     */
    public errordomain ClientError {
        /**
         * Не получается спарсить ответ
         */
        PARSE_ERROR,
        /**
         * Не получается получить ответ
         */
        SOUP_ERROR,
        /**
         * Ответом пришла ошибка
         */
        ANSWER_ERROR,
        /**
         * Ошибка при авторизации
         */
        AUTH_ERROR
    }

    /**
     * Errors containing reasons why using the client is not possible
     */
     public errordomain CantUseError {
        /**
         * User hasn't Plus Subscription
         */
        NO_PLUS
    }

    /**
     * Утилиты, зависимые от типа.
     */
    public class TypeUtils<T> {
        /**
        * Перемешивание списка
        *
        * @param list   ссылка на список ``Gee.ArrayList``, который будет перемешан
        */
        public void shuffle (ref ArrayList<T> list) {
            for (int i = 0; i < list.size; i++) {
                int random_index = Random.int_range (0, list.size);
                T a = list[i];
                list[i] = list[random_index];
                list[random_index] = a;
            }
        }
    }

    /**
     * Утилиты, зависимые от типа.
     */
    public string strip (string str, char ch) {
        /**
            Delete `ch` from start and end of `str`
        */

        int start = 0;
        int end = str.length;

        while (str[start] == ch) {
            start++;
        }
        while (str[end - 1] == ch) {
            end--;
        }

        return str[start:end];
    }

    /**
     * Функция для перевода camelCase строки в kebab-case.
     * Входная строка должна быть корректной camelCase
     */
    public string camel2kebab (string camel_string) {
        var builder = new StringBuilder ();

        int i = 0;
        while (i < camel_string.length) {
            if (camel_string[i].isupper ()) {
                builder.append_c ('-');
                builder.append_c (camel_string[i].tolower ());

            } else {
                builder.append_c (camel_string[i]);
            }
            i += 1;
        }

        return builder.free_and_steal ();
    }

    /**
     * Функция для перевода kebab-case строки в camelCase.
     * Входная строка должна быть корректной kebab-case
     */
    public string kebab2camel (string kebab_string) {
        var builder = new StringBuilder ();

        int i = 0;
        while (i < kebab_string.length) {
            if (kebab_string[i] == '-') {
                i += 1;
                builder.append_c (kebab_string[i].toupper ());

            } else {
                builder.append_c (kebab_string[i]);
            }
            i += 1;
        }

        return builder.free_and_steal ();
    }

    /**
     * Функция для перевода kebab-case строки в snake_case.
     * Входная строка должна быть корректной kebab-case
     */
    public string kebab2snake (string kebab_string) {
        var builder = new StringBuilder ();

        int i = 0;
        while (i < kebab_string.length) {
            if (kebab_string[i] == '-') {
                builder.append_c ('_');

            } else {
                builder.append_c (kebab_string[i]);
            }
            i += 1;
        }

        return builder.free_and_steal ();
    }

    /**
     * Функция для перевода snake_case строки в kebab-case.
     * Входная строка должна быть корректной snake_case
     */
    public string snake2kebab (string snake_string) {
        var builder = new StringBuilder ();

        int i = 0;
        while (i < snake_string.length) {
            if (snake_string[i] == '_') {
                builder.append_c ('-');

            } else {
                builder.append_c (snake_string[i]);
            }
            i += 1;
        }

        return builder.free_and_steal ();
    }
}
