/* custom_button.vala
 *
 * Copyright 2023 Rirusha
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
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Cassette {
    public abstract class CustomButton : Adw.Bin {

        protected virtual Gtk.Button real_button { get; default = new Gtk.Button (); }
        Adw.ButtonContent button_content = new Adw.ButtonContent ();

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

        // Если кто-то знает, как сократить свойства ниже в <style><style/> других ui файлах, то милости прошу
        public bool is_flat {
            construct {
                if (value) {
                    real_button.add_css_class ("flat");
                }
            }
        }

        public bool is_suggested_action {
            construct {
                if (value) {
                    real_button.add_css_class ("suggested-action");
                }
            }
        }

        public bool is_osd {
            construct {
                if (value) {
                    real_button.add_css_class ("osd");
                }
            }
        }

        public bool is_overlay {
            construct {
                if (value) {
                    real_button.add_css_class ("overlay-button");
                }
            }
        }

        public bool is_circular {
            construct {
                if (value) {
                    real_button.add_css_class ("circular");
                }
            }
        }

        public bool is_pill {
            construct {
                if (value) {
                    real_button.add_css_class ("pill");
                }
            }
        }

        public int size {
            construct {
                real_button.width_request = value;
                real_button.height_request = value;
            }
        }

        construct {
            child = real_button;
            real_button.child = button_content;
        }
    }
}
