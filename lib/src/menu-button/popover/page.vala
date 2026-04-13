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

internal sealed class Cassette.PopoverPage : Gtk.Box {

    Menu _menu;
    public Menu menu {
        get {
            return _menu;
        }
        set {
            if (_menu != null) {
                _menu.items_changed.disconnect (on_items_changed);
                _menu.notify["has-visible-items"].disconnect (menu_visible_items_changes);
            }

            _menu = value;

            if (_menu != null) {
                _menu.items_changed.connect (on_items_changed);
                _menu.notify["has-visible-items"].connect (menu_visible_items_changes);
            }

            on_items_changed ();
            menu_visible_items_changes ();
        }
    }

    public PopoverMenu main_menu { get; construct; }

    public string? previous { get; construct; }
    public string? current { get; construct; }
    public string? previous_label { get; construct; }

    public PopoverPage (
        PopoverMenu main_menu,
        string? previous = null,
        string? current = null,
        string? previous_label = null
    ) {
        Object (
            main_menu: main_menu,
            orientation: Gtk.Orientation.VERTICAL,
            previous: previous,
            current: current,
            previous_label: previous_label
        );
    }

    void menu_visible_items_changes () {
        if (!menu.has_visible_items && previous != null) {
            main_menu.push (previous, true);
        }
    }

    void on_items_changed () {
        while (get_last_child () != null) {
            remove (get_last_child ());
        }

        if (menu != null) {
            for (uint i = 0; i < menu.get_n_items (); i++) {
                var section = (MenuSection) menu.get_item (i);

                if (i == 0) {
                    if (previous != null) {
                        append (new PopoverSection.back_header (main_menu, previous_label, previous));
                    }
                }

                append (new PopoverSection (main_menu, current, i == 0) {
                    menu = section
                });
            }
        }
    }
}
