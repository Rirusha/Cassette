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

namespace Cassette.Client.YaMAPI {

    /**
     * Датакласс с фидбеком о прослушивании
     */
    public class Play : YaMObject {

        /**
         * Id сессии прослушивания
         */
        public string play_id { get; set; }

        /**
         * Временная метка запроса
         */
        public string timestamp { get; set; default = get_timestamp (); }

        /**
         * Общее количество прослушанного времени в секундах
         */
        public double total_played_seconds { get; set; }

        /**
         * Секунда, на которой закончилось прослушивание
         */
        public double end_position_seconds { get; set; }

        /**
         * Общее количество секунд в треке
         */
        public double track_length_seconds { get; set; }

        /**
         * Id трека
         */
        public string track_id { get; set; }

        /**
         * Id альбома
         */
        public string? album_id { get; set; }

        /**
         *
         */
        public string from { get; set; default = API_FROM; }

        /**
         * Контекст воспроизведения (То же что и ``Queue.context.type``)
         */
        public string context { get; set; }

        /**
         * Id контекста, (Тоже же, что и ``Queue.context.id``)
         */
        public string context_item { get; set; }

        /**
         *
         */
        public string add_tracks_to_player_time { get; set; default = generate_add_tracks_to_player_time (); }

        /**
         *
         */
        public string audio_auto { get; set; default = "none"; }

        /**
         *
         */
        public string audio_output_name { get; set; default = "Динамики"; }

        /**
         *
         */
        public string audio_output_type { get; set; default = "Speaker"; }

        /**
         * Id сессии волны
         */
        public string? radio_session_id { get; set; }

        public static string generate_add_tracks_to_player_time () {
            int64 random_part = (int64) (Random.double_range (0.0, 1.0) * Math.pow (10, 10));
            int64 time_part = new DateTime.now ().to_unix () / 1000;

            return @"$random_part-$time_part";
        }
    }

    /**
     * Датакласс с фидбеками
     */
    public class Plays : YaMObject {

        /**
         * Id сессии прослушивания
         */
        public ArrayList<Play> plays { get; set; default = new ArrayList<Play> (); }
    }
}
