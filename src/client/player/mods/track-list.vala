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
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */

using Gee;

public class Cassette.Client.Player.TrackList : Shufflable {

    public TrackList (
        Player player,
        ArrayList<YaMAPI.Track> queue,
        string context_type,
        string? context_id,
        int current_index,
        string? context_description
    ) {
        Object (
            player: player,
            queue: queue,
            context_type: context_type,
            context_id: context_id,
            current_index: current_index,
            context_description: context_description
        );
    }

    construct {
        change_queue ();
        sh_queue_changed.connect (change_queue);
    }

    void change_queue () {
        player.queue_changed (
            queue,
            context_type,
            context_id,
            current_index,
            context_description
        );
    }

    public override void next (bool consider_repeat_mode) {
        var new_index = get_next_index (consider_repeat_mode);

        if (new_index != -1) {
            current_index = new_index;

        } else {
            player.start_flow (
                "%s:%s".printf (
                    context_type,
                    context_id.replace (":", "_")
                ),
                queue);
        }
    }

    public override int get_next_index (bool consider_repeat_one) {
        int index = current_index;

        switch (player.repeat_mode) {
            case RepeatMode.OFF:
                if (index + 1 == queue.size) {
                    index = -1;

                } else {
                    index++;
                }
                break;

            case RepeatMode.ONE:
                if (!consider_repeat_one) {
                    if (index + 1 == queue.size) {
                        index = -1;

                    } else {
                        index++;
                    }
                }
                break;

            case RepeatMode.QUEUE:
                if (index + 1 == queue.size) {
                    index = 0;

                } else {
                    index++;
                }
                break;
        }

        return index;
    }

    public override int get_prev_index () {
        int index = current_index;

        switch (index) {
            case -1:
                index = -1;
                break;

            case 0:
                if (player.repeat_mode == RepeatMode.QUEUE) {
                    index = queue.size - 1;
                } else {
                    index = -1;
                }
                break;

            default:
                index--;
                break;
        }

        return index;
    }

    public override YaMAPI.Play form_play_obj () {
        var current_track = get_current_track_info ();

        return new YaMAPI.Play () {
            track_length_seconds = ((double) current_track.duration_ms) / 1000.0,
            track_id = current_track.id,
            album_id = current_track.albums.size > 0 ? current_track.albums[0].id : null,
            context = context_type,
            context_item = context_id
        };
    }
}
