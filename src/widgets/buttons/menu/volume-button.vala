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

public class Cassette.VolumeButton : CustomMenuButton {

    Gtk.Adjustment adjustment;

    double _volume;
    public double volume {
        get {
            return _volume;
        }
        set {
            _volume = value;

            adjustment.value = Math.pow (_volume, 1.0 / 3.0) / MUL;

            can_increase = volume < volume_upper;
            can_decrease = volume > volume_lower;
        }
    }

    bool _mute;
    public bool mute {
        get {
            return _mute;
        }
        set {
            _mute = value;

            if (mute) {
                adjustment.value = 0;

            } else {
                adjustment.value = Math.pow (volume, 1.0 / 3.0) / MUL;
            }

            check_icon ();
        }
    }

    public bool can_increase { get; set; default = true; }

    public bool can_decrease { get; set; default = true; }

    const double MUL = 0.01;

    double volume_upper;
    double volume_lower;
    double volume_step;

    double adjustment_actual_upper = 100.0;
    double adjustment_actual_lower = 0.0;

    Gtk.EventControllerScroll se;
    Settings touchpad_settings = new Settings ("org.gnome.desktop.peripherals.touchpad");

    construct {
        adjustment = new Gtk.Adjustment (50.0, adjustment_actual_lower, adjustment_actual_upper + 1.0, 5.0, 5.0, 1.0);

        add_css_class ("flat");
        icon_name = "audio-volume-high-symbolic";

        volume_upper = adjustment_actual_upper * MUL;
        volume_lower = adjustment_actual_lower * MUL;
        volume_step = adjustment.step_increment * MUL;

        real_button.direction = Gtk.ArrowType.UP;

        se = new Gtk.EventControllerScroll (Gtk.EventControllerScrollFlags.VERTICAL);
        se.scroll.connect ((dx, dy) => {
            if (mute) {
                mute = false;
                volume = 0.0;
            }

            switch (se.get_unit ()) {
                case Gdk.ScrollUnit.WHEEL:
                    bool is_increase = dy < 0;

                    for (int i = 0; i < dy.abs (); i++) {
                        if (is_increase) {
                            increase_volume ();

                        } else {
                            decrease_volume ();
                        }
                    }

                    break;

                case Gdk.ScrollUnit.SURFACE:
                    change_volume ((touchpad_settings.get_boolean ("natural-scroll") ? -dy : dy) * MUL);
                    break;

                default:
                    assert_not_reached ();
            }
        });
        add_controller (se);

        Cassette.Client.settings.bind ("volume", this, "volume", SettingsBindFlags.DEFAULT);
        Cassette.Client.settings.bind ("mute", this, "mute", SettingsBindFlags.DEFAULT);
    }

    protected override string get_title_label () {
        return _("Volume control");
    }

    void increase_volume () {
        change_volume (volume_step);
    }

    void decrease_volume () {
        change_volume (-volume_step);
    }

    /*
     * @param dvol  delta volume, 0.0-1.0
     */
    void change_volume (double dvol) {
        double svol = Math.pow (volume, 1.0 / 3.0);

        svol += dvol;

        if (svol > volume_upper) {
            volume = volume_upper;

        } else if (svol < volume_lower) {
            volume = volume_lower;

        } else {
            volume = Math.pow (svol, 3.0);
        }
    }

    void check_icon () {
        if (volume == volume_lower || mute) {
            real_button.icon_name = "audio-volume-muted-symbolic";
        } else if (volume < 0.025) {
            real_button.icon_name = "audio-volume-low-symbolic";
        } else if (volume < 0.35) {
            real_button.icon_name = "audio-volume-medium-symbolic";
        } else {
            real_button.icon_name = "audio-volume-high-symbolic";
        }
    }

    Gtk.Orientation mirror_orientation (Gtk.Orientation orientation) {
        if (orientation == Gtk.Orientation.HORIZONTAL) {
            return Gtk.Orientation.VERTICAL;
        }

        return Gtk.Orientation.HORIZONTAL;
    }

