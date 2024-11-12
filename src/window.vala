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

[GtkTemplate (ui = "/space/rirusha/Cassette/ui/window.ui")]
public class Cassette.Window : ApplicationWindow {

    const ActionEntry[] ACTION_ENTRIES = {
        { "close-sidebar", on_close_sidebar_action },
        { "show-disliked-tracks", on_show_disliked_tracks_action },
        { "preferences", on_preferences_action },
        { "about", on_about_action },
    };

    [GtkChild]
    unowned Adw.ToolbarView player_bar_toolbar;
    [GtkChild]
    unowned Sidebar sidebar;
    [GtkChild]
    unowned Adw.ToastOverlay toast_overlay;
    [GtkChild]
    unowned HeaderBar header_bar;
    [GtkChild]
    unowned Gtk.SearchEntry search_entry;
    [GtkChild]
    unowned Adw.Banner info_banner;
    [GtkChild]
    unowned Gtk.Stack loading_stack;
    [GtkChild]
    unowned LoadingSpinner loading_spinner;
    [GtkChild]
    unowned Adw.ViewStack main_stack;
    [GtkChild]
    unowned Adw.ToolbarView switcher_toolbar;
    [GtkChild]
    unowned PlayerBar player_bar;

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

    public Sidebar window_sidebar {
        get {
            return sidebar;
        }
    }

    // TODO: Remove this
    public bool player_bar_is_visible { get; set; }

    public bool is_ready { get; private set; default = false; }

    public Window (Cassette.Application app) {
        Object (application: app);
    }

    construct {
        info_banner.button_clicked.connect (try_reconnect);

        main_stack.notify["visible-child-name"].connect (() => {
            if (sidebar.collapsed) {
                activate_action ("close-sidebar", null);
            }
        });

        pager = new Pager (this, main_stack);

        add_action_entries (ACTION_ENTRIES, this);

        Cassette.settings.bind ("window-width", this, "default-width", SettingsBindFlags.DEFAULT);
        Cassette.settings.bind ("window-height", this, "default-height", SettingsBindFlags.DEFAULT);
        Cassette.settings.bind ("window-maximized", this, "maximized", SettingsBindFlags.DEFAULT);

        header_bar.backward_clicked.connect ((obj) => {
            current_view.backward ();
        });

        header_bar.refresh_clicked.connect ((obj) => {
            current_view.refresh ();
        });

        sidebar.notify["collapsed"].connect (check_bar_visible);
        sidebar.notify["is-shown"].connect (check_bar_visible);
        notify["is-shrinked"].connect (check_bar_visible);

        loading_stack.notify["visible-child"].connect (() => {
            if (loading_stack.visible_child_name == "done") {
                do_welcome.begin ();

                is_ready = true;
            }
        });

        close_request.connect (on_close_request);

        if (Cassette.application.is_devel) {
            add_css_class ("devel");
        }
    }

    bool on_close_request () {
        if (window_sidebar.sidebar_child == null) {
            return false;

        } else {
            window_sidebar.close ();
            return true;
        }
    }

    void check_bar_visible () {
        switcher_toolbar.reveal_bottom_bars = (sidebar.collapsed && sidebar.is_shown) || is_shrinked;
    }

    void on_preferences_action () {
        var pref_win = new PreferencesDialog ();

        pref_win.present (this);
    }

    void on_about_action () {
        var about = build_about_dialog ();

        about.present (this);
    }

    void on_show_disliked_tracks_action () {
        current_view.add_view (new DislikedTracksView ());
    }

    void on_close_sidebar_action () {
        sidebar.close ();
    }

    async void do_welcome () {
        switch (settings.get_string ("last-version")) {
            default:
                break;
        }

        settings.set_string ("last-version", Config.VERSION);
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

            header_bar.load_avatar.begin ();
            yam_talker.update_all.begin ();
            header_bar.can_search = true;

            header_bar.interactive = true;

            cachier.check_all_cache.begin ();

            notify["is-active"].connect (() => {
                if (
                    is_active &&
                    player.state != Player.State.PLAYING
                ) {
                    yam_talker.update_all.begin ();
                }
            });

            loading_stack.visible_child_name = "done";
        }
    }

    public void load_local_views () {
        if (loading_stack.visible_child_name == "loading") {
            pager.load_pages (PagesType.LOCAL);
            loading_stack.visible_child_name = "done";
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

        yam_talker.update_all.begin ();

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

    public void show_player_bar () {
        player_bar_toolbar.reveal_bottom_bars = true;
    }

    public void hide_player_bar () {
        player_bar_toolbar.reveal_bottom_bars = false;
    }
}
