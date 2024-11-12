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


public abstract class Cassette.PlayMarkDefault : PlayMark, Initable {

    public signal void triggered_not_playing ();

    protected string content_id { get; set; }

    protected bool react_as_track { get; set; default = false; }

    bool connected = false;

    protected abstract bool is_playing_now ();

    public void init_content (string content_id) {
        this.content_id = content_id;

        if (connected) {
            disconnect_all ();
        }

        connect_all ();

        switch (player.state) {
            case Client.Player.State.PLAYING:
                on_player_played ();
                break;

            case Client.Player.State.PAUSED:
                on_player_paused ();
                break;

            default:
                break;
        }
    }

    void connect_all () {
        player.played.connect (on_player_played);
        player.paused.connect (on_player_paused);

        if (react_as_track) {
            player.track_stopped.connect (on_player_stopped);
        } else {
            player.stopped.connect (on_player_stopped);
        }

        connected = true;
    }

    void disconnect_all () {
        player.played.disconnect (on_player_played);
        player.paused.disconnect (on_player_paused);

        if (react_as_track) {
            player.track_stopped.disconnect (on_player_stopped);
        } else {
            player.stopped.disconnect (on_player_stopped);
        }

        connected = false;
    }

    void on_player_played () {
        if (is_playing_now ()) {
            set_playing ();
        }
    }

    void on_player_paused () {
        if (is_playing_now ()) {
            set_paused ();
        }
    }

    void on_player_stopped () {
        set_stopped ();
    }

    public void trigger () {
        if (is_playing_now ()) {
            player.play_pause ();

        } else {
            triggered_not_playing ();
        }
    }
}
