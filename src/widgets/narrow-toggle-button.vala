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

[GtkTemplate (ui = "/io/github/Rirusha/Cassette/ui/narrow-toggle-button.ui")]
public class Cassette.NarrowToggleButton: Gtk.ToggleButton {

    [GtkChild]
    unowned Gtk.Image button_image;
    [GtkChild]
    unowned Gtk.Label button_label;

    public new string icon_name {
        owned get {
            return button_image.icon_name;
        }
        construct set {
            button_image.icon_name = value;

            if (value != null && value != "") {
                button_image.visible = true;

            } else {
                button_image.visible = false;
            }
        }
    }

    public new string label {
        get {
            return button_label.label;
        }
        construct set {
            button_label.label = value;
        }
    }
}
