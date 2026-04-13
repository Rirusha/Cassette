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

public sealed class Cassette.SheetMenu : Adw.Dialog {

    HashTable<string, SheetPage> submenus = new HashTable<string, SheetPage> (str_hash, str_equal);

    /**
     * It needs for actions query because of `Adw.Dialog` and `MenuButton` has different ancestors
     */
    public Gtk.Widget action_parent { get; construct; }

    public new Adw.DialogPresentationMode presentation_mode {
        get {
            return BOTTOM_SHEET;
        }
        set {
            return;
        }
    }

    Menu? _menu;
    public Menu? menu {
        get {
            return _menu;
        }
        set {
            if (_menu != null) {
                _menu.items_changed.disconnect (on_items_changed);
            }

            _menu = value;

            if (_menu != null) {
                _menu.items_changed.connect (on_items_changed);
                on_items_changed ();
            }
        }
    }

    Adw.NavigationView nav_view;

    SheetMenu () {}

    public SheetMenu.from_model (Gtk.Widget action_parent, Menu? menu) {
        Object (
            action_parent: action_parent,
            menu: menu,
            presentation_mode: Adw.DialogPresentationMode.BOTTOM_SHEET,
            width_request: 360,
            follows_content_size: true
        );
    }

    construct {
        closed.connect (to_first);
    }

    void on_items_changed () {
        reset_content ();
        submenus.remove_all ();
 
        if (menu?.get_n_items () > 0) {
            var page = new SheetPage (action_parent, this) {
                menu = menu
            };
            bind_property ("title", page, "title", SYNC_CREATE);
            nav_view.push (page);
        }
    }

    void to_first () {
        Timeout.add_once (300, () => {
            while (nav_view.pop ()) {}
        });
    }

    void reset_content () {
        nav_view = new Adw.NavigationView () {
            hhomogeneous = true,
            vhomogeneous = true,
        };
        child = nav_view;
    }

    internal void add (SheetPage page, string id) {
        submenus[id] = page;
    }

    internal void push (string id) {
        if (submenus.contains (id)) {
            nav_view.push (submenus[id]);
        }
    }

    internal void pop () {
        nav_view.pop ();
    }
}
