/* window.vala
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
    [GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/main_window.ui")]
    public class MainWindow : Adw.ApplicationWindow {
        [GtkChild]
        unowned Adw.ViewSwitcher switcher_title;
        [GtkChild]
        unowned Gtk.Button button_backward;
        [GtkChild]
        unowned Gtk.Button button_refresh;
        [GtkChild]
        unowned Gtk.MenuButton avatar_button;
        [GtkChild]
        unowned Adw.Avatar avatar;
        [GtkChild]
        public unowned SideBar sidebar;
        [GtkChild]
        unowned Gtk.ToggleButton button_search;
        [GtkChild]
         unowned Adw.ToastOverlay toast_overlay;
        [GtkChild]
        unowned Adw.ViewStack main_stack;
        [GtkChild]
        unowned Gtk.Stack loading_stack;
        [GtkChild]
        unowned Gtk.MenuButton app_menu_button;
        [GtkChild]
        unowned PlayerBar player_bar;
        [GtkChild]
        unowned Gtk.Revealer search_revealer;
        [GtkChild]
        unowned Gtk.Revealer sidebar_toggle_revealer;
        [GtkChild]
        unowned Adw.ToolbarView toolbar_view;
        [GtkChild]
        unowned Gtk.SearchEntry search_entry;
        [GtkChild]
        unowned Gtk.ToggleButton sidebar_toggle_button;
        [GtkChild]
        unowned Adw.Banner info_banner;
        [GtkChild]
        unowned Adw.HeaderBar header_bar;

        public bool is_mobile_orientation {
            get {
                if ((float) get_width () / (float) get_height () < 0.6f) {
                    return true;
                } else {
                    return false;
                }
            }
        }

        int reconnect_timer = 5;

        public Pager pager { get; construct; }

        GLib.Binding? current_view_can_back_binding = null;
        GLib.Binding? current_view_can_refresh_binding = null;
        PageRoot _current_view;
        public PageRoot current_view {
            get {
                return _current_view;
            }
            set {
                if (current_view_can_back_binding != null) {
                    current_view_can_back_binding.unbind ();
                }
                if (current_view_can_refresh_binding != null) {
                    current_view_can_refresh_binding.unbind ();
                }

                _current_view = value;
                current_view_can_back_binding = _current_view.bind_property (
                    "can-back",
                    button_backward,
                    "sensitive",
                    GLib.BindingFlags.SYNC_CREATE
                );

                current_view_can_refresh_binding = _current_view.bind_property (
                    "can-refresh",
                    button_refresh,
                    "visible",
                    GLib.BindingFlags.SYNC_CREATE
                );
            }
        }

        public MainWindow (Cassette.Application app) {
            Object (application: app);
        }

        construct {
            var gs = new Gtk.GestureClick ();
            gs.pressed.connect (() => {
                set_focus (null);
            });
            header_bar.add_controller (gs);

            sidebar.notify["is-shown"].connect (() => {
                if (sidebar.is_shown) {
                    sidebar_toggle_revealer.reveal_child = true;
                    sidebar_toggle_button.active = true;
                } else {
                    sidebar_toggle_revealer.reveal_child = false;
                }
            });

            sidebar_toggle_button.notify["active"].connect (() => {
                if (!sidebar_toggle_button.active) {
                    sidebar.is_shown = false;
                }
            });

            main_stack.notify["visible-child"].connect (() => {
                Adw.ViewStackPage current_page = main_stack.get_page (main_stack.get_visible_child ());
            });

            info_banner.button_clicked.connect (try_reconnect);

                //  try {
                //      string cmd = "";

                //      switch (Environment.get_variable ("XDG_CURRENT_DESKTOP")) {
                //          case "GNOME":
                //              cmd = "gnome-control-center network";
                //              break;
                //          default:
                //              Logger.warning ("Unsupported DE '%s'. You can create issue on github: %s.".printf (
                //                  Environment.get_variable ("XDG_CURRENT_DESKTOP"),
                //                  "https://github.com/Rirusha/Cassette/issues/new/choose"
                //              ));
                //      }

                //      Process.spawn_command_line_sync (cmd);
                //  } catch (SpawnError e) {
                //      Logger.warning ("Error while opening network settings. Error message: %s".printf (e.message));
                //  }
            //  });

            var show_disliked_tracks_action = new SimpleAction ("show-disliked-tracks", null);
            show_disliked_tracks_action.activate.connect (() => {
                current_view.add_view (new DislikedTracksView ());
            });
            add_action (show_disliked_tracks_action);

            var parse_uri_action = new SimpleAction ("parse-url", null);
            parse_uri_action.activate.connect (parse_url_from_clipboard);
            add_action (parse_uri_action);

            var open_account_in_browser_action = new SimpleAction ("open-in-browser", null);
            open_account_in_browser_action.activate.connect (() => {
                try {
                    Process.spawn_command_line_async ("xdg-open https://id.yandex.ru/");
                } catch (SpawnError e) {
                    Logger.warning (_("Error while opening uri: %s").printf (e.message));
                }

            });
            add_action (open_account_in_browser_action);

            var account_info_action = new SimpleAction ("accoint-info", null);
            account_info_action.activate.connect (() => {
                var win = new AccountInfoWindow (yam_talker.me) {
                    transient_for = this,
                    modal = true
                };
                win.present ();
            });
            add_action (account_info_action);

            pager = new Pager (this, main_stack);

            CassetteClient.storager.settings.bind ("window-width", this, "default-width", SettingsBindFlags.DEFAULT);
            storager.settings.bind ("window-height", this, "default-height", SettingsBindFlags.DEFAULT);
            storager.settings.bind ("window-maximized", this, "maximized", SettingsBindFlags.DEFAULT);

            button_backward.clicked.connect ((obj) => {
                current_view.backward ();
            });

            button_refresh.clicked.connect ((obj) => {
                current_view.refresh ();
            });

            if (Config.POSTFIX == ".Devel") {
                add_css_class ("devel");
            }

            Cassette.application.application_state_changed.connect ((new_state) => {
                switch (new_state) {
                    case ApplicationState.ONLINE:
                        show_message (_("Connection restored"));
                        set_online ();
                        break;
                    case ApplicationState.OFFLINE:
                        set_offline ();
                        break;
                    default:
                        break;
                }
            });

            SimpleAction search_action = new SimpleAction ("search", null);
            search_action.activate.connect (() => {
                button_search.active = true;
            });
            add_action (search_action);

            button_search.bind_property ("active", search_revealer, "reveal-child", BindingFlags.DEFAULT);
            search_revealer.notify["reveal-child"].connect (() => {
                if (search_revealer.reveal_child) {
                    set_focus (search_entry);
                }
            });

            show.connect (() => {
                change (get_width (), get_height ());
            });

            block_widget (button_search, BlockReason.NOT_IMPLEMENTED);
        }

        public void set_online () {
            info_banner.revealed = false;
            avatar_button.sensitive = true;
        }

        public void set_offline () {
            info_banner.revealed = true;
            avatar_button.sensitive = false;
        }

        public void load_default_views () {
            if (loading_stack.visible_child_name == "loading") {
                pager.load_pages (PagesType.ONLINE);
                loading_stack.visible_child_name = "done";

                load_avatar.begin ();
                player_bar.update_queue.begin ();

                app_menu_button.sensitive = true;
                button_refresh.sensitive = true;

                cachier.check_all_cache ();

                notify["is-active"].connect (() => {
                    if (
                        is_active &&
                        storager.settings.get_boolean ("try-load-queue-every-activate") &&
                        player.player_state != Player.PlayerState.PLAYING
                    ) {
                        player_bar.update_queue.begin ();
                    }
                });
            }
        }

        public void load_local_views () {
            if (loading_stack.visible_child_name == "loading") {
                pager.load_pages (PagesType.LOCAL);
                loading_stack.visible_child_name = "done";

                avatar_button.visible = false;
                action_set_enabled ("win.show-disliked-tracks", false);
                action_set_enabled ("win.parse-url", false);

                app_menu_button.sensitive = true;
                button_refresh.sensitive = true;
            }
        }

        public void show_message (string message) {
            var toast = new Adw.Toast (message);
            toast_overlay.add_toast (toast);

            Logger.info (_("Window info message: %s").printf (message));
        }

        async void try_reconnect () {
            info_banner.sensitive = false;
            info_banner.button_label = reconnect_timer.to_string ();

            Timeout.add_seconds (1, () => {
                if (reconnect_timer > 1) {
                    reconnect_timer--;
                    info_banner.button_label = reconnect_timer.to_string ();
                    return Source.CONTINUE;

                } else {
                    info_banner.sensitive = true;
                    info_banner.button_label = _("Reconnect");
                    reconnect_timer = 5;
                    return Source.REMOVE;
                }
            });

            player_bar.update_queue.begin ();
        }

        async void load_avatar () {
            avatar.text = yam_talker.me.account.get_user_name ();
            avatar.size = 22;
            var pixbuf = yield Cachier.get_image (yam_talker.me, 28);
            if (pixbuf != null) {
                avatar.custom_image = Gdk.Texture.for_pixbuf (pixbuf);
            }

            avatar_button.sensitive = true;
        }

        void parse_url_from_clipboard () {
            Gdk.Display? display = Gdk.Display.get_default ();
            Gdk.Clipboard clipboard = display.get_clipboard ();

            clipboard.read_text_async.begin (null, (obj, res) => {
                try {
                    string url = clipboard.read_text_async.end (res);

                    if (!url.has_prefix ("https://music.yandex.ru/")) {
                        show_message (_("Can't parse clipboard content"));
                        return;
                    }

                    string[] parts = url.split ("/");

                    // Cut https://music.yandex.ru
                    parts = parts [3:parts.length];

                    // users 737063213
                    if (parts[0] == "users") {
                        string user_id = parts[1];

                        // playlists ~
                        if (parts[2] == "playlists") {
                            if (parts.length == 3) {
                                show_message (_("Users view not implemented yet"));
                                return;

                            // playlists 3
                            } else {
                                string kind = parts[3];

                                current_view.add_view (new PlaylistView (user_id, kind));
                            }
                        }

                    // album 4545465
                    } else if (parts[0] == "album") {
                        // string album_id = parts[1];

                        if (parts.length == 2) {
                            show_message (_("Albums view not implemented yet"));

                        // album 87894564 track 54654
                        } else {
                            string track_id;

                            if ("?" in parts[3]) {
                                track_id = parts[3].split ("?")[0];
                            } else {
                                track_id = parts[3];
                            }

                            show_track_by_id.begin (track_id);

                            show_message (_("Albums view not implemented yet"));
                        }
                    }

                } catch (Error e) {
                    show_message (_("Can't parse clipboard content"));
                }
            });
        }

        public void show_player_bar () {
            toolbar_view.reveal_bottom_bars = true;
        }

        public void hide_player_bar () {
            toolbar_view.reveal_bottom_bars = false;
        }

        // Адаптивное окно, не используется Adw.Breakpoint, так как каждый
        // триггер Breakpoint - вызов сигналов unmap и map, что
        // подтормаживает приложение при прохождении breakpoint'а
        protected override void size_allocate (int width, int height, int baseline) {
            base.size_allocate (width, height, baseline);

            change (width, height);
        }

        void change (int width, int height) {
            if (width > 950) {
                if (switcher_title.policy == Adw.ViewSwitcherPolicy.NARROW) {
                    switcher_title.policy = Adw.ViewSwitcherPolicy.WIDE;
                }
            } else {
                if (switcher_title.policy == Adw.ViewSwitcherPolicy.WIDE) {
                    switcher_title.policy = Adw.ViewSwitcherPolicy.NARROW;
                }
            }

            if (width > 1055) {
                if (sidebar.collapsed) {
                    sidebar.collapsed = false;
                }
            } else {
                if (!sidebar.collapsed) {
                    sidebar.collapsed = true;
                }
            }
        }
    }
}
