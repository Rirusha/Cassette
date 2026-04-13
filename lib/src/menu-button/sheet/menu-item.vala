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
        set {
            if (tracker == null) {
                return;
            }

            tracker.action_name = value ?? "";

            if (value != null) {
                var accels = ((Gtk.Application) Application.get_default ()).get_accels_for_action (value);

                if (accels.length > 0) {
                    shortcut_label.set_accelerator (accels[0]);
                    shortcut_label.visible = true;
                }
            } else {
                shortcut_label.visible = false;
            }
        }
    }

    public new Variant? action_target {
        owned get {
            return tracker?.action_target;
        }
        set {
            if (tracker == null) {
                return;
            }

            tracker.action_target = value;
        }
    }

    public ActionActor tracker { get; construct; }

    public MenuItem item { get; construct; }

    Gtk.Image? icon = null;
    Menu last_menu;

    Badge badge = new Badge ();
    Adw.ShortcutLabel shortcut_label = new Adw.ShortcutLabel ("") {
        visible = false,
        halign = CENTER,
        valign = CENTER
    };
    Gtk.Image end_icon = new Gtk.Image.from_icon_name ("go-next-symbolic") {
        visible = false
    };
    Gtk.Box suffix_box = new Gtk.Box (HORIZONTAL, 6);

    SheetMenuItem () {}

    public SheetMenuItem.submenu (
        MenuItem item
    ) {
        Object (
            item: item,
            activatable: true
        );

        item.notify["submenu"].connect (submenu_updated);
        submenu_updated ();
        end_icon.visible = true;
    }

    public SheetMenuItem.action (
        Gtk.Widget menu_real_parent,
        MenuItem item
    ) {
        Object (
            item: item,
            activatable: true,
            tracker: new ActionActor ()
        );

        tracker.set_parent (menu_real_parent);
        item.bind_property ("action-name", this, "action-name", SYNC_CREATE);
        item.bind_property ("action-target", this, "action-target", SYNC_CREATE);

        tracker.bind_property ("sensitive", this, "sensitive", BindingFlags.SYNC_CREATE);
    }

    ~SheetMenuItem () {
        tracker?.unparent ();
    }

    construct {
        suffix_box.append (badge);
        suffix_box.append (shortcut_label);
        suffix_box.append (end_icon);
        update_box_visibility ();

        badge.notify["visible"].connect (update_box_visibility);
        shortcut_label.notify["visible"].connect (update_box_visibility);
        end_icon.notify["visible"].connect (update_box_visibility);

        item.bind_property ("label", this, "title", SYNC_CREATE);
        item.notify["icon-name"].connect (update_icon);
        update_icon ();

        item.bind_property ("needs-attention", badge, "needs-attention");
        item.bind_property ("badge-number", badge, "badge-number");

        activated.connect_after (on_activated);
    }

    void update_box_visibility () {
        if (badge.visible || shortcut_label.visible || end_icon.visible) {
            if (suffix_box.parent == null) {
                add_suffix (suffix_box);
            }
        } else {
            if (suffix_box.parent != null) {
                remove (suffix_box);
            }
        }
    }

    void on_activated () {
        tracker?.activate_action_variant (action_name, action_target);
    }

    void update_icon () {
        if (item.icon_name != null) {
            if (icon == null) {
                icon = new Gtk.Image ();
                add_prefix (icon);
            }
            icon.icon_name = item.icon_name;
        } else {
            if (icon != null) {
                icon = null;
                remove (icon);
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
