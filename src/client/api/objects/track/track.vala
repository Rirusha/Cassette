/* track.vala
 *
 * Copyright 2023 Rirusha
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
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Gee;

namespace CassetteClient.YaMAPI {
    public class Track : YaMObject, HasCover {

        public bool explicit {
            get {
                return content_warning == "explicit"? true : false;
            }
        }

        public bool ugc {
            get {
                return track_source == "UGC"? true : false;
            }
        }

        public string track_id {
            set {
                id = value;
            }
        }

        public string full_title {
            owned get {
                if (version != null) {
                    return @"$title $version";
                }
                return title;
            }
        }

        public string id { get; set; }
        public string? title { get; set; }
        public bool available { get; set; }
        public ArrayList<Artist> artists { get; set; default = new ArrayList<Artist> (); }
        public ArrayList<Album> albums { get; set; default = new ArrayList<Album> (); }
        public bool available_for_premium_users { get; set; }
        public bool lyrics_available { get; set; }
        //public string? type_ { get; set; }
        public string? cover_uri { get; set; }
        public Label major { get; set; }
        public int duration_ms { get; set; }
        public Track? substituted { get; set; }
        public MetaData? meta_data { get; set; }
        public string? content_warning { get; set; }
        public string? version { get; set; }
        public string? background_video_uri { get; set; }
        public string? short_description { get; set; }
        public bool is_suitable_for_children { get; set; }
        public string track_source { get; set; }
        public ArrayList<string> available_for_options { get; set; default = new ArrayList<string> (); }
        public LyricsInfo lyrics_info { get; set; }

        public ArrayList<string> get_cover_items_by_size (int size) {
            var array = new ArrayList<string> ();
            if (cover_uri != null) {
                array.add ("https://" + cover_uri.replace ("%%", @"$(size)x$(size)"));
            }
            return array;
        }

        public string get_artists_names () {
            var artists_names = new string[artists.size];
            for (int i = 0; i < artists.size; i++) {
                artists_names[i] = artists[i].name;
            }
            return string.joinv (", ", artists_names);
        }
    }
}