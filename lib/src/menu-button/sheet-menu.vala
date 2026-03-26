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

    HashTable<string, SheetSubmenu> submenus = new HashTable<string, SheetSubmenu> (str_hash, str_equal);
    HashTable<string, Adw.Bin> customs = new HashTable<string, Adw.Bin> (str_hash, str_equal);

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

    MenuModel? _menu_model;
    public MenuModel? menu_model {
        get {
            return _menu_model;
        }
        set {
            if (_menu_model != null) {
                _menu_model.items_changed.disconnect (build_model);
            }

            _menu_model = value;
            _menu_model.items_changed.connect (build_model);
            build_model ();
        }
    }

    Adw.NavigationView nav_view = new Adw.NavigationView () {
        hhomogeneous = true
    };

    SheetMenu () {}

    public SheetMenu.from_model (Gtk.Widget action_parent, MenuModel? menu_model, string? title = null) {
        Object (
            action_parent: action_parent,
            menu_model: menu_model,
            presentation_mode: Adw.DialogPresentationMode.BOTTOM_SHEET,
            title: title,
            width_request: 360,
            follows_content_size: true
        );
    }

    construct {
        reset_content ();

        closed.connect (to_first);
    }

    public bool add_child (Gtk.Widget child, string id) {
        customs[id].child = child;
        customs[id].visible = true;
        return true;
    }

    public bool remove_child (Gtk.Widget child) {
        foreach (var val in customs.get_values ()) {
            if (val.child == child) {
                val.child = null;
                val.visible = false;
                return true;
            }
        }
        return false;
    }

    void build_model () {
        if (menu_model == null) {
            reset_content ();
            return;
        }

        nav_view.push (new SheetSubmenu (action_parent, this, menu_model, title));
    }

    void to_first () {
        while (nav_view.pop ()) {}
    }

    void reset_content () {
        nav_view = new Adw.NavigationView ();
        child = nav_view;
    }

    internal void add (SheetSubmenu submenu, string? id) {
        if (id == null) {
            return;
        }

        submenus[id] = submenu;
    }

    internal void push (string? id) {
        if (id == null) {
            return;
        }

        if (submenus.contains (id)) {
            nav_view.push (submenus[id]);
        }
    }

    internal void add_custom (string id, Adw.Bin widget) {
        return_if_fail (!customs.contains (id));
        customs[id] = widget;
    }
}
