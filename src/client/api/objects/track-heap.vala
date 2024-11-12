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
    public class TrackHeap : YaMObject, HasID, HasTrackList {

        public string oid {
            owned get {
                return "";
            }
        }

        public ArrayList<Track> tracks { get; set; default = new ArrayList<Track> (); }

        public TrackHeap () {
            Object ();
        }

        public ArrayList<Track> get_filtered_track_list (
            bool show_explicit,
            bool show_child,
            string? exception_track_id = null
        ) {
            var out_track_list = new ArrayList<Track> ();

            foreach (Track track in tracks) {
                if (
                    (track.available && (
                        (!track.is_explicit || show_explicit) &&
                        (!track.is_suitable_for_children || show_child)
                    )) || track.id == exception_track_id
                ) {
                    out_track_list.add (track);
                }
            }

            return out_track_list;
        }
    }
}
