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
    public class Cover : YaMObject {

        public ArrayList<string> uris {
            owned get {
                if (uri != null) {
                    return new ArrayList<string>.wrap ({uri});
                } else {
                    return items_uri;
                }
            }
        }

        public string? type_ { get; set; }
        public ArrayList<string> items_uri { get; set; default = new ArrayList<string> (); }
        public string? uri { get; set; default = null; }
        public string? version { get; set; }
        public bool custom { get; set; }

        public Cover () {
            Object ();
        }

        public Cover.liked () {
            Object (uri: "music.yandex.ru/blocks/playlist-cover/playlist-cover_like.png");
        }

        public Cover.empty () {
            Object (uri: "music.yandex.ru/blocks/playlist-cover/playlist-cover_no_cover0.png");
        }
    }
}
