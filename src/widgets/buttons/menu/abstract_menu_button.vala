/* Copyright 2023-2024 Rirusha
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */


[GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/custom_menu_button.ui")]
public abstract class Cassette.CustomMenuButton : ShrinkableBin {

    [GtkChild]
    unowned Gtk.Popover menu_popover;
    [GtkChild]
    protected Gtk.MenuButton real_button;

    Adw.Dialog? dialog;

    Gtk.ListBox? menu_box;

    public new string[] css_classes {
        owned get {
            return real_button.css_classes;
        }
        set {
            real_button.css_classes = value;
        }
    }

    public int size {
        construct {
            width_request = value;
            height_request = value;
        }
    }

    construct {
        menu_popover.notify["child"].connect (() => {
            menu_popover.visible = child != null;
        });

        real_button.notify["active"].connect (() => {
            if (real_button.active) {
                menu_box = build_menu_box ();
                notify["root-window-is-shrinked"].connect (adapt_menu);
                adapt_menu ();

            } else {
                notify["root-window-is-shrinked"].disconnect (adapt_menu);
                menu_box = null;
            }
        });
    }

    public new void add_css_class (string class_name) {
        real_button.add_css_class (class_name);
    }

    protected abstract Gtk.Widget[] get_menu_items ();

    Gtk.ListBox build_menu_box () {
        var t_menu_box = new Gtk.ListBox () { css_classes = {"menu"} };

        foreach (var widget in get_menu_items ()) {
            t_menu_box.append (widget);
        }

        return t_menu_box;
    }

    void adapt_menu () {
        if (root_window_is_shrinked) {
            set_bottom_sheet_menu ();

        } else {
            set_popover_menu.begin ();
        }
    }

    async void set_popover_menu () {
        if (dialog != null) {
            dialog.closed.connect (() => {
                Idle.add (set_popover_menu.callback);
            });
            dialog.close ();

            yield;
        }

        menu_popover.child = menu_box;
    }

    void set_bottom_sheet_menu () {
        menu_popover.child = null;

        dialog = new Adw.Dialog () {
            presentation_mode = Adw.DialogPresentationMode.BOTTOM_SHEET,
            child = menu_box
        };

        dialog.closed.connect (() => {
            dialog = null;
        });

        dialog.present (this);
    }
}
