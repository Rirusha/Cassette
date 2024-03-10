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

namespace Cassette.Client.Player {

    public class PlayerFlow : PlayerMode {

        public string station_id { get; construct; }

        public PlayerFlow (
            Player player,
            string station_id,
            ArrayList<YaMAPI.Track> queue
        ) {
            Object (
                player: player,
                station_id: station_id,
                queue: queue
            );
        }

        public async override YaMAPI.Track? get_prev_track_info_async () {
            assert_not_reached ();
        }
        public override YaMAPI.Track? get_current_track_info () {
            assert_not_reached ();
        }
        public async override YaMAPI.Track? get_next_track_info_async () {
            assert_not_reached ();
        }
        public override YaMAPI.Play form_play_obj () {
            assert_not_reached ();
        }
        public override void next (bool consider_repeat_mode) {
            assert_not_reached ();
        }
        public override void prev () {
            assert_not_reached ();
        }
    }
}
