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

internal sealed class Cassette.SheetSection : Adw.PreferencesGroup {

    public Gtk.Widget menu_action_parent { get; construct; }

    public SheetMenu main_menu { get; construct; }

    MenuSection _menu;
    public MenuSection menu {
        get {
            return _menu;
        }
        set {
            if (_menu != null) {
                _menu.items_changed.disconnect (on_items_changed);
            }

            _menu = value;

            if (_menu != null) {
                _menu.bind_property ("label", this, "title", SYNC_CREATE);
                _menu.items_changed.connect (on_items_changed);
            }

            on_items_changed ();
        }
    }

    Array<Gtk.Widget> childs = new Array<Gtk.Widget> ();

    public SheetSection (Gtk.Widget menu_action_parent, SheetMenu main_menu) {
        Object (
            menu_action_parent: menu_action_parent,
            main_menu: main_menu
        );
    }

    void on_items_changed () {
        foreach (var row in childs) {
            remove (row);
        }
        childs.remove_range (0, childs.length);

        if (menu != null) {
            for (uint i = 0; i < menu.get_n_items (); i++) {
                var item = (MenuItem) menu.get_item (i);

                var custom = item.get_custom ("sheet") as Gtk.Widget?;
                if (custom != null) {
                    add (custom);
                    childs.append_val (custom);
                    continue;
                }

                SheetMenuItem row;

                if (item.submenu != null) {
                    row = new SheetMenuItem.submenu (item);
                    var label = Uuid.string_random ();
                    main_menu.add (
                        new SheetPage (menu_action_parent, main_menu) {
                            menu = item.submenu,
                            title = item.label
                        },
                        label
                    );
                    row.activated.connect (() => {
                        main_menu.push (label);
                    });
                    add (row);
                } else {
                    row = new SheetMenuItem.action (menu_action_parent, item);
                    row.activated.connect (() => {
                        main_menu.close ();
                    });
                    add (row);
                }

                childs.append_val (row);
            }
        }
    }
}
