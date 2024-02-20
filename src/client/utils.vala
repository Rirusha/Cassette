/* Copyright 2023-2024 Rirusha
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */


using Gee;


namespace CassetteClient {

    namespace YaMAPI.Rotor {
        namespace FeedbackType {
            public const string STARTED = "radioStarted";
            public const string TRACK_STARTED = "trackStarted";
            public const string TRACK_FINISHED = "trackFinished";
            public const string FINISHED = "trackFinished";
        }

        namespace StationType {
            public const string ON_YOUR_WAVE = "user:onyourwave";
        }
    }

    public enum ArtSize {
        TRACK = 75,
        BIG_ART = 400,
        BIG_SMALL = 200
    }

    public const int TIMEOUT = 10;

    public static Cachier.Cachier cachier;
    public static Cachier.Storager storager;
    public static Threader threader;
    public static YaMTalker yam_talker;
    public static Player.Player player;

    public static string get_language () {
        string? locale = Environment.get_variable ("LANG");
        string language = "en";

        if (locale != null) {
            language = locale.split ("_")[0];
        }

        return language;
    }

    public static string get_timestamp () {
        return new DateTime.now_utc ().format_iso8601 ();
    }

    public static void init (string application_id, bool is_devel) {
        cachier = new Cachier.Cachier ();
        storager = new Cachier.Storager (application_id);

        if (is_devel) {
            Logger.log_level = LogLevel.DEVEL;
        } else {
            storager.settings.changed.connect ((key) => {
                if (key == "debug-mode") {
                    if (storager.settings.get_boolean ("debug-mode")) {
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

    // Если переместить домен в другое место, то Jsoner перестанет его видеть
    public errordomain ClientError {
        // Не получается спарсить ответ
        PARSE_ERROR,
        // Не получается получить ответ
        SOUP_ERROR,
        // Ответом пришла ошибка
        ANSWER_ERROR,
        // Ошибка авторизации
        AUTH_ERROR
    }

    public class TypeUtils<T> {
        public void shuffle (ref ArrayList<T> list) {
            for (int i = 0; i < list.size; i++) {
                int random_index = Random.int_range (0, list.size);
                T a = list[i];
                list[i] = list[random_index];
                list[random_index] = a;
            }
        }
    }

    public string strip (string str, char ch) {
        /*
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

    //  Переделывает camelCase строку в kebab-case. Входная строка должна быть корректной camelCase
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

    //  Переделывает kebab-case строку в camelCase. Входная строка должна быть корректной kebab-case
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

    //  Переделывает kebab-case строку в snake_case. Входная строка должна быть корректной kebab-case
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

    //  Переделывает snake_case строку в kebab-case. Входная строка должна быть корректной snake_case
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
