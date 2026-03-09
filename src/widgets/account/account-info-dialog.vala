/*
 * Copyright (C) 2026 Vladimir Romanov <rirusha@altlinux.org>
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

[GtkTemplate (ui = "/space/rirusha/Cassette/ui/account/account-info-dialog.ui")]
public sealed class Cassette.AccountInfoDialog : Adw.Dialog {

    [GtkChild]
    unowned Gtk.Image avatar_image;
    [GtkChild]
    unowned Gtk.Label public_name_label;
    [GtkChild]
    unowned Gtk.Label login_label;

    static construct {
        set_css_name ("accountinfodialog");
    }

    construct {
        set_info.begin ();

        if (Config.IS_DEVEL) {
            add_css_class ("devel");
        }
    }

    async void set_info () {
        var bytes = yield Cassette.Application.tape_client.yam_helper.me.get_avatar ();
        public_name_label.label = Cassette.Application.tape_client.yam_helper.me.public_name;
        login_label.label = Cassette.Application.tape_client.yam_helper.me.login;

        if (bytes == null) {
            avatar_image.paintable = null;
            return;
        }

        try {
            avatar_image.paintable = Gdk.Texture.from_bytes (bytes);
        } catch (Error e) {
            avatar_image.paintable = null;
            warning ("Can't set account info: %s", e.message);
        }
    }
}
