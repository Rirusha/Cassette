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

[GtkTemplate (ui = "/space/rirusha/Cassette/Lib/ui/popover-menu.ui")]
public sealed class Cassette.PopoverMenu : Gtk.Popover {

    [GtkChild]
    unowned Gtk.Stack stack;

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

    PopoverMenu () {}

    public PopoverMenu.from_model (Menu? menu) {
        Object (
            menu: menu
        );
    }

    construct {
        closed.connect (to_first);
        add_css_class ("menu");
        add_css_class ("background");
    }

    void on_items_changed () {
        reset_content ();

        if (menu?.get_n_items () > 0) {
            var page = new PopoverPage (this) {
                menu = menu
            };
            stack.add_named (page, "root");
            stack.visible_child_name = "root";
        }
    }

    void to_first () {
        stack.visible_child_name = "root";
    }

    void reset_content () {
        while (stack.get_visible_child () != null) {
            stack.remove (stack.get_visible_child ());
        }
    }

    internal void add (PopoverPage page, string id) {
        stack.add_named (page, id);
    }

    internal void push (string id, bool backward = false) {
        if (stack.get_child_by_name (id) != null) {
            if (backward) {
                stack.transition_type = Gtk.StackTransitionType.SLIDE_RIGHT;
            } else {
                stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT;
            }
            stack.visible_child_name = id;
        }
    }
}