    Gtk.Box build_volume_box (Gtk.Orientation orientation) {
        var box = new Gtk.Box (
            mirror_orientation (orientation),
            0
        ) {
            height_request = orientation == Gtk.Orientation.HORIZONTAL ? -1 : 270,
            valign = orientation == Gtk.Orientation.HORIZONTAL ? Gtk.Align.END : Gtk.Align.FILL
        };

        var equalaizer_revealer = new Gtk.Revealer () {
            reveal_child = orientation == Gtk.Orientation.HORIZONTAL,
            transition_type = orientation == Gtk.Orientation.HORIZONTAL ?
                Gtk.RevealerTransitionType.SLIDE_DOWN : Gtk.RevealerTransitionType.SLIDE_RIGHT
        };
        box.append (equalaizer_revealer);

        var equalaizer_box = new Gtk.Box (mirror_orientation (orientation), 8);
        equalaizer_revealer.child = equalaizer_box;

        equalaizer_box.append (new Equalaizer ());

        var separator = new Gtk.Separator (orientation);
        if (orientation == Gtk.Orientation.HORIZONTAL) {
            separator.add_css_class ("spacer");
        } else {
            separator.margin_end = 4;
        }
        equalaizer_box.append (separator);

        var volume_box = new Gtk.Box (orientation, 4);
        box.append (volume_box);

        var equalaizer_button = new Gtk.ToggleButton () {
            css_classes = { "flat" },
            visible = orientation == Gtk.Orientation.VERTICAL,
            icon_name = "sound-wave-alt-symbolic"
        };
        volume_box.append (equalaizer_button);
        equalaizer_button.bind_property ("active", equalaizer_revealer, "reveal-child", BindingFlags.DEFAULT);
        block_widget (equalaizer_button, BlockReason.NOT_IMPLEMENTED);

        var volume_first_button = new Gtk.Button () {
            css_classes = { "flat" }
        };
        volume_box.append (volume_first_button);

        var volume_level_scale = new Gtk.Scale (orientation, adjustment) {
            vexpand = orientation == Gtk.Orientation.VERTICAL,
            hexpand = orientation == Gtk.Orientation.HORIZONTAL,
            inverted = orientation == Gtk.Orientation.VERTICAL
        };
        volume_box.append (volume_level_scale);
        volume_level_scale.change_value.connect ((range, type, new_val) => {
            double val = new_val;

            if (val < adjustment_actual_lower) {
                val = adjustment_actual_lower;

            } else if (val > adjustment_actual_upper) {
                val = adjustment_actual_upper;
            }

            mute = false;

            volume = Math.pow (val * MUL, 3.0);

            return true;
        });

        var volume_second_button = new Gtk.Button () {
            css_classes = { "flat" }
        };
        volume_box.append (volume_second_button);

        var mute_button = new Gtk.ToggleButton () {
            css_classes = { "flat" },
            icon_name = "audio-volume-muted-symbolic"
        };
        player.bind_property (
            "mute",
            mute_button,
            "active",
            BindingFlags.DEFAULT | BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE
        );
        player.bind_property (
            "mute",
            mute_button,
            "tooltip-text",
            BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
            (binding, srcval, ref trgval) => {
                trgval.set_string (srcval.get_boolean () ? _("Unmute") : _("Mute"));

                return true;
            }
        );
        volume_box.append (mute_button);

        if (orientation == Gtk.Orientation.HORIZONTAL) {
            volume_first_button.icon_name = "minus-symbolic";
            volume_first_button.clicked.connect (decrease_volume);

            volume_second_button.icon_name = "plus-symbolic";
            volume_second_button.clicked.connect (increase_volume);

            this.bind_property (
                "can-decrease",
                volume_first_button, "sensitive",
                BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE
            );
            this.bind_property (
                "can-increase",
                volume_second_button, "sensitive",
                BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE
            );

        } else {
            volume_first_button.icon_name = "plus-symbolic";
            volume_first_button.clicked.connect (increase_volume);

            volume_second_button.icon_name = "minus-symbolic";
            volume_second_button.clicked.connect (decrease_volume);

            this.bind_property (
                "can-increase",
                volume_first_button, "sensitive",
                BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE
            );
            this.bind_property (
                "can-decrease",
                volume_second_button, "sensitive",
                BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE
            );
        }

        return box;
    }

    protected override Gtk.Widget[] get_popover_menu_widgets () {
        return {
            build_volume_box (Gtk.Orientation.VERTICAL)
        };
    }

    protected override Gtk.Widget[] get_dialog_menu_widgets () {
        return {
            build_volume_box (Gtk.Orientation.HORIZONTAL)
        };
    }
}
