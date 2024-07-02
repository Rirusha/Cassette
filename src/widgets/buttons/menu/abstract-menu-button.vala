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
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */

[GtkTemplate (ui = "/io/github/Rirusha/Cassette/ui/custom-menu-button.ui")]
public abstract class Cassette.CustomMenuButton : ShrinkableBin {

    public struct MenuItem {
        public string label;
        public string action_name;
        public int section_num;
    }

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

    public bool primary {
        get {
            return real_button.primary;
        }
        set {
            real_button.primary = value;
        }
    }

    public string icon_name {
        get {
            return real_button.icon_name;
        }
        set {
            real_button.icon_name = value;
        }
    }

    public Gtk.Widget button_child {
        get {
            return real_button.child;
        }
        set {
            real_button.child = value;
        }
    }

    protected SimpleActionGroup actions { get; private set; }

    construct {
        bind_property ("css-classes", real_button, "css-classes", BindingFlags.DEFAULT);

        actions = new SimpleActionGroup ();
        insert_action_group ("actions", actions);

        real_button.set_create_popup_func ((menu_button) => {
            if (root_window_is_shrinked || settings.get_boolean ("use-only-dialogs")) {
                menu_button.active = false;
                show_dialog_menu ();

            } else {
                menu_button.set_popover (build_popover ());
            }
        });
    }

    Gtk.Separator build_separator () {
        return new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
            margin_top = 6,
            margin_bottom = 6
        };
    }

    protected virtual Gtk.Widget[] get_popover_menu_widgets () {
        return {};
    }

    protected virtual MenuItem[] get_popover_menu_items () {
        return {};
    }

    Gtk.Popover build_popover () {
        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
            css_classes = { "flat" }
        };

        var menu_widgets = get_popover_menu_widgets ();
        var menu_items = get_popover_menu_items ();

        for (int i = 0; i < menu_widgets.length; i++) {
            box.append (menu_widgets[i]);

            if (i < menu_widgets.length - 1 || (i == menu_widgets.length - 1 && menu_items.length != 0)) {
                box.append (build_separator ());
            }
        }

        int current_section = -1;

        foreach (var item in menu_items) {
            if (current_section > -1 && item.section_num > -1 && current_section != item.section_num) {
                box.append (build_separator ());
            }

            current_section = item.section_num;

            var button = new Gtk.Button () {
                child = new Gtk.Label (item.label) {
                    halign = Gtk.Align.START,
                    ellipsize = Pango.EllipsizeMode.END
                },
                css_classes = { "flat", "menu-button" },
                action_name = item.action_name
            };

            button.clicked.connect (() => {
                real_button.popdown ();
            });

            box.append (button);
        }

        return new Gtk.Popover () {
            child = box
        };
    }

    protected virtual Gtk.Widget[] get_dialog_menu_widgets () {
        return {};
    }

    protected virtual MenuItem[] get_dialog_menu_items () {
        return {};
    }

    Gtk.Box build_dialog_menu_box () {
        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12) {
            css_classes = { "flat" }
        };

        var menu_widgets = get_dialog_menu_widgets ();
        var menu_items = get_dialog_menu_items ();

        foreach (var widget in menu_widgets) {
            box.append (widget);
        }

        var list_box = new Gtk.ListBox () {
            css_classes = { "boxed-list" },
            selection_mode = Gtk.SelectionMode.NONE,
            activate_on_single_click = true
        };

        if (menu_items.length != 0) {
            box.append (list_box);
        }

        foreach (var item in menu_items) {
            var row = new Gtk.ListBoxRow () {
                child = new Gtk.Label (item.label) {
                    halign = Gtk.Align.START,
                    ellipsize = Pango.EllipsizeMode.END,
                    margin_top = 12,
                    margin_bottom = 12,
                    margin_start = 12,
                    margin_end = 12,
                },
                action_name = item.action_name
            };

            // ListBox.row_activated doesn't work, idk why
            var gs = new Gtk.GestureClick ();
            gs.released.connect ((n, x, y) => {
                if (row.contains (x, y)) {
                    dialog.close ();
                }
            });
            row.add_controller (gs);

            list_box.append (row);
        }

        return box;
    }

    void show_dialog_menu () {
        real_button.set_popover (null);

        var title_widget = get_title_widget ();

        dialog = new MenuDialog () {
            menu_widget = build_dialog_menu_box (),
            title_widget = title_widget != null ? title_widget : new Gtk.Label (get_title_label ()) {
                css_classes = { "title-2" }
            },
            width_request = 360,
            content_width = 360,
            content_height = 294
        };

        dialog.insert_action_group ("track", actions);

        real_button.active = false;

        dialog.closed.connect (() => {
            dialog = null;
        });

        dialog.present (this);
    }

    protected virtual Gtk.Widget? get_title_widget () {
        return null;
    }

    protected virtual string get_title_label () {
        return "ASSERT_SEEN";
    }
}
