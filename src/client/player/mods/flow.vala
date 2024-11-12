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


using Gee;

public class Cassette.Client.Player.Flow : Mode {

    public string station_id { get; construct; }

    public YaMAPI.Rotor.StationTracks last_station_tracks {
        get; private set; default = new YaMAPI.Rotor.StationTracks ();
    }

    string radio_session_id;

    public Flow (
        Player player,
        string station_id,
        ArrayList<YaMAPI.Track> queue
    ) {
        Object (
            player: player,
            station_id: station_id,
            queue: queue,
            context_id: station_id,
            context_type: "radio"
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
            last_station_tracks = station_tracks;
            radio_session_id = station_tracks.radio_session_id;

            queue.add (station_tracks.sequence[0].track);
            queue.add (station_tracks.sequence[1].track);

            current_index = queue.size - 2;

            send_feedback.begin (YaMAPI.Rotor.FeedbackType.RADIO_STARTED);

            return true;

        } else {
            return false;
        }
    }

    public async void send_feedback (
        string feedback_type,
        string? track_id = null,
        double total_played_seconds = 0.0
    ) {
        threader.add_single (() => {
            yam_talker.send_rotor_feedback (
                radio_session_id,
                last_station_tracks.batch_id,
                feedback_type,
                track_id,
                total_played_seconds
            );

            Idle.add (send_feedback.callback);
        });

        yield;
    }

    /**
     * @return  next track object
     */
    async YaMAPI.Track? get_next_track_async () {
        YaMAPI.Track? next_track = null;

        threader.add (() => {
            ArrayList<string> track_ids = new ArrayList<string> ();

            foreach (var track_info in queue) {
                track_ids.add (track_info.id);
            }

            last_station_tracks = yam_talker.get_session_tracks (radio_session_id, track_ids);
            next_track = last_station_tracks.sequence[0].track;

            Idle.add (get_next_track_async.callback);
        });

        yield;

        return next_track;
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
        var index = current_index;

        switch (player.repeat_mode) {
            case RepeatMode.OFF:
                if (index + 1 == queue.size) {
                    index = -1;

                } else {
                    index++;
                }
                break;

            case RepeatMode.ONE:
                if (!consider_repeat_mode) {
                    if (index + 1 == queue.size) {
                        index = -1;

                    } else {
                        index++;
                    }
                }
                break;

            default:
                Logger.error ("Flow with `RepeatMode.QUEUE unsupported");
                break;
        }

        return index;
    }

    public void prepare_next_track () {
        get_next_track_async.begin ((obj, res) => {
            YaMAPI.Track? next_track = get_next_track_async.end (res);

            if (next_track != null) {
                queue.add (next_track);
                player.next_track_loaded (next_track);
            }
        });
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
