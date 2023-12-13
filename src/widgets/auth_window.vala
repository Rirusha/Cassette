/* auth_window.vala
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
using WebKit;


namespace Cassette {
    [GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/auth_window.ui")]
    public class AuthWindow : Adw.Window {
        [GtkChild]
        unowned Adw.NavigationView navigation_view;
        [GtkChild]
        unowned Gtk.Box main_box;
        [GtkChild]
        unowned Gtk.Button button_local_mode;
        [GtkChild]
        unowned Gtk.Button button_refresh;
        [GtkChild]
        unowned Adw.ToolbarView toolbar_view_auth;

        private WebView webview = new WebView ();

        public signal void bad_close ();
        public signal void local_choosed ();
        public signal void online_complete ();

        public AuthWindow () {
            Object ();
        }

        construct {
            // Размещение кнопок выбора снизу и развёртывание окна при мобильном соотношении сторон
            if (Cassette.application.main_window.is_mobile) {
                main_box.valign = Gtk.Align.CENTER;

            } else {
                main_box.valign = Gtk.Align.FILL;

                main_box.map.connect (() => {
                    width_request = 100;
                    height_request = 300;
                });

                webview.map.connect (() => {
                    width_request = 700;
                    height_request = 900;
                });
            }

            button_refresh.clicked.connect (webview.reload);

            toolbar_view_auth.content = webview;

            var action_group = new SimpleActionGroup ();

            var bad_close_action = new SimpleAction ("bad-close", null);
            bad_close_action.activate.connect (() => {
                bad_close ();
            });
            action_group.add_action (bad_close_action);

            var login_action = new SimpleAction ("online", null);
            login_action.activate.connect (online);
            action_group.add_action (login_action);

            var local_action = new SimpleAction ("local", null);
            local_action.activate.connect (local);
            action_group.add_action (local_action);

            insert_action_group ("auth", action_group);

            webview.load_changed.connect ((event) => {
                if (!("https://passport.yandex.ru/" in webview.uri) && event != LoadEvent.STARTED) {
                    online_complete ();

                    close ();
                }
            });

            var network_session = webview.get_network_session ();
            var cookie_manager = network_session.get_cookie_manager ();

            cookie_manager.set_persistent_storage (storager.cookies_file_path, CookiePersistentStorage.SQLITE);

            block_widget (button_local_mode, BlockReason.NOT_IMPLEMENTED);

            if (Config.POSTFIX == ".Devel") {
                add_css_class ("devel");
            }
        }

        void online () {
            navigation_view.push_by_tag ("auth-page");

            webview.load_uri ("https://oauth.yandex.ru/authorize");
        }

        void local () {
            assert_not_reached ();

            //  choosed_local ();
            //  close ();
        }
    }
}
