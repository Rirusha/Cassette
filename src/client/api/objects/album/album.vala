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
    public class Album : YaMObject, HasID {

        public string oid {
            owned get {
                return id;
            }
        }

        public bool explicit {
            get {
                return content_warning == "explicit"? true : false;
            }
        }

        public string id { get; set; }
        public string title { get; set; }
        public int track_count { get; set; }
        public ArrayList<Artist> artists { get; set; default = new ArrayList<Artist> (); }
        public ArrayList<Label> labels { get; set; default = new ArrayList<Label> (); }
        public bool available { get; set; }
        public string? version { get; set; }
        public string? cover_uri { get; set; }
        public string? content_warning { get; set; }
        public string? genre { get; set; }
        public string? short_description { get; set; }
        public string? description { get; set; }
        public bool is_premiere { get; set; }
        public bool is_banner { get; set; }
        public bool recent { get; set; }
        public bool very_important { get; set; }
        public ArrayList<int> bests { get; set; default = new ArrayList<int> (); }
        public ArrayList<Album> duplicates { get; set; default = new ArrayList<Album> (); }
        public ArrayList<ArrayList<Track>> volumes { get; set; default = new ArrayList<ArrayList<Track>> (); }
        public int year { get; set; }
        public string? release_date { get; set; }
        public ArrayList<Album> albums { get; set; default = new ArrayList<Album> (); }
        public int duration_ms { get; set; }
        public int likes_count { get; set; }

        public Album () {
            Object ();
        }

        construct {
            volumes.add (new ArrayList<Track> ());
        }

        public Album.with_id (string id) {
            Object (id: id);
        }

        public string? get_cover_url_by_size (int size) {
            if (cover_uri == null) {
                return null;
            }
            return "https://" + cover_uri.replace ("%%", @"$(size)x$(size)");
        }
    }
}
