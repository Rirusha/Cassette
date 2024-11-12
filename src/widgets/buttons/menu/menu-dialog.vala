/* Copyright 2023-2024 Vladimir Vaskov
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

[GtkTemplate (ui = "/space/rirusha/Cassette/ui/menu-dialog.ui")]
public class Cassette.MenuDialog : Adw.Dialog {

    [GtkChild]
    unowned ShrinkableBin shrinkable_bin;
    [GtkChild]
    unowned Adw.Clamp title_clamp;
    [GtkChild]
    unowned Gtk.ScrolledWindow scrolled_window;
    [GtkChild]
    unowned Adw.Clamp menu_clamp;

    public Gtk.Widget? menu_widget {
        get {
            return menu_clamp.child;
        }
        set {
            menu_clamp.child = value;
        }
    }

    public Gtk.Widget? title_widget {
        get {
            return title_clamp.child;
        }
        set {
            if (value is Gtk.Button) {
                value.add_css_class ("button-standart-padding");
                value.add_css_class ("flat");
                ((Gtk.Button) value).clicked.connect (() => {
                    close ();
                });

            } else {
                value.margin_bottom = 5;
                value.margin_top = 5;
                value.margin_start = 5;
                value.margin_end = 5;
            }

            title_clamp.child = value;
        }
    }

    construct {
        shrinkable_bin.notify["root-window-is-shrinked"].connect (update_scrolled);
        update_scrolled ();
    }

    void update_scrolled () {
        if (shrinkable_bin.root_window_is_shrinked) {
            scrolled_window.vscrollbar_policy = Gtk.PolicyType.NEVER;
            follows_content_size = false;

        } else {
            scrolled_window.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
            follows_content_size = true;
        }
    }
}
