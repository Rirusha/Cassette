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
    public class Artist : YaMObject, HasID {

        public string oid {
            owned get {
                return id;
            }
        }

        public string id { get; set; }
        public string? reason { get; set; }
        public string? name { get; set; }
        public Cover cover { get; set; }
        public bool various { get; set; }
        public bool composer { get; set; }
        public ArrayList<string> genres { get; set; default = new ArrayList<string> (); }
        public Counts? counts { get; set; }
        public bool is_available { get; set; }
        public Ratings? ratings { get; set; }
        public ArrayList<Link> links { get; set; default = new ArrayList<Link> (); }
        public int likes_count { get; set; }
        public ArrayList<Track> popular_tracks { get; set; default = new ArrayList<Track> (); }
        public string? hand_made_description { get; set; }
        public string? description { get; set; }
        public ArrayList<string> countries { get; set; default = new ArrayList<string> (); }
        public string? en_wikipedia_link { get; set; }
        public string? ya_money_id { get; set; }

        public Artist () {
            Object ();
        }

        public string? get_cover_uri_by_size (int size) {
            if (cover == null) {
                return null;
            }
            return "https://" + cover.items_uri[0].replace ("%%", @"$(size)x$(size)");
        }
    }
}
