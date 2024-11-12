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


[GtkTemplate (ui = "/space/rirusha/Cassette/ui/headered-scrolled-window.ui")]
public class Cassette.HeaderedScrolledWindow : Adw.Bin {

    [GtkChild]
    unowned Gtk.Revealer header_revealer;
    [GtkChild]
    unowned Adw.Bin header_bin;
    [GtkChild]
    unowned Gtk.ScrolledWindow real_scrolled_window;

    public Gtk.Widget header_widget {
        get {
            return header_bin.child;
        }
        set {
            header_bin.child = value;
        }
    }

    public Gtk.Widget body_widget {
        get {
            return real_scrolled_window.child;
        }
        set {
            real_scrolled_window.child = value;
        }
    }

    public bool on_top { get; private set; default = true; }

    public bool reveal_header { get; set; default = true; }

    construct {
        real_scrolled_window.vadjustment.value_changed.connect (() => {
            if (real_scrolled_window.vadjustment.value > 0) {
                if (!on_top) {
                    on_top = true;
                }

            } else {
                if (on_top) {
                    on_top = false;
                }
            }
        });

        bind_property ("reveal-header", header_revealer, "reveal-child", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
    }
}
