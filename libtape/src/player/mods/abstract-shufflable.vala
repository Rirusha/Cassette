/*
 * Copyright (C) 2024 Vladimir Romanov
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Gee;

/**
 *
 */
public abstract class Tape.PlayerShufflable : PlayerMode {

    static int index_of_track (GLib.GenericArray<YaMAPI.Track> tracks, YaMAPI.Track track) {
        uint index;
        return tracks.find (track, out index) ? (int) index : -1;
    }

    GLib.GenericArray<YaMAPI.Track> original_queue { get; set; default = new GLib.GenericArray<YaMAPI.Track> (); }

    public signal void sh_queue_changed ();

    construct {
        foreach (var track in queue) original_queue.add (track);

        if (player.shuffle_mode == ShuffleMode.ON) {
            shuffle ();
        }
    }

    public void shuffle () {
        var type_utils = new TypeUtils<YaMAPI.Track> ();

        var current_track = get_current_track_info ();

        GLib.GenericArray<YaMAPI.Track> shuffled_queue = new GLib.GenericArray<YaMAPI.Track> ();

        foreach (var track in queue) shuffled_queue.add (track);
        queue.remove_range (0, queue.length);

        type_utils.shuffle (ref shuffled_queue);

        var new_index = index_of_track (shuffled_queue, current_track);

        for (int i = new_index; i < shuffled_queue.length; i++) queue.add (shuffled_queue[i]);
        for (int i = 0; i < new_index; i++) queue.add (shuffled_queue[i]);

        current_index = 0;

        sh_queue_changed ();
    }

    public void unshuffle () {
        var current_track = get_current_track_info ();

        queue.remove_range (0, queue.length);
        foreach (var track in original_queue) queue.add (track);
        current_index = index_of_track (queue, current_track);

        sh_queue_changed ();
    }

    public void add_track_next (YaMAPI.Track track_info) {
        if (queue.length == 0) {
            add_track_end (track_info);
            return;
        }

        queue.insert (current_index + 1, track_info);
        original_queue.insert (index_of_track (original_queue, get_current_track_info ()) + 1, track_info);

        sh_queue_changed ();
    }

    public void remove_track_by_pos (int position) {
        var track_info = queue[position];
        remove_track (track_info);

        sh_queue_changed ();
    }

    public void remove_track (YaMAPI.Track track_info) {
        int track_pos = index_of_track (queue, track_info);

        if (track_pos == -1) {
            return;
        }

        queue.remove_index (track_pos);
        original_queue.remove (track_info);

        if (queue.length != 0) {
            if (track_pos == current_index) {
                player.change_track (get_current_track_info ());
            } else if (track_pos < current_index) {
                current_index--;
            }
        } else {
            player.clear_mode ();
        }

        sh_queue_changed ();
    }

    public void add_track_end (YaMAPI.Track track_info) {
        queue.add (track_info);
        original_queue.add (track_info);

        sh_queue_changed ();
    }

    public void add_many_end (GLib.GenericArray<YaMAPI.Track> track_list) {
        foreach (var track in track_list) {
            queue.add (track);
            original_queue.add (track);
        }

        sh_queue_changed ();
    }
}
