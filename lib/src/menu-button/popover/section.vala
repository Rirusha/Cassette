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

[GtkTemplate (ui = "/space/rirusha/Cassette/Lib/ui/popover-section.ui")]
internal sealed class Cassette.PopoverSection : Gtk.Box {

    [GtkChild]
    unowned Gtk.Separator sep;
    [GtkChild]
    unowned Gtk.Label heading_label;
    [GtkChild]
    unowned Gtk.ListBox list;

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
                _menu.bind_property ("visible", this, "visible", SYNC_CREATE);
                _menu.items_changed.connect (on_items_changed);
            }

            on_items_changed ();
        }
    }

    public PopoverMenu main_menu { get; construct; }

    public string title { get; set; }

    bool is_first;
    string? current;

    public PopoverSection (
        PopoverMenu main_menu,
        string? current,
        bool is_first
    ) {
        Object (
            main_menu: main_menu
        );

        this.is_first = is_first;
        this.current = current;
    }

    public PopoverSection.back_header (
        PopoverMenu main_menu,
        string previous_label,
        string previous
    ) {
        Object (
            main_menu: main_menu
        );

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
        list.append (brow);
    }

    void on_items_changed () {
        list.remove_all ();

        if (title != null && title != "") {
            heading_label.label = title;
            heading_label.visible = true;
            sep.visible = false;
        } else {
            heading_label.visible = false;
            sep.visible = !is_first;
        }

        if (menu != null) {
            for (uint j = 0; j < menu.get_n_items (); j++) {
                var item = (MenuItem) menu.get_item (j);

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
                    var row = new PopoverMenuItem.submenu (item);
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
                    var row = new PopoverMenuItem.action (item);
                    row.activated.connect (() => {
                        main_menu.popdown ();
                    });
                    list.append (row);
                }
            }
        }
    }
}
