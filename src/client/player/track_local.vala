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

using CassetteClient.YaMAPI;
using Gee;

namespace CassetteClient {
    public class TrackLocal : Track {

        construct {
            type_ = "local";
        }

        public override ArrayList<string> get_cover_items_by_size (int size) {
            var array = new ArrayList<string> ();
            array.add ("https://es-static.z-dn.net/files/d6a/87164361f7d08a28bd93261b5ebacd8a.png");
            return array;
        }
    }
}
 