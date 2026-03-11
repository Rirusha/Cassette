/*
 * Copyright (C) 2025 Vladimir Romanov <rirusha@altlinux.org>
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

using Tape;

[GtkTemplate (ui = "/space/rirusha/Cassette/ui/loadable.ui")]
public class Cassette.Loadable : Adw.Bin {

    [GtkChild]
    unowned Gtk.Stack stack;

    public Gtk.Widget? content {
        get {
            return stack.get_child_by_name ("content");
        }
        set {
            if (stack.get_child_by_name ("content") != null) {
                stack.remove (stack.get_child_by_name ("content"));
            }

            if (value != null) {
                stack.add_named (value, "content");
            }
        }
    }

    public bool is_loading { get; set; default = true; }

    bool? wait_to_is_loading = null;

    construct {
        on_loading_changed ();
    }

    [GtkCallback]
    void on_loading_changed () {
        wait_to_is_loading = is_loading;

        if (!stack.transition_running) {
            on_transition_ended ();
        }
    }

    [GtkCallback]
    void on_transition_ended () {
        if (wait_to_is_loading == null) {
            return;
        }

        if (wait_to_is_loading) {
            stack.visible_child_name = "loading";
        } else {
            if (stack.get_child_by_name ("content") != null) {
                stack.visible_child_name = "content";
            } else {
                critical ("Can't stop loading while content is empty");
            }
        }

        wait_to_is_loading = null;
    }
}
