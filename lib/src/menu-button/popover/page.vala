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
            }

            _menu = value;

            if (_menu != null) {
                _menu.items_changed.connect (on_items_changed);
            }

            on_items_changed ();
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

    void on_items_changed () {
        while (get_last_child () != null) {
            remove (get_last_child ());
        }

        if (menu != null) {
            Gtk.ListBox list;

            for (uint i = 0; i < menu.get_n_items (); i++) {
                var section = (MenuSection) menu.get_item (i);

                PopoverMenuItem? row = null;
                list = new Gtk.ListBox ();

                section.bind_property ("visible", list, "visible", SYNC_CREATE);

                if (i == 0) {
                    if (previous != null) {
                        var brow = new Gtk.ListBoxRow ();
                        var box = new Gtk.CenterBox ();
                        brow.child = box;
                        box.center_widget = new Gtk.Label (previous_label);
                        box.start_widget = new Gtk.Image.from_icon_name ("go-previous-symbolic") {
                            css_classes = { "dimmed" },
                            accessible_role = PRESENTATION
                        };
                        var e = new Gtk.GestureClick ();
                        e.end.connect (() => {
                            main_menu.push (previous, true);
                        });
                        brow.add_controller (e);
                        var hlist = new Gtk.ListBox ();
                        hlist.append (brow);
                        append (hlist);
                    }
                } else {
                    if (section.label != null) {
                        list.set_header_func ((row, before) => {
                            if (before == null) {
                                row.set_header (new Gtk.Label (section.label) {
                                    xalign = 0.0f,
                                    css_classes = { "heading" },
                                    margin_bottom = 12,
                                    margin_top = 18,
                                    margin_start = 12
                                });
                            }
                        });
                    } else {
                        append (new Gtk.Separator (HORIZONTAL));
                    }
                }

                append (list);

                for (uint j = 0; j < section.get_n_items (); j++) {
                    var item = (MenuItem) section.get_item (j);

                    var custom = item.get_custom ("popover") as Gtk.Widget?;
                    if (custom != null) {
                        var r = new Gtk.ListBoxRow () {
                            child = custom,
                            activatable = false,
                            css_classes = { "no-backgound" },
                            margin_top = 6,
                            margin_bottom = 6
                        };
                        list.append (r);
                        continue;
                    }

                    if (item.submenu != null) {
                        row = new PopoverMenuItem.submenu (item);
                        var label = Uuid.string_random ();
                        main_menu.add (
                            new PopoverPage (
                                main_menu,
                                current ?? "root",
                                label,
                                item.label
                            ) {
                                menu = item.submenu
                            },
                            label
                        );
                        row.activated.connect (() => {
                            main_menu.push (label);
                        });
                        list.append (row);
                    } else {
                        row = new PopoverMenuItem.action (item);
                        row.activated.connect (() => {
                            main_menu.popdown ();
                        });
                        list.append (row);
                    }
                }
            }
        }
    }
}
