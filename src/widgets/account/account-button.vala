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

[GtkTemplate (ui = "/space/rirusha/Cassette/ui/account/account-button.ui")]
public sealed class Cassette.AccountButton : Adw.Bin {

    [GtkChild]
    unowned Adw.Avatar avatar;

    static construct {
        set_css_name ("accountbutton");
    }

    construct {
        set_avatar.begin ();
    }

    async void set_avatar () {
        try {
            var bytes = yield Cassette.Application.tape_client.yam_helper.me.get_avatar ();
            avatar.name = Cassette.Application.tape_client.yam_helper.me.public_name;

            if (bytes == null) {
                avatar.set_custom_image (null);
                return;
            }

            var avatar_paintable = Gdk.Texture.from_bytes (bytes);

            avatar.set_custom_image (avatar_paintable);
        } catch (Error e) {
            avatar.set_custom_image (null);
            warning ("Can't set avatar: %s", e.message);
        }
    }

    [GtkCallback]
    void on_button_clicked () {
        new AccountInfoDialog ().present (this);
    }
}
