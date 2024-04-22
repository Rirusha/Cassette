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


namespace Cassette {
    [GtkTemplate (ui = "/io/github/Rirusha/Cassette/ui/volume_button.ui")]
    public class VolumeButton : CustomMenuButton {

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

        double _volume;
        public double volume {
            get {
                return _volume;
            }
            set {
                _volume = value;

                mute = false;

                volume_level_scale.set_value (Math.pow (_volume, 1.0 / 3.0) / MUL);

                check_button_sensetivity ();
            }
        }

        bool _mute;
        public bool mute {
            get {
                return _mute;
            }
            set {
                _mute = value;

                check_icon ();
            }
        }

        const double MUL = 0.01;

        double volume_upper;
        double volume_lower;
        double volume_step;

        construct {
            equalaizer_button.bind_property ("active", revealer, "reveal-child", BindingFlags.DEFAULT);

            block_widget (equalaizer_button, BlockReason.NOT_IMPLEMENTED);

            volume_level_scale.change_value.connect ((range, type, new_val) => {
                var val = new_val * MUL;

                volume = Math.pow (val, 3.0);

                return true;
            });

            volume_upper = volume_level_scale.adjustment.upper * MUL;
            volume_lower = volume_level_scale.adjustment.lower * MUL;
            volume_step = volume_level_scale.adjustment.step_increment * MUL;

            volume_inc_button.clicked.connect (() => {
                if (volume + volume_step > volume_upper) {
                    volume = volume_upper;
                } else {
                    volume += volume_step;
                }
            });

            volume_dec_button.clicked.connect (() => {
                if (volume - volume_step < volume_lower) {
                    volume = volume_lower;
                } else {
                    volume -= volume_step;
                }
            });
        }

        void check_button_sensetivity () {
            volume_inc_button.sensitive = volume < volume_upper;
            volume_dec_button.sensitive = volume > volume_lower;
        }

        void check_icon () {
            if (volume == volume_lower || mute) {
                real_button.icon_name = "adwaita-audio-volume-muted-symbolic";
            } else if (volume < 0.025) {
                real_button.icon_name = "adwaita-audio-volume-low-symbolic";
            } else if (volume < 0.35) {
                real_button.icon_name = "adwaita-audio-volume-medium-symbolic";
            } else {
                real_button.icon_name = "adwaita-audio-volume-high-symbolic";
            }
        }

        protected override Gtk.Widget[] get_popover_menu_items () {
            assert_not_reached ();
        }

        protected override Gtk.Widget[] get_dialog_menu_items () {
            assert_not_reached ();
        }
    }
}
