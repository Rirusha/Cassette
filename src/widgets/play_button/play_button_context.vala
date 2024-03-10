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


using Cassette.Client;


namespace Cassette {

    public class PlayButtonContext : PlayButtonDefault {

        public string? context_type { get; construct; default = "playlist"; }

        public PlayButtonContext () {
            Object ();
        }

        protected override void post_init () {
            player.notify["player-state"].connect (on_player_state_changed);

            on_player_state_changed ();
        }

        bool context_playing_now () {
            if (player.player_mode?.context_id == content_id && player.player_mode?.context_type == context_type) {
                return true;

            } else {
                string uid = yam_talker.me.oid;
                if (uid == null) {
                    return false;
                }

                if ((content_id == @"$uid:3") && player.player_mode?.context_type == "my_music") {
                    return true;
                }
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

        void on_player_state_changed () {
            if (context_playing_now ()) {
                if (player.player_state == Player.PlayerState.PLAYING) {
                    set_playing ();
                    return;
                }
                set_paused ();
                return;
            } else {
                set_stopped ();
            }
        }
    }
}
