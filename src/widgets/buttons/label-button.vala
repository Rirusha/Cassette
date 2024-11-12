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

using Gee;

namespace Cassette {
    // Может принимать вид кнопки, так и простого текста
    [GtkTemplate (ui = "/space/rirusha/Cassette/ui/label-button.ui")]
    public class LabelButton : Adw.Bin {

        [GtkChild]
        unowned Gtk.Label just_label;
        [GtkChild]
        unowned Gtk.Label button_label;
        [GtkChild]
        public unowned Gtk.Button button;
        [GtkChild]
        public unowned Gtk.Stack stack;

        public string line { get; construct set; }
        public int64 time_ms { get; construct set; default = -1; }

        public string label { get; construct; }
        public bool button_visible { get; construct; }

        public LabelButton (string label, bool button_visible) {
            Object (label: label, button_visible: button_visible);
        }

        construct {
            if (button_visible) {
                stack.visible_child_name = "with_button";
                button_label.label = label;
            } else {
                stack.visible_child_name = "just";
                just_label.label = label;
            }
        }
    }
}
