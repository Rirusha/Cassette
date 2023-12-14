/* application.vala
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

    public static Application application;
    public static CassetteClient.Cachier.Storager storager;
    public static CassetteClient.Threader threader;
    static Authenticator authenticator;
    public static CassetteClient.YaMTalker yam_talker;
    public static CassetteClient.Player.Player player;
    public static CassetteClient.Cachier.CachierController cachier_controller;

    public enum ApplicationState {
        BEGIN,
        ONLINE,
        LOCAL,
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

                bool should_notify = false;

                if (_application_state != ApplicationState.BEGIN) {
                    should_notify = true;
                }

                _application_state = value;

                if (should_notify) {
                    application_state_changed (_application_state);
                }
            }
        }

        public bool is_mobile {
            get {
                if (main_window == null) {
                    return false;
                }

                return main_window.is_mobile_orientation;
            }
        }

        const string APP_NAME = "Cassette";
        const string RIRUSHA = "Rirusha <anerin.sidiver@yandex.ru>";
        const string TELEGRAM_CHAT = "https://t.me/CassetteGNOME_Discussion";
        const string TELEGRAM_CHANNEL = "https://t.me/CassetteGNOME_Devlog";
        const string ISSUE_LINK = "https://github.com/Rirusha/Cassette/issues/new";

        public signal void application_state_changed (ApplicationState new_state);

        public MainWindow main_window = null;

        public Application () {
            Object (
                application_id: Config.APP_ID,
                resource_base_path: "/com/github/Rirusha/Cassette/"
            );
        }

        construct {
            application = this;

            CassetteClient.init (Config.POSTFIX == ".Devel");
            CassetteClient.Mpris.mpris.quit_triggered.connect (() => {
                quit ();
            });
            CassetteClient.Mpris.mpris.raise_triggered.connect (() => {
                main_window.present ();
            });

            // Shortcuts
            storager = CassetteClient.storager;
            threader = CassetteClient.threader;
            authenticator = new Authenticator ();
            yam_talker = CassetteClient.yam_talker;
            player = CassetteClient.player;
            cachier_controller = CassetteClient.cachier_controller;

            authenticator.failed.connect (quit);

            yam_talker.connection_established.connect (() => {
                application_state = ApplicationState.ONLINE;
            });
            yam_talker.connection_lost.connect (() => {
                application_state = ApplicationState.OFFLINE;
            });

            _application_state = (ApplicationState) storager.settings.get_enum ("application-state");

            storager.settings.bind ("application-state", this, "application-state", SettingsBindFlags.DEFAULT);

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

            if (active_window == null) {
                main_window = new MainWindow (this);

                authenticator.success.connect (main_window.load_default_views);
                authenticator.local.connect (main_window.load_local_views);

                if (_application_state == ApplicationState.OFFLINE) {
                    _application_state = ApplicationState.ONLINE;
                }

                if (!storager.cookies_exists () && _application_state != ApplicationState.LOCAL) {
                    _application_state = ApplicationState.BEGIN;
                }

                main_window.present ();

                if (_application_state == ApplicationState.LOCAL) {
                    main_window.load_local_views ();
                } else {
                    authenticator.log_in ();
                }

            } else {
                main_window.present ();
            }
        }

        public void show_message (string message, bool is_notify = false) {
            main_window.show_message (message);

            if (is_notify) {
                var ntf = new Notification (APP_NAME);
                ntf.set_body (message);
                send_notification (null, ntf);
            }
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
                _("Arseniy Nechkin <krisgeniusnos@gmail.com>")
            };
            string[] documenters = {

            };

            var about = new Adw.AboutWindow () {
                transient_for = active_window,
                application_name = APP_NAME,
                application_icon = Config.APP_ID,
                developer_name = "Rirusha",
                version = Config.VERSION,
                developers = developers,
                designers = designers,
                artists = artists,
                documenters = documenters,
                //  Translators: NAME <EMAIL.COM> /n NAME <EMAIL.COM>
                translator_credits = _("translator-credits"),
                license_type = Gtk.License.GPL_3_0,
                copyright = "© 2023 Rirusha",
                support_url = TELEGRAM_CHAT,
                issue_url = ISSUE_LINK,
                release_notes_version = Config.VERSION
            };
            about.release_notes = _("<p>First release. For additional info check telegram channel</p>");
            about.add_link (_("Telegram channel"), TELEGRAM_CHANNEL);

            about.present ();
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
            main_window.player_bar.roll_shuffle_mode ();
        }

        void on_repeat () {
            main_window.player_bar.roll_repeat_mode ();
        }

        void on_next () {
            if (!player.is_loading) {
                player.next ();
            }
        }

        void on_prev () {
            if (!player.is_loading) {
                player.prev ();
            }
        }

        void on_preferences_action () {
            var pref_win = new PreferencesWindow () {
                transient_for = main_window,
                modal = true
            };

            pref_win.present ();
            pref_win.set_focus (null);
        }

        void on_share_current_track () {
            if (player.current_track?.ugc == false) {
                track_share (player.current_track);
            }
        }
    }
}
