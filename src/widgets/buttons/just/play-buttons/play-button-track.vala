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


namespace Cassette {

    public class PlayButtonTrack : PlayButtonDefault {

        public PlayButtonTrack () {
            Object ();
        }

        protected override void post_init () {
            player.played.connect ((track_info) => {
                if (content_id == track_info.id) {
                    set_playing ();
                }
            });

            player.paused.connect ((track_info) => {
                if (content_id == track_info.id) {
                    set_paused ();
                }
            });

            player.stopped.connect (() => {
                set_stopped ();
            });

            check_track_play_state ();
        }

        protected override bool on_clicked () {
            var current_track = player.mode.get_current_track_info ();

            if (current_track != null) {
                if (current_track.id == content_id) {
                    player.play_pause ();

                    return false;
                }
            }

            return true;
        }

        void check_track_play_state () {
            var current_track = player.mode.get_current_track_info ();

            if (current_track == null) {
                return;
            }

            if (current_track.id == content_id) {
                if (player.state == Player.State.PLAYING) {
                    set_playing ();
                    return;
                }
                set_paused ();
                return;
            }
            if (is_current_playing == true) {
                set_stopped ();
            }
        }
    }
}
