/* Copyright 2023-2025 Vladimir Vaskov
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


[GtkTemplate (ui = "/space/rirusha/Cassette/ui/action-card-custom.ui")]
/**
    * A class for convenient work with clickable cards.
    */
public class Cassette.ActionCardCustom : Reactable {

    public signal void clicked ();

    protected override string css_class_name_hover {
        owned get {
            return "action-card-hover";
        }
    }

    protected override string css_class_name_active {
        owned get {
            return "action-card-active";
        }
    }


    protected override string css_class_name_playing_default {
        owned get {
            return "";
        }
    }

    protected override string css_class_name_playing_hover {
        owned get {
            return "";
        }
    }

    protected override string css_class_name_playing_active {
        owned get {
            return "";
        }
    }

    construct {
        var gs = new Gtk.GestureClick ();
        gs.released.connect ((n, x, y) => {
            if (contains (x, y)) {
                clicked ();
            }
        });
        add_controller (gs);
    }
}
