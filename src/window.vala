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

[GtkTemplate (ui = "/space/rirusha/Cassette/ui/window.ui")]
public sealed class Cassette.Window : Adw.ApplicationWindow {

    const ActionEntry[] ACTION_ENTRIES = {
        //  { "close-sidebar", on_close_sidebar_action },
        //  { "show-disliked-tracks", on_show_disliked_tracks_action },
        { "preferences", on_preferences_action },
        { "about", on_about_action },
    };

    [GtkChild]
    unowned Adw.ToastOverlay toast_overlay;
    [GtkChild]
    unowned Gtk.Stack win_stack;
    [GtkChild]
    unowned Adw.StatusPage auth_status_page;
    [GtkChild]
    unowned Adw.ButtonRow webkit_login;
    [GtkChild]
    unowned Adw.PasswordEntryRow token_login;

    public Window (Cassette.Application app) {
        Object (application: app);
    }

    construct {
        add_action_entries (ACTION_ENTRIES, this);

        Cassette.Application.app_settings.bind ("window-width", this, "default-width", SettingsBindFlags.DEFAULT);
        Cassette.Application.app_settings.bind ("window-height", this, "default-height", SettingsBindFlags.DEFAULT);
        Cassette.Application.app_settings.bind ("window-maximized", this, "maximized", SettingsBindFlags.DEFAULT);

        auth_status_page.icon_name = Config.APP_ID_RELEVANT + "-symbolic";

#if WITH_WEBKIT
        auth_status_page.description = _("Choose a way to log in to the app. You can log in via your Yandex account or with your token."); // vala-lint=line-length
#else
        webkit_login.visible = false;
        auth_status_page.description = "%s\n<a href=\"https://yandex-music.readthedocs.io/en/main/token.html\">%s</a>".printf ( // vala-lint=line-length
            _("You need your Yandex music token to login."),
            _("The methods of obtaining it are described here.")
        );
#endif

        try_auth.begin (null);

        if (Config.IS_DEVEL) {
            add_css_class ("devel");
        }
    }

    void to_main () {
        win_stack.visible_child_name = "main";
    }

    void to_auth () {
        win_stack.visible_child_name = "auth";
    }

    void to_cant_use (CantUseError e) {
        switch (e.domain) {
            case CantUseError.NO_PLUS:
                win_stack.visible_child_name = "no-plus";
                break;
        }
    }

    public void show_message (string message) {
        toast_overlay.add_toast (new Adw.Toast (message));
    }

    [GtkCallback]
    void on_yandex_apply () {
#if WITH_WEBKIT
        var dialog = new WebkitAuthDialog (Cassette.Application.tape_client.cachier.storager.cookies_file);
        dialog.present (this);
        dialog.success.connect (() => {
            try_auth.begin (null);
        });
#endif
    }

    [GtkCallback]
    void on_token_apply () {
        win_stack.visible_child_name = "loading";
        try_auth.begin (token_login.text);
    }

    async void try_auth (string? token) {
        try {
            if (yield Cassette.Application.tape_client.init (token)) {
                to_main ();
            } else {
                if (token != null) {
                    show_message (_("Failed to login. Probably wrong token"));
                }
                to_auth ();
            }
        } catch (ApiBase.BadStatusCodeError e) {
            show_message (_("Bad status code: %i").printf (e.code));
            to_auth ();
        } catch (CantUseError e) {
            to_cant_use (e);
        } catch (ApiBase.SoupError e) {
            show_message (_("Connection problems"));
            to_auth ();
        }
    }

    void on_preferences_action () {

    }

    void on_about_action () {
        build_about ().present (this);
    }
}
