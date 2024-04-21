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


[GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/menu_dialog.ui")]
public class Cassette.MenuDialog : Adw.Dialog {

    [GtkChild]
    unowned Adw.Clamp clamp;
    [GtkChild]
    unowned Adw.Bin menu_bin;
    [GtkChild]
    unowned Adw.Bin title_bin;
    [GtkChild]
    unowned ShrinkableBin shrinkable_bin;
    [GtkChild]
    unowned Gtk.ScrolledWindow scrolled_window;

    public Gtk.Widget? menu_widget {
        get {
            return menu_bin.child;
        }
        set {
            menu_bin.child = value;
        }
    }

    public Gtk.Widget? title_widget {
        get {
            return title_bin.child;
        }
        set {
            title_bin.child = value;
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
