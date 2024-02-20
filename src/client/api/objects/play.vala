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


namespace CassetteClient.YaMAPI {
    public class Play : YaMObject {
        /*
            Объект для отправки фидбека о прослушивании трека
        */

        public string play_id { get; set; }
        public string timestamp { get; set; }
        public double total_played_seconds { get; set; }
        public double end_position_seconds { get; set; }
        public double track_length_seconds { get; set; }
        public string track_id { get; set; }
        public string album_id { get; set; }
        public string from { get; set; }
        public string context { get; set; }
        public string context_item { get; set; }
        public string add_tracks_to_player_time { get; set; }
        public string audio_auto { get; set; }
        public string audio_output_name { get; set; }
        public string audio_output_type { get; set; }
        public string radio_session_id { get; set; }
    }
}
