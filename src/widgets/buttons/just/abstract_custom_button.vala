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


[GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/custom_button.ui")]
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

    public new string[] css_classes {
        owned get {
            return real_button.css_classes;
        }
        set {
            real_button.css_classes = value;
        }
    }

    public int size {
        construct {
            width_request = value;
            height_request = value;
        }
    }

    public new void add_css_class (string class_name) {
        real_button.add_css_class (class_name);
    }
}
