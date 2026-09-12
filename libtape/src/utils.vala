/*
 * Copyright 2024 Vladimir Romanov
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

namespace Tape {

    public struct ParseUriResult {
        public Serialize.DataObject root_object;
        public YaMAPI.Track? track;
    }

    namespace Filenames {
        internal string data_root () { return root.settings.app_name_lower; }
        internal const string COOKIES = "session.cookies";
        internal const string LOG = "log";
        internal const string DATABASE = "info.db";
        internal const string IMAGES = "images";
        internal const string AUDIOS = "audios";
        internal const string OBJECTS = "objs";
    }

    /**
     * Enum with cover sizes. These values are set for
     * optimization purposes and to avoid errors with
     * obtaining images from the api.
     */
    namespace CoverSize {
        internal const int SMALL = 75;
        internal const int BIG = 400;
    }

    internal async void wait (uint seconds) {
        Timeout.add_seconds_once (seconds, () => {
            Idle.add (wait.callback);
        });

        yield;
    }

    internal static void check_client_initted () {
        if (root.player == null ||
            root.cm == null ||
            root.ym == null
        ) {
            error (_("Client not initted"));
        }
    }

    /**
     * Переключить режим перемешивания на следующий.
     * ON -> OFF
     * OFF -> ON
     */
    public static void roll_shuffle_mode () {
        check_client_initted ();

        switch (root.player.shuffle_mode) {
        case ShuffleMode.OFF:
            root.player.shuffle_mode = ShuffleMode.ON;
            break;

        case ShuffleMode.ON:
            root.player.shuffle_mode = ShuffleMode.OFF;
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
        check_client_initted ();

        switch (root.player.repeat_mode) {
        case RepeatMode.OFF:
            if (root.player.mode is PlayerFlow) {
                root.player.repeat_mode = RepeatMode.ONE;
            } else {
                root.player.repeat_mode = RepeatMode.QUEUE;
            }
            break;

        case RepeatMode.QUEUE:
            root.player.repeat_mode = RepeatMode.ONE;
            break;

        case RepeatMode.ONE:
            root.player.repeat_mode = RepeatMode.OFF;
            break;
        }
    }

    /**
     * @return  Returns the result with the root dummy object
     *          (playlist, album) for which you want to get the
     *          object from the api. And a similar track, if the
     *          uri contained one.
     */
    public ParseUriResult? parse_uri (string uri) throws Serialize.JsonError {
        string[] uri_parts = {};
        string[] args = {};

        try {
            var regex = new Regex (
                "(yandexmusic://|https://music.yandex..+/)(.+)",
                RegexCompileFlags.OPTIMIZE, RegexMatchFlags.NOTEMPTY
            );
            MatchInfo match_info;

            string? match = null;
            if (regex.match (uri, 0, out match_info)) {
                match = match_info.fetch (2);
            }

            if (match == "" || match == null) {
                return null;
            }

            var splitted = match.split ("?");
            uri_parts = splitted[0].split ("/");

            // Cut off arguments
            if (splitted.length == 2) {
                args = splitted[1].split ("&");
            }

        } catch (Error e) {
            warning (e.message);
        }

        switch (uri_parts[0]) {
            case "users":
                return_val_if_fail (uri_parts.length > 1, null);
                string user_id = uri_parts[1];

                switch (uri_parts[2]) {
                    case "playlists":
                        return_val_if_fail (uri_parts.length > 3, null);
                        var playlist_dummy = new YaMAPI.Playlist () {
                            uid = user_id,
                            kind = uri_parts[3]
                        };

                        string kind = uri_parts[3];
                        return {playlist_dummy, null};

                    default:
                        return null;
                }

            case "album":
                return_val_if_fail (uri_parts.length > 1, null);
                var album_dummy = new YaMAPI.Album () {
                    id = uri_parts[1]
                };

                if (uri_parts.length == 2) {
                    warning (_("Albums view not implemented yet"));
                    return null;
                }

                switch (uri_parts[2]) {
                    case "track":
                        return_val_if_fail (uri_parts.length > 3, null);
                        var track_dummy = new YaMAPI.Track () {
                            id = uri_parts[3]
                        };

                        return {album_dummy, track_dummy};

                    default:
                        return null;
                }
        }

        return null;
    }

    public string get_share_link (Serialize.DataObject yam_obj) {
        if (yam_obj is YaMAPI.Track) {
            var track_info = (YaMAPI.Track) yam_obj;

            if (track_info.albums.size == 0) {
                warning (_("User owned tracks can't be shared"));
                return "";
            } else {
                return "https://music.yandex.ru/album/%s/track/%s?utm_medium=copy_link".printf (
                    track_info.albums[0].id, track_info.id
                );
            }

        } else if (yam_obj is YaMAPI.Playlist) {
            var playlist_info = (YaMAPI.Playlist) yam_obj;

            return "https://music.yandex.ru/users/%s/playlists/%s?utm_medium=copy_link".printf (
                playlist_info.owner.login, playlist_info.kind
            );

        } else if (yam_obj is YaMAPI.Album) {
            var album_info = (YaMAPI.Album) yam_obj;

            return "https://music.yandex.ru/albums/%s?utm_medium=copy_link".printf (
                album_info.oid
            );

        } else if (yam_obj is YaMAPI.Artist) {
            var artist_info = (YaMAPI.Artist) yam_obj;

            return "https://music.yandex.ru/artist/%s?utm_medium=copy_link".printf (
                artist_info.oid
            );

        } else {
            error (_("Can't share '%s' object").printf (
                yam_obj.get_type ().name ()
            ));
        }
    }

    // 253.3M -> 253.3 Megabytes
    HumanitySize to_human (string input) {
        string size = input[0 : input.length - 1];
        string unit;

        ulong size_long = (ulong) double.parse (size);

        switch (input[input.length - 1]) {
        case 'B':
            unit = ngettext ("Byte", "Bytes", size_long);
            break;

        case 'K':
            unit = ngettext ("Kilobyte", "Kilobytes", size_long);
            break;

        case 'M':
            unit = ngettext ("Megabyte", "Megabytes", size_long);
            break;

        case 'G':
            unit = ngettext ("Gigabyte", "Gigabytes", size_long);
            break;

        case 'T':
            unit = ngettext ("Terabyte", "Terabytes", size_long);
            break;

        default:
            assert_not_reached ();
        }

        return { size, unit };
    }

    /**
     * Milliseconds to seconds.
     *
     * @param ms    milliseconds
     *
     * @return      seconds
     */
    public static int ms2sec (int64 ms) {
        return (int) (ms / 1000);
    }

    /**
     * Utils for generic types.
     */
    public class TypeUtils<T> {

        /**
         * Shuffle list.
         *
         * @param list   `Serialize.Array' need to shuffle
         */
        public void shuffle (ref Serialize.Array<T> list) {
            for (int i = 0; i < list.size; i++) {
                int random_index = Random.int_range (0, list.size);
                T a = list[i];
                list[i] = list[random_index];
                list[random_index] = a;
            }
        }
    }
}
