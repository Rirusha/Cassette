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

    public class Application : Adw.Application {

        const ActionEntry[] ACTION_ENTRIES = {
            { "quit", quit },
            { "log-out", on_log_out_action },
            { "force-log-out", on_force_log_out_action },
            { "play-pause", on_play_pause_action },
            { "next", on_next_action },
            { "prev", on_prev_action },
            { "prev-force", on_prev_force_action },
            { "change-shuffle", on_change_shuffle_action },
            { "change-repeat", on_change_repeat_action },
            { "share-current-track", on_share_current_track_action},
            { "parse-url", on_parse_url_action },
            { "open-account", on_open_account_action },
            { "open-plus", on_open_plus_action },
            { "get-plus", on_get_plus_action },
            { "mute", on_mute_action },
        };

        const OptionEntry[] OPTION_ENTRIES = {
            { "version", 'v', 0, OptionArg.NONE, null, N_("Print version information and exit"), null },
            { null }
        };

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

                application_state_changed (_application_state, old_state);
            }
        }

        public signal void application_state_changed (
            ApplicationState new_state,
            ApplicationState old_state
        );

        public Window? main_window { get; private set; default = null; }

        uint now_playing_t = 0;

        public bool is_devel {
            get {
                return Config.IS_DEVEL;
            }
        }

        public Application () {
            Object (
                application_id: Config.APP_ID_DYN,
                resource_base_path: "/space/rirusha/Cassette/",
                flags: ApplicationFlags.DEFAULT_FLAGS | ApplicationFlags.HANDLES_OPEN
            );
        }

        construct {
            application = this;

            settings = new Settings ("space.rirusha.Cassette.application");

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

            player.current_track_finish_loading.connect (show_now_playing_notif);

            _application_state = (ApplicationState) settings.get_enum ("application-state");

            settings.bind ("application-state", this, "application-state", SettingsBindFlags.DEFAULT);

            application.application_state_changed.connect ((new_state, old_state) => {
                switch (new_state) {
                    case ApplicationState.ONLINE:
                        if (old_state == ApplicationState.OFFLINE) {
                            show_message (_("Connection restored"));
                        }
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

            add_main_option_entries (OPTION_ENTRIES);
            set_option_context_parameter_string ("[YANDEX-MUSIC-URL]");

            add_action_entries (ACTION_ENTRIES, this);
            set_accels_for_action ("app.quit", { "<primary>q" });
            set_accels_for_action ("app.play-pause", { "space" });
            set_accels_for_action ("app.prev", { "<Alt>Left" });
            set_accels_for_action ("app.next", { "<Alt>Right" });
            set_accels_for_action ("app.change-shuffle", { "<Ctrl>s" });
            set_accels_for_action ("app.change-repeat", { "<Ctrl>r" });
            set_accels_for_action ("app.share-current-track", { "<Ctrl><Shift>c" });
            set_accels_for_action ("app.parse-url", { "<Ctrl><Shift>v" });
            set_accels_for_action ("app.mute", { "<Ctrl>m" });
        }

        protected override int handle_local_options (VariantDict options) {
            if (options.contains ("version")) {
                print ("%s %s\n", Config.APP_NAME, Config.VERSION);
                return 0;
            }

            return -1;
        }

        protected override void open (File[] files, string hint) {
            activate ();

            if (application_state != ApplicationState.BEGIN && application_state != ApplicationState.LOCAL) {
                parse_on_window_loaded.begin (files[0].get_uri ());
            }
        }

        async void parse_on_window_loaded (string uri) {
            ulong con_id;

            if (!main_window.is_ready) {
                con_id = main_window.notify["is-ready"].connect (() => {
                    Idle.add (parse_on_window_loaded.callback);
                });

                yield;

                SignalHandler.disconnect (main_window, con_id);
            }

            parse_uri (uri);
        }

        public override void activate () {
            base.activate ();

            if (main_window == null) {
                main_window = new Window (this);

                authenticator.success.connect (main_window.load_default_views);
                authenticator.local.connect (main_window.load_local_views);

                if (_application_state == ApplicationState.OFFLINE) {
                    _application_state = ApplicationState.ONLINE;
                }

                main_window.close_request.connect (() => {
                    main_window = null;
                    return false;
                });

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

        public void show_message (string message) {
            if (main_window != null) {
                if (main_window.is_active) {
                    main_window.show_toast (message);
                    return;
                }
            }

            var ntf = new Notification (Config.APP_NAME);
            ntf.set_body (message);
            send_notification (null, ntf);
        }

        public void show_now_playing_notif (YaMAPI.Track track_info) {
            if (!settings.get_boolean ("show-playing-track-notif")) {
                return;
            }

            if (main_window != null) {
                if (main_window.is_active) {
                    return;
                }
            }

            var ntf = new Notification (Config.APP_NAME);

            ntf.set_body ("%s%s - %s".printf (
                track_info.title,
                track_info.version != null ? @" $(track_info.version)" : "",
                track_info.get_artists_names ()
            ));

            ntf.set_title (_("Playing now"));

            ntf.add_button (_("Previous"), "app.prev-force");
            ntf.add_button (_("Next"), "app.next");

            ntf.set_icon (new ThemedIcon ("%s-symbolic".printf (Config.APP_ID_DYN)));

            if (now_playing_t != 0) {
                Source.remove (now_playing_t);
            }

            send_notification ("now-playing", ntf);

            now_playing_t = Timeout.add_seconds_once (10, () => {
                withdraw_notification ("now-playing");
                now_playing_t = 0;
            });
        }

        void on_log_out_action () {
            authenticator.log_out ();
        }

        void on_force_log_out_action () {
            authenticator.force_log_out ();
        }

        void on_play_pause_action () {
            var text_entry = main_window.focus_widget as Gtk.Text;
            if (text_entry != null) {
                // Исправление ситуации, когда пробел нельзя вписать, так как клавиша забрана play-pause
                text_entry.insert_at_cursor (" ");
            } else {
                player.play_pause ();
            }
        }

        void on_change_shuffle_action () {
            roll_shuffle_mode ();
        }

        void on_change_repeat_action () {
            roll_repeat_mode ();
        }

        void on_next_action () {
            if (player.can_go_next) {
                player.next ();
            }
        }

        void on_prev_action () {
            if (player.can_go_prev) {
                player.prev ();
            }
        }

        void on_prev_force_action () {
            if (player.can_go_prev) {
                player.prev (true);
            }
        }

        public void show_no_plus_dialog () {
            var dialog = new NoPlusDialog () {
                log_out_button_visible = application_state != ApplicationState.BEGIN
            };

            dialog.closed.connect (() => {
                if (application_state == ApplicationState.BEGIN) {
                    application.activate_action ("force-log-out", null);

                } else {
                    application.activate_action ("quit", null);
                }
            });

            dialog.present (main_window);
        }

        void on_share_current_track_action () {
            var current_track = player.mode.get_current_track_info ();

            if (current_track?.is_ugc == false) {
                track_share (current_track);
            } else {
                show_message (_("Current track can not be copied to the clipboard"));
            }
        }

        void parse_uri (string uri) {
            string clear_uri = "";

            if (uri.has_prefix ("https://music.yandex.ru/")) {
                clear_uri = uri.replace ("https://music.yandex.ru/", "");

            } else if (uri.has_prefix ("yandexmusic://")) {
                clear_uri = uri.replace ("yandexmusic://", "");

            } else {
                Logger.warning (_("Can't parse clipboard content"));
                return;
            }

            string[] parts = clear_uri.split ("/");

            if (parts.length < 2) {
                Logger.warning (_("Can't parse clipboard content"));
                return;
            }

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

                        main_window?.current_view.add_view (new PlaylistView (user_id, kind));
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
        }

        void on_parse_url_action () {
            activate ();

            Gdk.Display? display = Gdk.Display.get_default ();
            Gdk.Clipboard clipboard = display.get_clipboard ();

            clipboard.read_text_async.begin (null, (obj, res) => {
                try {
                    parse_uri (clipboard.read_text_async.end (res));

                } catch (Error e) {
                    show_message (_("Can't parse clipboard content"));
                }
            });
        }

        void on_open_account_action () {
            new Gtk.UriLauncher ("https://id.yandex.ru/").launch.begin (null, null);
        }

        void on_open_plus_action () {
            new Gtk.UriLauncher ("https://plus.yandex.ru/").launch.begin (null, null);
        }

        void on_get_plus_action () {
            new Gtk.UriLauncher ("https://plus.yandex.ru/getplus/").launch.begin (null, null);
        }

        void on_mute_action () {
            player.mute = !player.mute;
        }
    }
}
