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

public class Tape.YaMAPI.Playlist : Serialize.DataObject, HasCover, HasID {

    public bool is_public {
        get {
            if (visibility == "public") {
                return true;
            } else {
                return false;
            }
        }
    }

    public string oid {
        owned get {
            return @"$uid:$kind";
        }
    }

    public string title { get; set; }

    public string? uid { get; set; default = null; }

    public string kind { get; set; default = "3"; }

    public string? playlist_uuid { get; set; }

    public int track_count { get; set; default = 0; }

    public int revision { get; set; }

    public int snapshot { get; set; }

    public string? visibility { get; set; }

    public User owner { get; set; }

    public Cover cover { get; set; default = new Cover.empty (); }

    public Serialize.Array<TrackShort> tracks { get; set; default = new Serialize.Array<TrackShort> (); }

    public MadeFor? made_for { get; set; }

    public PlayCounter? play_counter { get; set; }

    public PlaylistAbsence? playlist_absence { get; set; }

    public string? url_part { get; set; }

    public string? created { get; set; }

    public string? modified { get; set; }

    public int duration_ms { get; set; }

    public string? background_color { get; set; }

    public string? text_color { get; set; }

    public int likes_count { get; set; }

    public Serialize.Array<Playlist> similar_playlists { get; set; default = new Serialize.Array<Playlist> (); }

    public Serialize.Array<Playlist> last_owner_playlists { get; set; default = new Serialize.Array<Playlist> (); }

    public string? generated_playlist_type { get; set; }

    public string? description { get; set; }

    [Description (nick = "type")]
    public string? type_ { get; set; }

    public Playlist.liked () {
        Object (
            cover : new Cover.liked (),
            title : _("Liked"),
            kind : "3"
        );
    }

    public void filter_by_track_type (TrackType track_type) {
        var new_track_list = new Serialize.Array<TrackShort> ();

        foreach (TrackShort track_short in tracks) {
            if (track_short.track.track_type == track_type) {
                new_track_list.add (track_short);
            }
        }

        tracks = new_track_list;
    }

    public Serialize.Array<YaMAPI.Track> get_filtered_track_list (
        bool with_explicit,
        bool with_child,
        string[] exception_tracks_ids = new string[0]
    ) {
        var out_track_list = new Serialize.Array<Track> ();

        foreach (TrackShort track_short in tracks) {
            if ((track_short.track.available &&
                ((!track_short.track.is_explicit || with_explicit) &&
                 (!track_short.track.is_suitable_for_children || with_child))
                ) || track_short.id in exception_tracks_ids
            ) {
                out_track_list.add (track_short.track);
            }
        }

        return out_track_list;
    }

    public void set_track_list (Serialize.Array<Track> track_list) {
        for (int i = 0; i < track_list.size; i++) {
            tracks[i].track = track_list[i];
        }
    }

    public Serialize.Array<Track> get_track_list () {
        var track_list = new Serialize.Array<Track> ();
        foreach (TrackShort track_short in tracks) {
            track_list.add (track_short.track);
        }

        return track_list;
    }

    public Serialize.Array<string> get_cover_items_by_size (int size) {
        if (kind == "3") {
            cover = new Cover.liked ();
        }

        if (cover.uris.size == 0) {
            cover = new Cover.empty ();
        }

        Serialize.Array<string> cover_array = new Serialize.Array<string> ();

        foreach (string uri in cover.uris) {
            cover_array.add ("https://" + uri.replace ("%%", @"$(size)x$(size)"));
        }

        return cover_array;
    }
}
