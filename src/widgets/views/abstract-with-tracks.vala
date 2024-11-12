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


using Cassette.Client;


namespace Cassette {
    public abstract class HasTracksView : BaseView {

        protected HasTrackList object_info { get; set; }
        protected TrackList track_list { get; set; }

        ~HasTracksView () {
            track_list.clear_all ();
        }

        public virtual void start_playing () {
            var track_list = object_info.get_filtered_track_list (
                Cassette.settings.get_boolean ("explicit-visible"),
                Cassette.settings.get_boolean ("child-visible")
            );

            player.start_track_list (
                track_list,
                get_context_type (object_info),
                object_info.oid,
                player.shuffle_mode == Player.ShuffleMode.ON ? Random.int_range (0, track_list.size) : 0,
                get_context_description (object_info)
            );
        }
    }
}
