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
    [GtkTemplate (ui = "/space/rirusha/Cassette/ui/playlist-create-button.ui")]
    public class PlaylistCreateButton : Adw.Bin {
        [GtkChild]
        unowned Gtk.Button real_button;

        public PlaylistCreateButton () {
            Object ();
        }

        construct {
            real_button.clicked.connect (create_playlist_button_clicked_async);
            application.application_state_changed.connect (application_state_changed);
            application_state_changed (application.application_state, application.application_state);
        }

        async void create_playlist_button_clicked_async () {
            sensitive = false;

            threader.add (() => {
                yam_talker.create_playlist ();

                Idle.add (create_playlist_button_clicked_async.callback);
            });

            yield;
        }

        void application_state_changed (ApplicationState new_state, ApplicationState old_state) {
            switch (new_state) {
                case ApplicationState.ONLINE:
                    real_button.sensitive = true;
                    break;

                case ApplicationState.OFFLINE:
                    real_button.sensitive = false;
                    break;

                default:
                    break;
            }
        }
    }
}
