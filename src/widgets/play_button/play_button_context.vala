/* play_button_context.vala
 *
 * Copyright 2023-2024 Rirusha
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
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


using CassetteClient;


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

        bool object_playing_now () {
            if (player.player_type == Player.PlayerModeType.TRACK_LIST) {
                var queue = player.get_queue ();

                if (queue.context.id == content_id && queue.context.type_ == context_type) {
                    return true;
                } else {
                    string uid = yam_talker.me.oid;
                    if ( uid == null) {
                        return false;
                    }

                    if ((content_id == @"$uid:3") && queue.context.type_ == "my_music") {
                        return true;
                    }
                }
            }

            return false;
        }

        protected override bool on_clicked () {
            if (object_playing_now ()) {
                player.play_pause ();
                return false;
            }

            return true;
        }

        void on_player_state_changed () {
            if (object_playing_now ()) {
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
