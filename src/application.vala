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


namespace Cassette {

    static Authenticator authenticator;

    public static Application application;
    public static Cassette.Client.Cachier.Cachier cachier;
    public static Cassette.Client.Cachier.Storager storager;
    public static Cassette.Client.Threader threader;
    public static Cassette.Client.YaMTalker yam_talker;
    public static Cassette.Client.Player.Player player;

    public static Settings settings;

    public enum ApplicationState {
        BEGIN,
        LOCAL,
        ONLINE,
        OFFLINE
    }

    // Класс приложения
    public class Application : Adw.Application {

        ApplicationState _application_state;
        public ApplicationState application_state {
            get {
                return _application_state;
            }
            set {
                if (_application_state == value) {
                    return;
                }

                var old_state = _application_state;

                _application_state = value;

                // Don't write "Connection restored" after auth
                if (old_state != ApplicationState.BEGIN) {
                    application_state_changed (_application_state);
                }
            }
        }

        public bool is_mobile { get; private set; default = false; }

        const string APP_NAME = "Cassette";
        const string RIRUSHA = "Rirusha https://github.com/Rirusha";
        const string TELEGRAM_CHAT = "https://t.me/CassetteGNOME_Discussion";
        const string TELEGRAM_CHANNEL = "https://t.me/CassetteGNOME_Devlog";
        const string ISSUE_LINK = "https://github.com/Rirusha/Cassette/issues/new";

        public signal void application_state_changed (ApplicationState new_state);

        public MainWindow? main_window {
            get {
                return (MainWindow?) active_window;
            }
        }

        public bool is_devel {
            get {
                return Config.PROFILE == "Devel";
            }
        }

        public Application () {
            Object (
                application_id: Config.APP_ID_DYN,
                resource_base_path: "/com/github/Rirusha/Cassette/"
            );
        }

        construct {
            application = this;

            settings = new Settings ("io.github.Rirusha.Cassette.application");

            Cassette.Client.init (is_devel);

            Cassette.Client.Mpris.mpris.quit_triggered.connect (() => {
                quit ();
            });
            Cassette.Client.Mpris.mpris.raise_triggered.connect (() => {
                main_window.present ();
            });

            // Shortcuts
            cachier = Cassette.Client.cachier;
            storager = Cassette.Client.storager;
            threader = Cassette.Client.threader;
            authenticator = new Authenticator ();
            yam_talker = Cassette.Client.yam_talker;
            player = Cassette.Client.player;

            yam_talker.connection_established.connect (() => {
                application_state = ApplicationState.ONLINE;
            });
            yam_talker.connection_lost.connect (() => {
                application_state = ApplicationState.OFFLINE;
            });

            _application_state = (ApplicationState) settings.get_enum ("application-state");

            settings.bind ("application-state", this, "application-state", SettingsBindFlags.DEFAULT);

            application.application_state_changed.connect ((new_state) => {
                switch (new_state) {
                    case ApplicationState.ONLINE:
                        show_message (_("Connection restored"));
                        main_window?.set_online ();
                        break;
                    case ApplicationState.OFFLINE:
                        show_message (_("Connection problems"));
                        main_window?.set_offline ();
                        break;
                    default:
                        break;
                }
            });

            ActionEntry[] action_entries = {
                { "about", on_about_action },
                { "preferences", on_preferences_action },
                { "quit", quit },
                { "log-out", on_log_out },
                { "play-pause", on_play_pause },
                { "next", on_next },
                { "prev", on_prev },
                { "change-shuffle", on_shuffle },
                { "change-repeat", on_repeat },
                { "share-current-track", on_share_current_track}
            };
            add_action_entries (action_entries, this);
            set_accels_for_action ("app.quit", { "<primary>q" });
            set_accels_for_action ("app.play-pause", { "space" });
            set_accels_for_action ("app.prev", { "<Ctrl>a" });
            set_accels_for_action ("app.next", { "<Ctrl>d" });
            set_accels_for_action ("app.change-shuffle", { "<Ctrl>s" });
            set_accels_for_action ("app.change-repeat", { "<Ctrl>r" });
            set_accels_for_action ("app.share-current-track", { "<Ctrl><Shift>c" });
        }

        public override void activate () {
            base.activate ();

            if (main_window == null) {
                var win = new MainWindow (this);

                authenticator.success.connect (win.load_default_views);
                authenticator.local.connect (win.load_local_views);

                if (_application_state == ApplicationState.OFFLINE) {
                    _application_state = ApplicationState.ONLINE;
                }

                win.present ();

                if (_application_state == ApplicationState.LOCAL) {
                    win.load_local_views ();
                } else {
                    authenticator.log_in ();
                }

            } else {
                main_window.present ();
            }
        }

        public void show_message (string message) {
            if (main_window != null) {
                if (main_window.is_active) {
                    main_window.show_toast (message);
                    return;
                }
            }

            var ntf = new Notification (APP_NAME);
            ntf.set_body (message);
            send_notification (null, ntf);
        }

        void on_about_action () {
            string[] developers = {
                RIRUSHA
            };

            string[] designers = {
                RIRUSHA
            };

            string[] artists = {
                RIRUSHA,
                "Arseniy Nechkin <krisgeniusnos@gmail.com>",
                "NaumovSN"
            };

            string[] documenters = {

            };

            var about = new Adw.AboutDialog () {
                application_name = APP_NAME,
                application_icon = Config.APP_ID_DYN,
                developer_name = "Rirusha",
                version = Config.VERSION,
                developers = developers,
                designers = designers,
                artists = artists,
                documenters = documenters,
                //  Translators: NAME <EMAIL.COM> /n NAME <EMAIL.COM>
                translator_credits = _("translator-credits"),
                license_type = Gtk.License.GPL_3_0,
                copyright = "© 2023-2024 Rirusha",
                support_url = TELEGRAM_CHAT,
                issue_url = ISSUE_LINK,
                release_notes_version = Config.VERSION
            };

            about.add_link (_("Telegram channel"), TELEGRAM_CHANNEL);
            about.add_link (_("Financial support"), "https://www.tinkoff.ru/cf/21GCxLuFuE9");

            about.add_acknowledgement_section ("Donaters", {
                "katze_942", "gen1s", "Semen Fomchenkov", "Oleg Shchavelev", "Fissium", "Fiersik", "belovmv",
                "krylov_alexandr", "Spp595", "Mikazil", "Sergey P.", "khaustovdn", "dant4ick", "Nikolai M."
            });

            about.present (main_window);
        }

        void on_log_out () {
            authenticator.log_out ();
        }

        void on_play_pause () {
            var text_entry = main_window.focus_widget as Gtk.Text;
            if (text_entry != null) {
                // Исправление ситуации, когда пробел нельзя вписать, так как клавиша забрана play-pause
                text_entry.insert_at_cursor (" ");
            } else {
                player.play_pause ();
            }
        }

        void on_shuffle () {
            roll_shuffle_mode ();
        }

        void on_repeat () {
            roll_repeat_mode ();
        }

        void on_next () {
            if (!player.track_loading) {
                player.next ();
            }
        }

        void on_prev () {
            if (player.can_go_prev) {
                player.prev ();
            }
        }

        void on_preferences_action () {
            var pref_win = new PreferencesDialog ();

            pref_win.present (main_window);
        }

        void on_share_current_track () {
            var current_track = player.get_current_track_info ();

            if (current_track?.is_ugc == false) {
                track_share (current_track);
            }
        }
    }
}
