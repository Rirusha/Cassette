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


[GtkTemplate (ui = "/space/rirusha/Cassette/ui/custom-button.ui")]
public abstract class Cassette.CustomButton : Adw.Bin {

    [GtkChild]
    protected unowned Gtk.Button real_button;
    [GtkChild]
    unowned Adw.ButtonContent button_content;

    public string label {
        get {
            return button_content.label;
        }
        set {
            button_content.label = value;
        }
    }

    public string icon_name {
        get {
            return button_content.icon_name;
        }
        set {
            button_content.icon_name = value;
        }
    }

    /**
     * Easy way to set both width and height of the button.
     */
    public int size {
        construct {
            width_request = value;
            height_request = value;
        }
    }

    construct {
        bind_property ("css-classes", real_button, "css-classes", BindingFlags.DEFAULT);
    }
}
