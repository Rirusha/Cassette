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
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */


using Cassette.Client;

[GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/main_window.ui")]
public class Cassette.MainWindow : ApplicationWindow {

    [GtkChild]
    unowned Adw.ToolbarView player_bar_toolbar;
    [GtkChild]
    unowned SideBar sidebar;
    [GtkChild]
    unowned Adw.ToastOverlay toast_overlay;
    [GtkChild]
    unowned HeaderBar header_bar;
    [GtkChild]
    unowned Adw.ToolbarView search_toolbar;
    [GtkChild]
    unowned Gtk.SearchEntry search_entry;
    [GtkChild]
    unowned Adw.Banner info_banner;
    [GtkChild]
    unowned Gtk.Stack loading_stack;
    [GtkChild]
    unowned Adw.ViewStack main_stack;
    [GtkChild]
    unowned Adw.ToolbarView switcher_toolbar;

    int reconnect_timer = Cassette.Client.TIMEOUT;

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
                header_bar,
                "can-backward",
                GLib.BindingFlags.SYNC_CREATE
            );

            current_view_can_refresh_binding = _current_view.bind_property (
                "can-refresh",
                header_bar,
                "can-refresh",
                GLib.BindingFlags.SYNC_CREATE
            );
        }
    }

    public SideBar window_sidebar {
        get {
            return sidebar;
        }
    }

    public MainWindow (Cassette.Application app) {
        Object (application: app);
    }

    construct {
        info_banner.button_clicked.connect (try_reconnect);

        var gs = new Gtk.GestureClick ();
        gs.end.connect (() => {
            sidebar.close ();
        });
        switcher_bar.add_controller (gs);

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
            var dilaog = new AccountInfoDialog (yam_talker.me);
            dilaog.present (this);
        });
        add_action (account_info_action);

        pager = new Pager (this, main_stack);

        Cassette.settings.bind ("window-width", this, "default-width", SettingsBindFlags.DEFAULT);
        Cassette.settings.bind ("window-height", this, "default-height", SettingsBindFlags.DEFAULT);
        Cassette.settings.bind ("window-maximized", this, "maximized", SettingsBindFlags.DEFAULT);

        header_bar.backward_clicked.connect ((obj) => {
            current_view.backward ();
        });

        header_bar.refresh_clicked.connect ((obj) => {
            current_view.refresh ();
        });

        if (Cassette.application.is_devel) {
            add_css_class ("devel");
        }

        header_bar.search_toggled.connect ((active) => {
            search_toolbar.reveal_top_bars = active;
        });

        notify["is-shrinked"].connect (() => {
            header_bar.switcher_visible = !is_shrinked;
            switcher_toolbar.reveal_bottom_bars = is_shrinked;
        });
    }

    public void set_online () {
        info_banner.revealed = false;
    }

    public void set_offline () {
        info_banner.revealed = true;
    }

    public void load_default_views () {
        if (loading_stack.visible_child_name == "loading") {
            pager.load_pages (PagesType.ONLINE);
            loading_stack.visible_child_name = "done";

            //  load_avatar.begin ();
            yam_talker.update_all.begin ();
            header_bar.can_search = true;

            header_bar.sensitive = true;

            cachier.check_all_cache.begin ();

            notify["is-active"].connect (() => {
                if (
                    is_active &&
                    player.state != Player.State.PLAYING
                ) {
                    yam_talker.update_all.begin ();
                }
            });
        }
    }

    public void load_local_views () {
        if (loading_stack.visible_child_name == "loading") {
            pager.load_pages (PagesType.LOCAL);
            loading_stack.visible_child_name = "done";

            //  avatar_button.visible = false;
            //  action_set_enabled ("win.show-disliked-tracks", false);
            //  action_set_enabled ("win.parse-url", false);

            //  app_menu_button.sensitive = true;
            //  button_refresh.sensitive = true;
        }
    }

    public void show_toast (string message) {
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
                reconnect_timer = Cassette.Client.TIMEOUT;
                return Source.REMOVE;
            }
        });
    }

    //  async void load_avatar () {
    //      avatar.text = yam_talker.me.public_name;
    //      avatar.size = 22;
    //      var pixbuf = yield Cachier.get_image (yam_talker.me, 28);
    //      if (pixbuf != null) {
    //          avatar.custom_image = Gdk.Texture.for_pixbuf (pixbuf);
    //      }

    //      avatar_button.sensitive = true;
    //  }

    void parse_url_from_clipboard () {
        Gdk.Display? display = Gdk.Display.get_default ();
        Gdk.Clipboard clipboard = display.get_clipboard ();

        clipboard.read_text_async.begin (null, (obj, res) => {
            try {
                string url = clipboard.read_text_async.end (res);

                if (!url.has_prefix ("https://music.yandex.ru/")) {
                    show_toast (_("Can't parse clipboard content"));
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
                            show_toast (_("Users view not implemented yet"));
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
                        show_toast (_("Albums view not implemented yet"));

                    // album 87894564 track 54654
                    } else {
                        string track_id;

                        if ("?" in parts[3]) {
                            track_id = parts[3].split ("?")[0];
                        } else {
                            track_id = parts[3];
                        }

                        show_track_by_id.begin (track_id);

                        show_toast (_("Albums view not implemented yet"));
                    }
                }

            } catch (Error e) {
                show_toast (_("Can't parse clipboard content"));
            }
        });
    }

    public void show_player_bar () {
        player_bar_toolbar.reveal_bottom_bars = true;
    }

    public void hide_player_bar () {
        player_bar_toolbar.reveal_bottom_bars = false;
    }
}
