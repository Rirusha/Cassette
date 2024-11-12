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

namespace Cassette.Client.YaMAPI {
    public class Playlist : YaMObject, HasCover, HasID, HasTrackList {

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

        string _title;
        public string title {
            get {
                return _title;
            }
            set {
                switch (value) {
                    case "Мне нравится":
                        // Translators: Playlist with liked tracks
                        _title = _("Liked");
                        break;
                    case "Плейлист дня":
                        // Translators: Playlist that updates every day
                        _title = _("Daily");
                        break;
                    case "":
                        // Translators: Unknown playlist
                        _title = _("Unknown");
                        break;
                    default:
                        _title = value;
                        break;
                }
            }
        }

        public string? uid { get; set; default = null; }
        public string kind { get; set; default = "3"; }
        public string? playlist_uuid { get; set; }
        public int track_count { get; set; default = 0; }
        public int revision { get; set; }
        public int snapshot { get; set; }
        public string? visibility { get; set; }
        public User owner { get; set; }
        public Cover cover {get; set; default = new Cover.empty (); }
        public ArrayList<TrackShort> tracks { get; set; default = new ArrayList<TrackShort> (); }
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
        public ArrayList<Playlist> similar_playlists { get; set; default = new ArrayList<Playlist> (); }
        public ArrayList<Playlist> last_owner_playlists { get; set; default = new ArrayList<Playlist> (); }
        public string? generated_playlist_type { get; set; }
        public string? description { get; set; }
        public string? type_ { get; set; }

        public Playlist () {
            Object ();
        }

        public Playlist.liked () {
            Object (
                cover: new Cover.liked (),
                title: _("Liked"),
                kind: "3"
            );
        }

        public void filter_by_track_type (TrackType track_type) {
            var new_track_list = new ArrayList<TrackShort> ();

            foreach (TrackShort track_short in tracks) {
                if (track_short.track.track_type == track_type) {
                    new_track_list.add (track_short);
                }
            }

            tracks = new_track_list;
        }

        public ArrayList<Track> get_filtered_track_list (
            bool show_explicit,
            bool show_child,
            string? exception_track_id = null
        ) {
            var out_track_list = new ArrayList<Track> ();

            foreach (TrackShort track_short in tracks) {
                if (
                    (track_short.track.available &&
                        (
                            (!track_short.track.is_explicit || show_explicit) &&
                            (!track_short.track.is_suitable_for_children || show_child)
                        )
                    ) || track_short.id == exception_track_id
                ) {
                    out_track_list.add (track_short.track);
                }
            }

            return out_track_list;
        }

        public void set_track_list (ArrayList<Track> track_list) {
            for (int i = 0; i < track_list.size; i++) {
                tracks[i].track = track_list[i];
            }
        }

        public ArrayList<Track> get_track_list () {
            var track_list = new ArrayList<Track> ();
            foreach (TrackShort track_short in tracks) {
                track_list.add (track_short.track);
            }

            return track_list;
        }

        public ArrayList<string> get_cover_items_by_size (int size) {
            if (kind == "3") {
                cover = new Cover.liked ();
            }
            if (cover.uris.size == 0) {
                cover = new Cover.empty ();
            }
            ArrayList<string> cover_array = new ArrayList<string> ();
            foreach (string uri in cover.uris) {
                cover_array.add ("https://" + uri.replace ("%%", @"$(size)x$(size)"));
            }

            return cover_array;
        }
    }
}
