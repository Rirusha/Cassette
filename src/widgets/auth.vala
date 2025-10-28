/*
 * Copyright (C) 2025 Vladimir Romanov <rirusha@altlinux.org>
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

[GtkTemplate (ui = "/space/rirusha/Cassette/ui/auth.ui")]
public sealed class Cassette.Auth : Loadable {

    [GtkChild]
    unowned Gtk.Stack win_stack;
    [GtkChild]
    unowned Adw.StatusPage auth_status_page;
#if !WITH_WEBKIT
    [GtkChild]
    unowned Adw.ButtonRow webkit_login;
#endif
    [GtkChild]
    unowned Adw.PasswordEntryRow token_login;

    construct {
        auth_status_page.icon_name = Config.APP_ID_RELEVANT + "-symbolic";

#if WITH_WEBKIT
        auth_status_page.description = _("Choose a way to log in to the app. You can log in via your Yandex account or with your token."); // vala-lint=line-length
#else
        webkit_login.visible = false;
        auth_status_page.description = _("You need your Yandex music token to login.");
#endif

        try_auth.begin (null);

        if (Config.IS_DEVEL) {
            add_css_class ("devel");
        }
    }

    void clear_main () {
        if (win_stack.get_child_by_name ("main") != null) {
            win_stack.remove (win_stack.get_child_by_name ("main"));
        }
    }

    public void to_main () {
        clear_main ();
        win_stack.add_named (new MainContent (), "main");
        win_stack.visible_child_name = "main";
        is_loading = false;
    }

    public void to_auth () {
        win_stack.visible_child_name = "auth";
        clear_main ();
        is_loading = false;
    }

    void to_cant_use (CantUseError e) {
        switch (e.code) {
            case CantUseError.NO_PLUS:
                win_stack.visible_child_name = "no-plus";
                break;
        }
        clear_main ();
        is_loading = false;
    }

    [GtkCallback]
    void on_yandex_apply () {
#if WITH_WEBKIT
        var dialog = new WebkitAuthDialog (Cassette.Application.tape_client.cachier.storager.cookies_file);
        dialog.present (this);
        dialog.success.connect (() => {
            try_auth.begin (null);
        });
        is_loading = true;
#endif
    }

    [GtkCallback]
    void on_token_apply () {
        is_loading = true;
        try_auth.begin (token_login.text);
    }

    async void try_auth (string? token) {
        try {
            if (yield Cassette.Application.tape_client.init (token)) {
                to_main ();
            } else {
                if (token != null) {
                    activate_action_variant ("app.show-message", _("Failed to login. Probably wrong token"));
                }
                to_auth ();
            }
        } catch (ApiBase.BadStatusCodeError e) {
            activate_action_variant ("app.show-message", _("Bad status code: %i").printf (e.code));
            to_auth ();
        } catch (CantUseError e) {
            to_cant_use (e);
        } catch (ApiBase.SoupError e) {
            activate_action_variant ("app.show-message", _("Connection problems"));
            to_auth ();
        }
    }

    [GtkCallback]
    void on_open_link () {
        new Gtk.UriLauncher ("https://yandex-music.readthedocs.io/en/main/token.html").launch.begin (null, null);
    }

    [GtkCallback]
    void on_to_auth_clicked () {
        Tape.Storager.remove_file.begin (Application.tape_client.cachier.storager.cookies_file, to_auth);
    }
}
