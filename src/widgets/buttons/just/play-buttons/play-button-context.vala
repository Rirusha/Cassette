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

    public class PlayButtonContext : PlayButtonDefault {

        public string context_type { get; construct set; default = "playlist"; }

        public PlayButtonContext () {
            Object ();
        }

        protected override void post_init () {
            player.played.connect ((track_info) => {

                if (player.mode.context_id == content_id && player.mode.context_type == context_type) {
                    set_playing ();
                }
            });

            player.paused.connect ((track_info) => {
                if (player.mode.context_id == content_id && player.mode.context_type == context_type) {
                    set_paused ();
                }
            });

            player.stopped.connect (() => {
                set_stopped ();
            });
        }

        bool context_playing_now () {
            if (player.mode.context_id == content_id && player.mode.context_type == context_type) {
                return true;
            }

            return false;
        }

        protected override bool on_clicked () {
            if (context_playing_now ()) {
                player.play_pause ();
                return false;
            }

            return true;
        }
    }
}
