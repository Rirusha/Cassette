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
    unowned Gtk.Popover popover_menu;
    [GtkChild]
    protected unowned Gtk.MenuButton real_button;

    public Gtk.Orientation dialog_orientation { get; construct; default = Gtk.Orientation.VERTICAL; }

    public Gtk.Orientation popover_orientation { get; construct; default = Gtk.Orientation.VERTICAL; }

    public bool should_close_on_click { get; construct; default = true; }

    MenuDialog? dialog = null;

    public int size {
        construct {
            width_request = value;
            height_request = value;
        }
    }

    construct {
        bind_property ("css-classes", real_button, "css-classes", BindingFlags.DEFAULT);

        popover_menu.closed.connect (() => {
            popover_menu.child = null;
        });

        real_button.notify["active"].connect (() => {
            if (real_button.active) {
                if (root_window_is_shrinked) {
                    set_bottom_sheet_menu ();

                } else {
                    set_popover_menu ();
                }
            }
        });
    }

    protected abstract Gtk.Widget[] get_popover_menu_items ();

    Gtk.Box build_popover_menu_box () {
        var box = new Gtk.Box (popover_orientation, 2) {
            css_classes = {"flat"}
        };

        foreach (var widget in get_popover_menu_items ()) {
            box.append (widget);

            var gs = new Gtk.GestureClick ();
            gs.end.connect (() => {
                real_button.popdown ();
            });
            widget.add_controller (gs);
        }

        return box;
    }

    void set_popover_menu () {
        popover_menu.child = build_popover_menu_box ();
    }

    protected abstract string get_menu_title ();

    protected abstract Gtk.Widget[] get_dialog_menu_items ();

    Gtk.Box build_dialog_menu_box () {
        var box = new Gtk.Box (dialog_orientation, 8) {
            css_classes = {"flat"}
        };

        foreach (var widget in get_dialog_menu_items ()) {
            box.append (widget);

            var gs = new Gtk.GestureClick ();
            gs.end.connect (() => {
                dialog.close ();
            });
            widget.add_controller (gs);
        }

        return box;
    }

    void set_bottom_sheet_menu () {
        popover_menu.popdown ();

        dialog = new MenuDialog ();
        dialog.set_menu_widget (get_menu_title (), build_dialog_menu_box ());

        dialog.closed.connect (() => {
            dialog = null;
        });

        dialog.present (this);
    }
}
