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
    [GtkChild]
    unowned Gtk.Stack image_stack;
    [GtkChild]
    unowned Adw.HeaderBar header_bar;
    [GtkChild]
    unowned Gtk.Revealer revealer;
    [GtkChild]
    unowned Gtk.Revealer logout_revealer;

    bool logout_in_process = false;

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
        var me = Cassette.Application.tape_client.yam_helper.me;

        var bytes = yield me.get_avatar ();
        public_name_label.label = me.public_name;
        login_label.label = me.login;

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

    public override void close_attempt () {
        if (!logout_in_process) {
            base.close_attempt ();
        }
    }

    [GtkCallback]
    void on_logout_clicked () {
        var dialog = new Adw.AlertDialog (_("Logout?"), _("It will erase all application data"));
        dialog.add_response ("cancel", _("_No"));
        dialog.add_response ("confirm", _("_Yes"));

        dialog.set_response_appearance ("confirm", Adw.ResponseAppearance.DESTRUCTIVE);
        dialog.set_default_response ("cancel");
        dialog.set_close_response ("cancel");

        dialog.response.connect (on_dialog_apply);
        dialog.present (this);
    }

    void on_dialog_apply (string response) {
        if (response == "confirm") {
            real_logout ();
        }
    }

    void real_logout () {
        activate_action ("app.log-out", null);
        header_bar.show_end_title_buttons = false;
        header_bar.show_start_title_buttons = false;
        revealer.reveal_child = false;
        logout_revealer.reveal_child = false;
        can_close = false;
        image_stack.visible_child_name = "load";
    }
}
