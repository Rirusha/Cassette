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

    [GtkTemplate (ui = "/space/rirusha/Cassette/ui/disliked-tracks-view.ui")]
    public class DislikedTracksView : HasTracksView {
        [GtkChild]
        unowned Gtk.Box main_box;
        [GtkChild]
        unowned Gtk.ScrolledWindow scrolled_window;

        public override bool can_refresh { get; default = true; }

        YaMAPI.TrackHeap? _track_list = null;

        public string? uid { get; construct set; }
        public string kind { get; construct set; }

        public DislikedTracksView () {
            Object ();
        }

        construct {
            track_list = new TrackList (scrolled_window.vadjustment);
            main_box.append (track_list);
        }

        void set_values () {
            track_list.set_tracks_disliked (_track_list.tracks, _track_list);

            show_ready ();
        }

        public async override int try_load_from_web () {
            threader.add (() => {
                _track_list = yam_talker.get_disliked_tracks ();

                Idle.add (try_load_from_web.callback);
            });

            yield;

            if (_track_list != null) {
                set_values ();
                return -1;
            }
            return 0;
        }

        public async override bool try_load_from_cache () {
            return false;
        }
    }
}
