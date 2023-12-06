/* options_button.vala
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
    public abstract class OptionsButton : Adw.Bin {

        protected Gtk.MenuButton real_button { get; default = new Gtk.MenuButton () {icon_name = "view-more-symbolic"}; }

        protected Menu queue_menu = new Menu ();
        protected Menu global_menu = new Menu ();
        protected Menu add_menu = new Menu ();
        protected Menu other_menu = new Menu ();

        public bool is_flat {
            construct {
                if (value) {
                    real_button.add_css_class ("flat");
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
            tooltip_text = _("Options menu");

            var base_menu = new Menu ();

            base_menu.append_section (null, queue_menu);
            base_menu.append_section (null, global_menu);
            base_menu.append_section (null, add_menu);
            base_menu.append_section (null, other_menu);

            real_button.menu_model = base_menu;

            set_menu ();
        }

        protected abstract void set_menu ();
    }
}
