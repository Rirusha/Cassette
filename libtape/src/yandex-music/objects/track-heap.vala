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

public class Tape.YaMAPI.TrackHeap : Serialize.DataObject, HasID {

    public string oid {
        owned get {
            return "";
        }
    }

    public Serialize.Array<Track> tracks { get; set; default = new Serialize.Array<Track> (); }

    public Serialize.Array<YaMAPI.Track> get_filtered_track_list (
        bool with_explicit,
        bool with_child,
        string[] exception_tracks_ids = new string[0]
    ) {
        var out_track_list = new Serialize.Array<Track> ();

        foreach (Track track in tracks) {
            if (
                (track.available && (
                    (!track.is_explicit || with_explicit) &&
                    (!track.is_suitable_for_children || with_child)
                )) || track.id in exception_tracks_ids
            ) {
                out_track_list.add (track);
            }
        }

        return out_track_list;
    }
}
