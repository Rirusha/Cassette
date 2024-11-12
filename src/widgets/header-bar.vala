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


using Cassette.Client;

[GtkTemplate (ui = "/space/rirusha/Cassette/ui/header-bar.ui")]
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
    [GtkChild]
    unowned Gtk.Button avatar_button;
    [GtkChild]
    unowned Adw.Avatar avatar;
    [GtkChild]
    unowned CacheIndicator cache_indicator;

    public bool sidebar_shown { get; set; }

    public bool interactive { get; set; }

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
        avatar_button.clicked.connect (on_avatar_button_clicked);

        notify["is-shrinked"].connect (() => {
            switcher_title.policy = is_shrinked ? Adw.ViewSwitcherPolicy.NARROW : Adw.ViewSwitcherPolicy.WIDE;
        });

        backward_button.clicked.connect (() => {
            backward_clicked ();
        });

        refresh_button.clicked.connect (() => {
            refresh_clicked ();
        });

        resized.connect ((width, height) => {
            if (title_stack != null) {
                shrink_edge_width = (sidebar_shown ? 360 : 0) + 200 + 90 * (int) title_stack.pages.get_n_items ();
            }
        });

        // Also https://github.com/Rirusha/Cassette/blob/master/data/ui/header-bar.blp#L29
        block_widget (search_button, BlockReason.NOT_IMPLEMENTED);
    }

    public void on_avatar_button_clicked () {
        var dilaog = new AccountInfoDialog (yam_talker.me);
        dilaog.present (this);
    }

    public async void load_avatar () {
        avatar.text = yam_talker.me.public_name;

        var pixbuf = yield Client.Cachier.get_image (yam_talker.me, 28);
        if (pixbuf != null) {
            avatar.custom_image = Gdk.Texture.for_pixbuf (pixbuf);
        }

        avatar_button.visible = true;
    }
}
