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


using Cassette.Client;

[GtkTemplate (ui = "/io/github/Rirusha/Cassette/ui/header-bar.ui")]
public class Cassette.HeaderBar : ShrinkableBin {

    [GtkChild]
    unowned Gtk.Button backward_button;
    [GtkChild]
    unowned Gtk.Button refresh_button;
    [GtkChild]
    unowned Gtk.ToggleButton search_button;
    [GtkChild]
    unowned Adw.ViewSwitcher switcher_title;
    [GtkChild]
    unowned PrimaryMenuButton menu_button;

    public bool can_backward {
        set {
            backward_button.visible = value;
        }
    }

    public bool can_refresh {
        set {
            refresh_button.visible = value;
        }
    }

    public bool can_search {
        set {
            search_button.visible = value;
        }
    }

    public Adw.ViewStack title_stack {
        get {
            return switcher_title.stack;
        }
        set {
            switcher_title.stack = value;
        }
    }

    public bool switcher_visible {
        get {
            return switcher_title.visible;
        }
        set {
            switcher_title.visible = value;
        }
    }

    public bool search_active { get; set; }

    public signal void backward_clicked ();

    public signal void refresh_clicked ();

    construct {
        notify["is-shrinked"].connect (() => {
            switcher_title.policy = is_shrinked ? Adw.ViewSwitcherPolicy.NARROW : Adw.ViewSwitcherPolicy.WIDE;
        });

        backward_button.clicked.connect (() => {
            backward_clicked ();
        });

        refresh_button.clicked.connect (() => {
            refresh_clicked ();
        });

        search_button.bind_property ("active", this, "search-active", BindingFlags.SYNC_CREATE | BindingFlags.DEFAULT);

        resized.connect ((width, height) => {
            if (title_stack != null) {
                shrink_edge_width = 200 + 90 * (int) title_stack.pages.get_n_items ();
            }
        });

        block_widget (search_button, BlockReason.NOT_IMPLEMENTED);
    }
}
