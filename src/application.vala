/*
 * Copyright (C) 2023-2025 Vladimir Romanov <rirusha@altlinux.org>
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see
 * <https://www.gnu.org/licenses/gpl-3.0-standalone.html>.
 * 
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Tape;

public sealed class Cassette.Application : Adw.Application {

    const ActionEntry[] ACTION_ENTRIES = {
        { "quit", quit },
        { "show-message", show_message, "s" },
        //  { "log-out", on_log_out_action },
        //  { "force-log-out", on_force_log_out_action },
        //  { "play-pause", on_play_pause_action },
        //  { "next", on_next_action },
        //  { "prev", on_prev_action },
        //  { "prev-force", on_prev_force_action },
        //  { "change-shuffle", on_change_shuffle_action },
        //  { "change-repeat", on_change_repeat_action },
        //  { "share-current-track", on_share_current_track_action},
        //  { "parse-url", on_parse_url_action },
        //  { "open-account", on_open_account_action },
        //  { "open-plus", on_open_plus_action },
        //  { "get-plus", on_get_plus_action },
        //  { "mute", on_mute_action },
    };

    const OptionEntry[] OPTION_ENTRIES = {
        { "version", 'v', 0, OptionArg.NONE, null, N_("Print version information and exit"), null },
        { null }
    };

    public static GLib.Settings app_settings;
    public static GLib.Settings client_settings;
    public static Tape.Settings tape_settings;
    public static Tape.Client tape_client;

    public Application () {
        Object (
            application_id: Config.APP_ID_RELEVANT,
            resource_base_path: @"/$(Config.APP_ID.replace (".", "/"))/",
            flags: ApplicationFlags.DEFAULT_FLAGS | ApplicationFlags.HANDLES_OPEN
        );
    }

    static construct {
    }

    construct {
        add_main_option_entries (OPTION_ENTRIES);
        set_option_context_parameter_string ("[YANDEX-MUSIC-URL]");

        add_action_entries (ACTION_ENTRIES, this);
        set_accels_for_action ("app.quit", { "<primary>q" });
    }

    protected override int handle_local_options (VariantDict options) {
        if (options.contains ("version")) {
            print ("%s %s\n", Config.APP_NAME, Config.VERSION);
            return 0;
        }

        return -1;
    }

    protected override void startup () {
        base.startup ();

        app_settings = new GLib.Settings (@"$(Config.APP_ID).application");
        client_settings = new GLib.Settings (@"$(Config.APP_ID).client");

        tape_settings = new Tape.Settings (Config.APP_NAME, Config.APP_ID_RELEVANT);
        client_settings.bind ("repeat-mode", tape_settings, "repeat-mode", DEFAULT);
        client_settings.bind ("shuffle-mode", tape_settings, "shuffle-mode", DEFAULT);
        client_settings.bind ("volume", tape_settings, "volume", DEFAULT);
        client_settings.bind ("mute", tape_settings, "mute", DEFAULT);
        client_settings.bind ("add-tracks-to-start", tape_settings, "add-tracks-to-start", DEFAULT);
        client_settings.bind ("music-quality", tape_settings, "music-quality", DEFAULT);
        client_settings.bind ("can-cache", tape_settings, "can-cache", DEFAULT);
        client_settings.bind ("repeat-mode", tape_settings, "repeat-mode", DEFAULT);
        client_settings.bind ("repeat-mode", tape_settings, "repeat-mode", DEFAULT);

        tape_client = new Tape.Client (tape_settings);
    }

    public override void activate () {
        base.activate ();

        if (active_window == null) {
            var win = new Window (this);

            win.present ();
        } else {
            active_window.present ();
        }
    }

    public void show_message (SimpleAction action, Variant? param) {
        var message = param.get_string ();

        if (active_window != null) {
            ((Cassette.Window) active_window).show_message (message);

            if (active_window.is_active) {
                return;
            }
        }

        var ntf = new Notification (_("Cassette"));
        ntf.set_body (message);
        send_notification (Config.APP_ID_RELEVANT, ntf);
    }
}
