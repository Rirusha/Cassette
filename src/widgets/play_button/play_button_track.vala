/* play_button_track.vala
 *
 * Copyright 2023 Rirusha
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

    public class PlayButtonTrack : PlayButtonDefault {

        public PlayButtonTrack () {
            Object ();
        }

        protected override void post_init () {
            player.track_state_changed.connect (on_track_state_changed);

            check_state ();
        }

        public void check_state () {
            var playing_track = player.current_track;
            if (playing_track != null) {
                on_track_state_changed (playing_track.id);
            }
        }

        protected override bool on_clicked () {
            YaMAPI.Track? current_track = player.current_track;
            if (current_track != null) {
                if (current_track.id == content_id) {
                    player.play_pause ();
                    return false;
                }
            }

            return true;
        }

        private void on_track_state_changed (string playing_track_id) {
            if (playing_track_id == content_id) {
                if (player.player_state == Player.PlayerState.PLAYING) {
                    set_playing ();
                    return;
                }
                set_paused ();
                return;
            }
            if (is_playing == true) {
                set_stopped ();
            }
        }
    }
}