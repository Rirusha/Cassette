/* info_marks.vala
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


using CassetteClient;
using Gee;


namespace Cassette {
    // Может принимать вид кнопки, так и простого текста
    [GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/info_marks.ui")]
    public class InfoMarks : Adw.Bin {   

        [GtkChild]
        private unowned Gtk.Image track_replaced_mark;
        [GtkChild]
        private unowned Gtk.Image exp_mark;
        [GtkChild]
        public unowned Gtk.Image child_mark;

        YaMAPI.Track? _replaced_by = null;
        public YaMAPI.Track? replaced_by {
            set {
                _replaced_by = value;

                if (_replaced_by != null) {
                    track_replaced_mark.tooltip_text = _("Track was replaced. Original version: %s, %s").printf (_replaced_by.full_title, _replaced_by.get_artists_names ());
                } else {
                    track_replaced_mark.tooltip_text = "";
                }

                check_replaced_mark_visible ();
            }
        }

        public bool is_exp {
            set {
                exp_mark.visible = value;
            }
        }

        public bool is_child {
            set {
                child_mark.visible = value;
            }
        }

        construct {
            storager.settings.changed.connect ((key) => {
                if (key == "show-replaced-mark") {
                    check_replaced_mark_visible ();
                }
            });
        } 

        void check_replaced_mark_visible () {
            if (_replaced_by != null && storager.settings.get_boolean ("show-replaced-mark")) {
                track_replaced_mark.visible = true;
            } else {
                track_replaced_mark.visible = false;   
            }
        }
    }
}