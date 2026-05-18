/* Copyright 2026 Anton Palgunov
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


namespace Cassette.Client.MacOsNowPlaying {

public static void init () {
    cassette_now_playing_init (
        on_cmd_play,
        on_cmd_pause,
        on_cmd_play_pause,
        on_cmd_next,
        on_cmd_prev,
        on_cmd_seek
    );

    player.played.connect (on_played);
    player.paused.connect (on_paused);
    player.stopped.connect (() => cassette_now_playing_clear ());
    player.track_stopped.connect (() => cassette_now_playing_clear ());
}

// Remote command callbacks — called on the GLib main loop via g_idle_add

static void on_cmd_play () {
    player.play ();
}

static void on_cmd_pause () {
    player.pause ();
}

static void on_cmd_play_pause () {
    player.play_pause ();
}

static void on_cmd_next () {
    if (player.can_go_next) {
        player.next ();
    }
}

static void on_cmd_prev () {
    if (player.can_go_prev) {
        player.prev ();
    }
}

static void on_cmd_seek (double position_sec) {
    player.seek ((int64) (position_sec * 1000));
}

// Player signal handlers

static void on_played (YaMAPI.Track track) {
    send_update (track, true);
}

static void on_paused (YaMAPI.Track track) {
    send_update (track, false);
}

static void send_update (YaMAPI.Track track, bool is_playing) {
    string artist = "";
    if (track.artists.size > 0 && track.artists[0].name != null) {
        artist = track.artists[0].name;
    }

    string? artwork_url = null;
    var covers = track.get_cover_items_by_size ((int) CoverSize.BIG);
    if (covers.size > 0) {
        artwork_url = covers[0];
    }

    cassette_now_playing_update (
        track.title ?? "",
        artist,
        track.get_album_title (),
        track.duration_ms / 1000.0,
        player.playback_pos_ms / 1000.0,
        is_playing,
        artwork_url
    );
}

}
