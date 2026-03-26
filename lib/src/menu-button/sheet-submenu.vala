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


[GtkTemplate (ui = "/space/rirusha/Cassette/Lib/ui/sheet-submenu.ui")]
internal sealed class Cassette.SheetSubmenu : Adw.NavigationPage {

    [GtkChild]
    unowned Adw.HeaderBar header_bar;
    [GtkChild]
    unowned Gtk.Box header_box;
    [GtkChild]
    unowned Gtk.Box main_box;

    public Gtk.Widget menu_action_parent { get; construct; }

    public MenuModel menu_model { get; construct; }

    public SheetMenu main_menu { get; construct; }

    public string? submenu_label { get; construct; }

    public string? icon_name { get; construct; }

    Adw.PreferencesGroup current_section;

    public SheetSubmenu (
        Gtk.Widget menu_action_parent,
        SheetMenu main_menu,
        MenuModel menu_model,
        string? submenu_label = null,
        string? icon_name = null
    ) {
        assert (menu_model != null);

        Object (
            menu_action_parent: menu_action_parent,
            menu_model: menu_model,
            main_menu: main_menu,
            submenu_label: submenu_label,
            title: "opt",
            icon_name: icon_name ?? ""
        );
    }

    construct {
        if (icon_name != null) {
            header_box.append (new Gtk.Image.from_icon_name (icon_name));
        }

        if (submenu_label != null) {
            header_box.append (new Adw.WindowTitle (submenu_label, ""));
        }

        if (submenu_label != null || icon_name != null) {
            header_bar.show_title = true;
        } else {
            header_bar.show_title = false;
        }
    }

    void ensure_current_section (string? label) {
        if (current_section == null) {
            current_section = new Adw.PreferencesGroup () {
                margin_top = label != null ? 12 : 0
            };
            if (label != null) {
                current_section.title = label;
            }
            main_box.append (current_section);
        }
    }

    void add_section (MenuModel menu_model, string? label = null) {
        current_section = null;

        for (int i = 0; i < menu_model.get_n_items (); i++) {
            HashTable<string, Variant> attributes;
            menu_model.get_item_attributes (i, out attributes);

            HashTable<string, MenuModel> links;
            menu_model.get_item_links (i, out links);

            if (links.size () != 0) {
                var llabel = menu_model.get_item_attribute_value (i, "label", VariantType.STRING);
                var licon = menu_model.get_item_attribute_value (i, "icon", VariantType.STRING);

                foreach (var link in links.get_keys ()) {
                    switch (link) {
                        case "section":
                            add_section (links[link], llabel?.dup_string ());
                            break;
                        case "submenu":
                            add_submenu (links[link], llabel?.dup_string (), licon?.dup_string ());
                            break;
                        default:
                            assert_not_reached ();
                    }
                }

            } else if (attributes.size () != 0) {
                string? rlabel = null;
                string? ricon = null;
                bool ruse_markup = true;
                string? raction_name = null;
                string? rhidden_when = null;
                Variant? rtarget = null;
                string? rcustom = null;

                foreach (var attribute in attributes.get_keys ()) {
                    switch (attribute) {
                        case "label":
                            rlabel = attributes[attribute].dup_string ();
                            break;
                        case "icon":
                            ricon = attributes[attribute].dup_string ();
                            break;
                        case "use-markup":
                            ruse_markup = attributes[attribute].get_boolean ();
                            break;
                        case "action":
                            raction_name = attributes[attribute].dup_string ();
                            break;
                        case "hidden-when":
                            rhidden_when = attributes[attribute].dup_string ();
                            break;
                        case "target":
                            rtarget = attributes[attribute];
                            break;
                        case "custom":
                            rcustom = attributes[attribute].dup_string ();
                            break;
                    }
                }

                if (rcustom != null && rhidden_when != "mode-sheet") {
                    add_custom (rcustom);
                } else {
                    var row = new SheetMenuItem.action (
                        menu_action_parent,
                        raction_name,
                        rlabel,
                        ricon,
                        rtarget,
                        ruse_markup,
                        rhidden_when
                    );
                    row.activated.connect (() => {
                        main_menu.close ();
                    });
                    ensure_current_section (label);
                    current_section.add (row);
                }
            }
        }
    }

    void add_custom (string id) {
        var bin = new Adw.Bin () {
            visible = false
        };
        main_box.append (bin);
        current_section = null;
        main_menu.add_custom (id, bin);
    }

    void add_submenu (MenuModel menu_model, string? label, string? icon) {
        ensure_current_section (null);

        var row = new SheetMenuItem.submenu (label, icon);

        main_menu.add (new SheetSubmenu (menu_action_parent, main_menu, menu_model, label, icon), label);

        row.activated.connect (() => {
            main_menu.push (label);
        });

        ensure_current_section (label);
        current_section.add (row);
    }
}
