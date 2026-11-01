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

public class Tape.YaMAPI.SimilarTracks : Deser.DataObject, HasID {

    public string oid {
        owned get {
            return "";
        }
    }

    public Track track { get; set; }

    public GLib.GenericArray<Track> similar_tracks { get; set; default = new GLib.GenericArray<Track> (); }

    public GLib.GenericArray<YaMAPI.Track> get_filtered_track_list (
        bool with_explicit,
        bool with_child,
        string[] exception_tracks_ids = new string[0]
    ) {
        var out_track_list = new GLib.GenericArray<Track> ();

        foreach (var similar_track in similar_tracks) {
            if ((similar_track.available &&
                ((!similar_track.is_explicit || with_explicit) &&
                 (!similar_track.is_suitable_for_children || with_child)
                )) || similar_track.id in exception_tracks_ids
            ) {
                out_track_list.add (similar_track);
            }
        }

        return out_track_list;
    }

    public override Deser.ValueCodec get_property_codec (GLib.ParamSpec property) throws Deser.Error {
        if (property.name == "similar-tracks") return Deser.create_codec_for_array<Track> ();
        return base.get_property_codec (property);
    }
}
