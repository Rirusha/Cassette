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

[GtkTemplate (ui = "/space/rirusha/Cassette/ui/loadable-widget.ui")]
public class Cassette.LoadableWidget: Adw.Bin {

    [GtkChild]
    unowned Gtk.Stack main_stack;
    [GtkChild]
    unowned Adw.Bin result_bin;
    [GtkChild]
    unowned Adw.Bin error_bin;

    public Gtk.Widget result_widget {
        get {
            return result_bin.child;
        }
        set {
            result_bin.child = value;
        }
    }

    public Gtk.Widget error_widget {
        get {
            return error_bin.child;
        }
        set {
            error_bin.child = value;
        }
    }

    public void show_loading () {
        main_stack.visible_child_name = "loading";
    }

    public void show_result () {
        main_stack.visible_child_name = "result";
    }

    public void show_error () {
        main_stack.visible_child_name = "error";
    }
}
