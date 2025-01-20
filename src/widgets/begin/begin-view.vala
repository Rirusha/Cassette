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
using WebKit;

namespace Cassette {

    [GtkTemplate (ui = "/space/rirusha/Cassette/ui/begin-view.ui")]
    public class BeginView : AbstractLoadablePage {
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

        public signal void local_choosed ();
        public signal void online_complete ();

        public BeginView (bool with_header_bar) {
            Object (with_header_bar: with_header_bar);
        }

        construct {
            if (application.main_window?.is_shrinked) {
                main_box.valign = Gtk.Align.FILL;

            } else {
                main_box.valign = Gtk.Align.CENTER;
            }

            button_refresh.clicked.connect (refresh);

            toolbar_view_auth.content = webview;

            var action_group = new SimpleActionGroup ();

            var bad_close_action = new SimpleAction ("bad-close", null);
            bad_close_action.activate.connect (application.quit);
            action_group.add_action (bad_close_action);

            var login_action = new SimpleAction ("online", null);
            login_action.activate.connect (online);
            action_group.add_action (login_action);

            var local_action = new SimpleAction ("local", null);
            local_action.activate.connect (local);
            action_group.add_action (local_action);

            insert_action_group ("auth", action_group);

            webview.load_changed.connect ((event) => {
                if (("https://music.yandex." in webview.uri) && event != LoadEvent.STARTED) {
                    online_complete ();
                } else {
                    warning ("Redirected to %s", webview.uri);
                }

                if (event == LoadEvent.FINISHED && is_loading) {
                    stop_loading ();
                }
            });

            var network_session = webview.get_network_session ();
            var cookie_manager = network_session.get_cookie_manager ();

            cookie_manager.set_persistent_storage (storager.cookies_file.peek_path (), CookiePersistentStorage.SQLITE);

            // Кнопка не блокируется, если выполнять не добавлять в Idle
            Idle.add_once (() => {
                block_widget (button_local_mode, BlockReason.NOT_IMPLEMENTED);
            });

            if (application.is_devel) {
                add_css_class ("devel");
            }
        }

        void refresh () {
            start_loading ();

            webview.reload ();
        }

        void online () {
            navigation_view.push_by_tag ("auth-page");

            start_loading ();

            webview.load_uri (
                "https://oauth.yandex.ru/authorize?response_type=token&client_id=23cabbbdc6cd418abb4b39c32c41195d" // vala-lint=line-length
            );
        }

        void local () {
            assert_not_reached ();

            //  choosed_local ();
            //  close ();
        }
    }
}
