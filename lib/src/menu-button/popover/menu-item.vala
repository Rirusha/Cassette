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

[GtkTemplate (ui = "/space/rirusha/Cassette/Lib/ui/popover-menu-item.ui")]
internal sealed class Cassette.PopoverMenuItem : Gtk.ListBoxRow {

    [GtkChild]
    unowned IndicatorBin indicator_bin;
    [GtkChild]
    unowned Gtk.Image icon_image;
    [GtkChild]
    unowned Gtk.Label label;
    [GtkChild]
    unowned Gtk.Label shortcut_label;
    [GtkChild]
    unowned Gtk.Image submenu_icon;

    public MenuItem item { get; construct; }

    public new string? action_name {
        get {
            return base.action_name;
        }
        set {
            base.action_name = value ?? "";

            if (value != null) {
                var accels = ((Gtk.Application) Application.get_default ()).get_accels_for_action (value);

                if (accels.length > 0) {
                    uint accelerator_key;
                    Gdk.ModifierType accelerator_mods;

                    if (Gtk.accelerator_parse (accels[0], out accelerator_key, out accelerator_mods)) {
                        shortcut_label.label = Gtk.accelerator_get_label (accelerator_key, accelerator_mods);
                        shortcut_label.visible = true;
                    }
                }
            } else {
                shortcut_label.visible = false;
            }
        }
    }

    Menu last_menu;

    public signal void activated ();

    PopoverMenuItem () {}

    internal PopoverMenuItem.back (
        MenuItem item
    ) {
        Object (
            item: item
        );

        icon_image.add_css_class ("dimmed");
        label.xalign = 0.5f;
        label.halign = CENTER;
    }

    public PopoverMenuItem.submenu (
        MenuItem item
    ) {
        Object (
            item: item
        );

        submenu_icon.visible = true;
        item.notify["submenu"].connect (submenu_updated);
        submenu_updated ();
    }

    public PopoverMenuItem.action (
        MenuItem item
    ) {
        Object (
            item: item
        );

        item.bind_property ("action-target", this, "action-target", SYNC_CREATE);
        item.bind_property ("action-name", this, "action-name", SYNC_CREATE);
    }

    construct {
        item.bind_property ("label", label, "label", SYNC_CREATE);

        item.notify["icon-name"].connect (update_indicator);
        item.notify["needs-attention"].connect (update_indicator);
        item.notify["badge-number"].connect (update_indicator);
        update_indicator ();

        item.bind_property ("visible", this, "visible", SYNC_CREATE);

        var e = new Gtk.GestureClick ();
        e.end.connect (() => {
            Idle.add_once (() => {
                activated ();
            });
        });
        add_controller (e);
    }

    void update_indicator () {
        icon_image.icon_name = item.icon_name;
        indicator_bin.needs_attention = item.needs_attention;
        indicator_bin.badge_number = item.badge_number;

        indicator_bin.visible = true;
        if (item.icon_name == null) {
            if (item.needs_attention || indicator_bin.badge_number > 0) {
                icon_image.icon_name = "tablet-symbolic";
            } else {
                icon_image.icon_name = null;
                indicator_bin.visible = false;
            }
        }
    }

    void submenu_updated () {
        if (last_menu != null) {
            last_menu.items_changed.disconnect (menu_items_changed);
        }

        last_menu = item.submenu;

        if (last_menu != null) {
            sensitive = true;
            last_menu.items_changed.connect (menu_items_changed);
            menu_items_changed (last_menu, 0, 0, 0);
        } else {
            sensitive = false;
        }
    }

    void menu_items_changed (ListModel model, uint pos, uint added, uint removed) {
        sensitive = model.get_n_items () != 0;
    }
}
