/* Copyright 2023-2024 Rirusha
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */


using Cassette.Client;


namespace Cassette {

    public class Authenticator : Object {

        public signal void success ();
        public signal void local ();

        Adw.Window? loading_win = null;

        public Authenticator () {
            Object ();
        }

        construct {
            success.connect (() => {
                application.application_state = ApplicationState.ONLINE;
            });
            local.connect (() => {
                application.application_state = ApplicationState.LOCAL;
            });
        }

        public void log_out () {
            var dialog = new Adw.AlertDialog (
                _("Log out?"),
                _("You will need to log in again to use the app")
            );

            dialog.add_response ("cancel", _("Cancel"));
            dialog.add_response ("logout", _("Log out"));

            dialog.set_response_appearance ("logout", Adw.ResponseAppearance.DESTRUCTIVE);

            dialog.default_response = "cancel";
            dialog.close_response = "cancel";

            dialog.response.connect ((dialog, response) => {
                if (response == "logout") {
                    force_log_out ();
                }
            });

            dialog.present (application.main_window);
        }

        public void force_log_out () {
            move_user_cache.begin (() => {
                application.application_state = ApplicationState.BEGIN;
                application.quit ();
            });
        }

        async void move_user_cache () {
            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 16) {
                margin_top = 16,
                margin_bottom = 16,
                margin_start = 16,
                margin_end = 16
            };

            loading_win = new Adw.Window () {
                resizable = false,
                transient_for = application.main_window,
                modal = true,
                content = box
            };

            var spinner = new Gtk.Spinner () {
                width_request = 16,
                height_request = 16,
                hexpand = true,
                vexpand = true
            };
            box.append (spinner);

            var label = new Gtk.Label (_("Moving…"));
            label.add_css_class ("title-1");
            box.append (label);

            loading_win.present ();
            spinner.start ();

            // TODO: let user choose save content ot not
            yield storager.clear_user (true);
        }

        public void log_in () {
            if (application.application_state != ApplicationState.BEGIN) {
                init_client_async.begin ();
            } else {
                start_auth ();
            }
        }

        public async void init_client_async () {
            bool should_auth = false;
            bool cant_use = false;

            threader.add (() => {
                try {
                    yam_talker.init_if_not ();

                } catch (BadStatusCodeError e) {
                    Logger.warning ("Bad status code while trying init client. Error message: %s".printf (e.message));

                    should_auth = true;

                } catch (CantUseError e) {
                    Logger.warning ("User hasn't Plus Subscription. Error message: %s".printf (e.message));

                    cant_use = true;
                }

                Idle.add (init_client_async.callback);
            });

            yield;

            if (cant_use) {
                application.show_no_plus_dialog ();
                return;
            }

            if (should_auth) {
                start_auth ();

            } else {
                success ();
            }
        }

        public void start_auth () {
            application.application_state = ApplicationState.BEGIN;
            if (storager.cookies_file.query_exists ()) {
                storager.remove_file (storager.cookies_file);
            }

            var begin_window = new BeginDialog ();

            begin_window.begin_view.local_choosed.connect (() => {
                local ();
            });
            begin_window.begin_view.online_complete.connect (init_client_async);

            begin_window.present (application.main_window);
        }
    }
}
