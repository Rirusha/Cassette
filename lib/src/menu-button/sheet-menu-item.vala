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

internal sealed class Cassette.SheetMenuItem : Adw.ActionRow {

    public new string? action_name {
        get {
            return base.action_name;
        }
        construct set {
            base.action_name = value;
        }
    }

    public string? hidden_when { get; construct set; }

    public new string? icon_name { get; construct set; }

    public bool is_submenu { get; construct; }

    public signal void clicked ();

    SheetMenuItem () {}

    public SheetMenuItem.submenu (
        string? label,
        string? icon
    ) {
        Object (
            activatable: true,
            title: label ?? "",
            icon_name: icon,
            is_submenu: true
        );
        add_suffix (new Gtk.Image.from_icon_name ("go-next-symbolic"));
    }

    public SheetMenuItem.action (
        string? action,
        string? label,
        string? icon,
        Variant? target,
        bool use_markup,
        string? hidden_when
    ) {
        Object (
            activatable: true,
            title: label ?? "",
            hidden_when: hidden_when,
            icon_name: icon,
            use_markup: use_markup,
            action_name: action,
            action_target: target,
            is_submenu: false
        );
    }

    construct {
        if (icon_name != null) {
            add_prefix (new Gtk.Image.from_icon_name (icon_name));
        }

        if (hidden_when != null) {
            switch (hidden_when) {
                case "macos-menubar":
                    visible = false;
                    return;
                case "action-missing":
                    if (action_name != null) {
                        visible = Application.get_default ().has_action (action_name);
                    } else {
                        visible = false;
                    }
                    break;
                case "action-disabled":
                    if (action_name != null) {
                        visible = Application.get_default ().get_action_enabled (action_name);
                    } else {
                        visible = false;
                    }
                    break;
                default:
                    break;
            }
        }

        if (action_name != null) {
            var accels = ((Gtk.Application) Application.get_default ()).get_accels_for_action (action_name);

            if (accels.length > 0) {
                add_suffix (new Adw.ShortcutLabel (accels[0]) {
                    halign = CENTER,
                    valign = CENTER
                });
            }
        }

        var e = new Gtk.GestureClick ();
        e.end.connect (() => {
            activated ();
        });
        add_controller (e);
    }
}
