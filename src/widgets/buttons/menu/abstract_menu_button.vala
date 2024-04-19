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
    protected unowned Gtk.MenuButton real_button;

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

        real_button.set_create_popup_func ((menu_buttton) => {
            if (root_window_is_shrinked || settings.get_boolean ("use-only-dialogs")) {
                show_dialog_menu ();

            } else {
                menu_buttton.set_popover (build_popover ());
            }
        });
    }

    protected abstract Gtk.Widget[] get_popover_menu_items ();

    Gtk.Popover build_popover () {
        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 2) {
            css_classes = {"flat"}
        };

        foreach (var widget in get_popover_menu_items ()) {
            box.append (widget);

            if (widget is Gtk.Actionable && should_close_on_click) {
                var gs = new Gtk.GestureClick ();
                gs.end.connect (() => {
                    real_button.popdown ();
                });
                widget.add_controller (gs);
            }
        }

        return new Gtk.Popover () {
            child = box
        };
    }

    protected abstract Gtk.Widget[] get_dialog_menu_items ();

    Gtk.Box build_dialog_menu_box () {
        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 8) {
            css_classes = {"flat"}
        };

        foreach (var widget in get_dialog_menu_items ()) {
            box.append (widget);

            if (widget is Gtk.Actionable && should_close_on_click) {
                var gs = new Gtk.GestureClick ();
                gs.end.connect (() => {
                    dialog.close ();
                });
                widget.add_controller (gs);
            }
        }

        return box;
    }

    void show_dialog_menu () {
        dialog = new MenuDialog ();
        dialog.set_menu_widget (build_dialog_menu_box ());

        real_button.active = false;

        dialog.closed.connect (() => {
            dialog = null;
        });

        dialog.present (this);
    }
}
