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


[GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/action_card_custom.ui")]
/**
    * A class for convenient work with clickable cards.
    */
public class Cassette.ActionCardCustom : Gtk.Frame {

    public signal void clicked ();

    public ActionCardCustom.with_content () {
        Object ();
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
