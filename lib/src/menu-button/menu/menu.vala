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

public class Cassette.Menu : Buildable, ListModel {

    internal bool needs_attention { get; set; }

    internal uint badge_number { get; set; }

    internal ListStore sections { get; set; default = new ListStore (typeof (MenuSection)); }

    construct {
        sections.items_changed.connect (on_store_items_changed);
    }

    void on_store_items_changed (uint position, uint removed, uint added) {
        items_changed (position, removed, added);
        recalc ();
    }

    void recalc () {
        bool na = false;
        uint bn = 0;

        for (uint i = 0; i < sections.get_n_items (); i++) {
            var section = (MenuSection) sections.get_item (i);
            if (section.needs_attention) {
                na = true;
            }
            bn += section.badge_number;
        }

        needs_attention = na;
        badge_number = bn;
    }

    public override void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        if (child is MenuSection) {
            append_section ((MenuSection) child);
        } else if (child is MenuItem) {
            var tsec = new MenuSection ();
            tsec.append_item ((MenuItem) child);
            append_section (tsec);
        } else if (child is MenuSubmenu) {
            var item = new MenuItem ();
            var submenu = (MenuSubmenu) child;

            submenu.bind_property ("label", item, "label", SYNC_CREATE);
            submenu.bind_property ("icon-name", item, "icon-name", SYNC_CREATE);

            item.submenu = submenu;

            var tsec = new MenuSection ();
            tsec.append_item (item);
            append_section (tsec);
        }
    }

    public void append_section (MenuSection section) {
        sections.append (section);

        section.notify["needs-attention"].connect (recalc);
        section.notify["badge-number"].connect (recalc);
    }

    public void remove_section (MenuSection section) {
        uint pos;
        if (sections.find (section, out pos)) {
            sections.remove (pos);

            section.notify["needs-attention"].disconnect (recalc);
            section.notify["badge-number"].disconnect (recalc);
        }
    }

    public GLib.Object? get_item (uint position) {
        return sections.get_item (position);
    }

    public GLib.Type get_item_type () {
        return typeof (MenuSection);
    }

    public uint get_n_items () {
        return sections.get_n_items ();
    }
}
