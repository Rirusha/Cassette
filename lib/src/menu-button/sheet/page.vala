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

[GtkTemplate (ui = "/space/rirusha/Cassette/Lib/ui/sheet-page.ui")]
internal sealed class Cassette.SheetPage : Adw.NavigationPage {

    [GtkChild]
    unowned Adw.PreferencesPage pref_page;

    public Gtk.Widget menu_action_parent { get; construct; }

    Array<SheetSection> section_widgets = new Array<SheetSection> ();

    Menu _menu;
    public Menu menu {
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
            }

            on_items_changed ();
        }
    }

    public SheetMenu main_menu { get; construct; }

    public SheetPage (
        Gtk.Widget menu_action_parent,
        SheetMenu main_menu
    ) {
        Object (
            menu_action_parent: menu_action_parent,
            main_menu: main_menu
        );
    }

    static construct {
        //  For indicators
        set_css_name ("view-switcher-sidebar");
    }

    void on_items_changed () {
        foreach (var sw in section_widgets) {
            pref_page.remove (sw);
        }
        section_widgets.remove_range (0, section_widgets.length);

        if (menu != null) {
            for (uint i = 0; i < menu.get_n_items (); i++) {
                var sw = new SheetSection (menu_action_parent, main_menu) {
                    menu = (MenuSection) menu.get_item (i)
                };
                pref_page.add (sw);
                section_widgets.append_val (sw);
            }
        }
    }
}
