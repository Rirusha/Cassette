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

public class Cassette.MenuSection : Buildable, ListModel {

    internal bool needs_attention { get; set; }

    internal uint badge_number { get; set; }

    internal ListStore items { get; set; default = new ListStore (typeof (MenuItem)); }

    bool _visible_set = false;
    bool _visible = true;
    public bool visible {
        get {
            return _visible;
        }
        set {
            _visible_set = true;
            _visible = value;
        }
    }

    public string label { get; set; }

    construct {
        items.items_changed.connect (on_store_items_changed);
    }

    void on_store_items_changed (uint position, uint removed, uint added) {
        items_changed (position, removed, added);
        recalc ();
    }

    void recalc () {
        bool new_visible = false;
        bool na = false;
        uint bn = 0;

        for (uint i = 0; i < items.get_n_items (); i++) {
            var item = (MenuItem) items.get_item (i);
            if (item.needs_attention) {
                na = true;
            }
            if (item.visible && !_visible_set) {
                new_visible = true;
            }
            bn += item.badge_number;
        }

        needs_attention = na;
        badge_number = bn;

        if (new_visible != _visible) {
            _visible = new_visible;
            notify_property ("visible");
        }
    }

    public override void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        if (child is MenuItem) {
            append_item ((MenuItem) child);
        } else if (child is MenuSubmenu) {
            var item = new MenuItem ();
            var submenu = (MenuSubmenu) child;

            submenu.bind_property ("label", item, "label", SYNC_CREATE);
            submenu.bind_property ("icon-name", item, "icon-name", SYNC_CREATE);

            item.submenu = submenu;

            append_item (item);
        } else {
            critical ("Unknown type %s for adding to %s", child.get_type ().name (), get_type ().name ());
        }
    }

    public void append_item (MenuItem item) {
        items.append (item);

        item.notify["needs-attention"].connect (recalc);
        item.notify["badge-number"].connect (recalc);
    }

    public void remove_item (MenuItem item) {
        uint pos;
        if (items.find (item, out pos)) {
            items.remove (pos);

            item.notify["needs-attention"].disconnect (recalc);
            item.notify["badge-number"].disconnect (recalc);
        }
    }

    public GLib.Object? get_item (uint position) {
        return items.get_item (position);
    }

    public GLib.Type get_item_type () {
        return typeof (MenuItem);
    }

    public uint get_n_items () {
        return items.get_n_items ();
    }
}
