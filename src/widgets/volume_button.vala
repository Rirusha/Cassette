/* track_detailed.vala
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
    [GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/volume_button.ui")]
    public class VolumeButton : Adw.Bin {
        [GtkChild]
        unowned Gtk.MenuButton real_menu_button;
        [GtkChild]
        unowned Gtk.ToggleButton equalaizer_button;
        [GtkChild]
        unowned Gtk.Revealer revealer;
        [GtkChild]
        unowned Gtk.Button volume_inc_button;
        [GtkChild]
        unowned Gtk.Button volume_dec_button;
        [GtkChild]
        unowned Gtk.Scale volume_level_scale;

        public double volume {
            get {
                return volume_level_scale.get_value ();
            }
            set {
                volume_level_scale.set_value (value);
            }
        }

        public VolumeButton () {
            Object ();
        }

        construct {
            equalaizer_button.bind_property ("active", revealer, "reveal-child", BindingFlags.DEFAULT);

            block_widget (equalaizer_button, BlockReason.NOT_IMPLEMENTED);

            volume_inc_button.clicked.connect (() => {
                volume = volume_level_scale.get_value () + 0.1;
            });

            volume_dec_button.clicked.connect (() => {
                volume = volume_level_scale.get_value () - 0.1;
            });

            volume_level_scale.change_value.connect ((scroll, new_value) => {
                volume = new_value;
            });

            notify["volume"].connect (() => {
                volume_inc_button.sensitive = volume != 1;
                volume_dec_button.sensitive = volume != 0.0;

                if (volume == 0.0) {
                    real_menu_button.icon_name = "audio-volume-muted-symbolic";
                } else if (volume < 0.45) {
                    real_menu_button.icon_name = "audio-volume-low-symbolic";
                } else if (volume < 0.9) {
                    real_menu_button.icon_name = "audio-volume-medium-symbolic";
                } else {
                    real_menu_button.icon_name = "audio-volume-high-symbolic";
                }
            });
        }
    }
}
