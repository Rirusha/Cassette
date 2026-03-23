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
            return tracker?.action_name;
        }
    }

    public new Variant? action_target {
        owned get {
            return tracker?.action_target;
        }
    }

    public string? hidden_when { get; construct set; }

    public new string? icon_name { get; construct set; }

    public bool is_submenu { get; construct; }

    public ActionActor tracker { get; construct; }

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
        Gtk.Widget menu_real_parent,
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
            is_submenu: false,
            tracker: new ActionActor ()
        );
        tracker.set_parent (menu_real_parent);
        tracker.action_name = action;
        tracker.action_target = target;

        tracker.bind_property ("sensitive", this, "sensitive", BindingFlags.SYNC_CREATE);
    }

    ~SheetMenuItem () {
        tracker?.unparent ();
    }

    construct {
        if (icon_name != null) {
            add_prefix (new Gtk.Image.from_icon_name (icon_name));
        }

        if (hidden_when != null) {
            warning ("hidden_when is not supported");
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

        activated.connect_after (on_activated);
    }

    void on_activated () {
        tracker?.activate_action_variant (action_name, action_target);
    }
}
