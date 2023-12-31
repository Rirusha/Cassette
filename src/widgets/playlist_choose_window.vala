/* playlist_choose_window.vala
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


using CassetteClient;


namespace Cassette {
    [GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/playlist_choose_window.ui")]
    public class PlaylistChooseWindow : Adw.Window {
        [GtkChild]
        unowned Gtk.Box main_box;
        [GtkChild]
        unowned Gtk.Spinner spinner_loading;
        [GtkChild]
        unowned Gtk.Stack main_stack;

        public YaMAPI.Track target_track { get; construct; }

        public PlaylistChooseWindow (YaMAPI.Track target_track) {
            Object (target_track: target_track);
        }

        construct {
            main_stack.visible_child_name = "loading";
            spinner_loading.start ();

            load_playlists.begin ();

            if (Config.POSTFIX == ".Devel") {
                add_css_class ("devel");
            }

        }

        async void load_playlists () {
            Gee.ArrayList<YaMAPI.Playlist>? playlists_info = null;

            threader.add (() => {
                playlists_info = yam_talker.get_playlist_list (null);

                Idle.add (load_playlists.callback);
            });

            yield;

            set_values (playlists_info);
        }

        void set_values (Gee.ArrayList<YaMAPI.Playlist>? playlists_info) {
            if (playlists_info != null) {
                foreach (var playlist in playlists_info) {
                    main_box.append (new PlaylistRow (playlist, target_track));
                }

                spinner_loading.stop ();
                main_stack.set_visible_child_name ("done");
            }
        }
    }
}
