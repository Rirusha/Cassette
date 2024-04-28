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

[GtkTemplate (ui = "/io/github/Rirusha/Cassette/ui/window.ui")]
public class Cassette.Window : ApplicationWindow {

    const ActionEntry[] ACTION_ENTRIES = {
        { "welcome", on_welcome_activate },
        { "close-sidebar", on_close_sidebar_activate },
        { "show-disliked-tracks", on_show_disliked_tracks_activate },
        { "open-in-browser", on_open_in_browser_activate },
        { "accoint-info", on_account_info_activate },
        { "preferences", on_preferences_activate },
        { "about", on_about_activate },
    };

    [GtkChild]
    unowned Adw.ToolbarView player_bar_toolbar;
    [GtkChild]
    unowned SideBar sidebar;
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

    public Window (Cassette.Application app) {
        Object (application: app);
    }

    construct {
        info_banner.button_clicked.connect (try_reconnect);

        main_stack.notify["visible-child-name"].connect (() => {
            activate_action ("close-sidebar", null);
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

        notify["is-shrinked"].connect (() => {
            header_bar.switcher_visible = !is_shrinked;
            switcher_toolbar.reveal_bottom_bars = is_shrinked;
        });

        loading_stack.notify["visible-child"].connect (() => {
            if (loading_stack.visible_child_name == "done") {
                on_welcome_activate ();
            }
        });

        if (Cassette.application.is_devel) {
            add_css_class ("devel");
        }
    }

    void on_preferences_activate () {
        var pref_win = new PreferencesDialog ();

        pref_win.present (this);
    }

    void on_about_activate () {
        const string RIRUSHA = "Rirusha https://github.com/Rirusha";
        const string TELEGRAM_CHAT = "https://t.me/CassetteGNOME_Discussion";
        const string TELEGRAM_CHANNEL = "https://t.me/CassetteGNOME_Devlog";
        const string ISSUE_LINK = "https://github.com/Rirusha/Cassette/issues/new";

        string[] developers = {
            RIRUSHA
        };

        string[] designers = {
            RIRUSHA
        };

        string[] artists = {
            RIRUSHA,
            "Arseniy Nechkin <krisgeniusnos@gmail.com>",
            "NaumovSN",
        };

        string[] documenters = {
            RIRUSHA,
            "Armatik https://github.com/Armatik",
            "Fiersik https://github.com/fiersik",
            "Mikazil https://github.com/Mikazil",
        };

        var about = new Adw.AboutDialog () {
            application_name = Config.APP_NAME,
            application_icon = Config.APP_ID_DYN,
            developer_name = "Rirusha",
            version = Config.VERSION,
            developers = developers,
            designers = designers,
            artists = artists,
            documenters = documenters,
            //  Translators: NAME <EMAIL.COM> /n NAME <EMAIL.COM>
            translator_credits = _("translator-credits"),
            license_type = Gtk.License.GPL_3_0_ONLY,
            copyright = "© 2023-2024 Rirusha",
            support_url = TELEGRAM_CHAT,
            issue_url = ISSUE_LINK,
            release_notes_version = Config.VERSION
        };

        about.add_link (_("Telegram channel"), TELEGRAM_CHANNEL);
        about.add_link (_("Financial support (Tinkoff)"), "https://www.tinkoff.ru/cf/21GCxLuFuE9");
        about.add_link (_("Financial support (Boosty)"), "https://boosty.to/rirusha/donate");

        about.add_acknowledgement_section ("Donaters", {
            "katze_942", "gen1s", "Semen Fomchenkov", "Oleg Shchavelev", "Fissium", "Fiersik", "belovmv",
            "krylov_alexandr", "Spp595", "Mikazil", "Sergey P.", "khaustovdn", "dant4ick", "Nikolai M.",
            "Toxblh", "Roman Aysin", "IQQator", "𝙰𝚖𝚙𝚎𝚛 𝚂𝚑𝚒𝚣"
        });

        about.present (this);
    }

    void on_account_info_activate () {
        var dilaog = new AccountInfoDialog (yam_talker.me);
        dilaog.present (this);
    }

    void on_open_in_browser_activate () {
        try {
            Process.spawn_command_line_async ("xdg-open https://id.yandex.ru/");

        } catch (SpawnError e) {
            Logger.warning (_("Error while opening uri: %s").printf (e.message));
        }
    }

    void on_show_disliked_tracks_activate () {
        current_view.add_view (new DislikedTracksView ());
    }

    void on_close_sidebar_activate () {
        sidebar.close ();
    }

    void on_welcome_activate () {
        switch (settings.get_string ("last-version")) {
            case Config.VERSION:
                break;

            case "0.0.0":
                break;

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

    //  async void load_avatar () {
    //      avatar.text = yam_talker.me.public_name;
    //      avatar.size = 22;
    //      var pixbuf = yield Cachier.get_image (yam_talker.me, 28);
    //      if (pixbuf != null) {
    //          avatar.custom_image = Gdk.Texture.for_pixbuf (pixbuf);
    //      }

    //      avatar_button.sensitive = true;
    //  }

    public void show_player_bar () {
        player_bar_toolbar.reveal_bottom_bars = true;
    }

    public void hide_player_bar () {
        player_bar_toolbar.reveal_bottom_bars = false;
    }
}
