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

public class Cassette.Client.Player.Flow : Mode {

    public string station_id { get; construct; }

    string radio_session_id;

    public Flow (
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

    public async bool init_async () {
        YaMAPI.Rotor.StationTracks? station_tracks = null;

        threader.add (() => {
            station_tracks = yam_talker.start_new_session (station_id);

            Idle.add (init_async.callback);
        });

        yield;

        if (station_tracks != null) {
            radio_session_id = station_tracks.radio_session_id;

            queue.add (station_tracks.sequence[0].track);

            current_index = 0;

            return true;

        } else {
            return false;
        }
    }

    public override int get_prev_index () {
        int index = current_index;

        switch (index) {
            case -1:
            case 0:
                index = -1;
                break;

            default:
                index--;
                break;
        }

        return index;
    }

    public override int get_next_index (bool consider_repeat_mode) {
        return -1;
    }

    public override YaMAPI.Play form_play_obj () {
        var current_track = get_current_track_info ();

        return new YaMAPI.Play () {
            track_length_seconds = ((double) current_track.duration_ms) / 1000.0,
            track_id = current_track.id,
            album_id = current_track.albums.size > 0 ? current_track.albums[0].id : null,
            context = context_type,
            context_item = context_id,
            radio_session_id = radio_session_id
        };
    }
}
