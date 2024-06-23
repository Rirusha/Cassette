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

using Cassette.Client.YaMAPI;
using Gee;

[GtkTemplate (ui = "/io/github/Rirusha/Cassette/ui/wave-settings.ui")]
public sealed class Cassette.WaveSettings: SidebarChildBin {

    [GtkChild]
    unowned LoadableWidget loadable_widget;
    [GtkChild]
    unowned Gtk.FlowBox by_activity_box;
    [GtkChild]
    unowned Gtk.FlowBox by_diversity_box;
    [GtkChild]
    unowned Gtk.FlowBox by_mood_energy_box;
    [GtkChild]
    unowned Gtk.FlowBox by_language_box;

    Rotor.Settings? wave_settings;

    construct {
        child_id = "null:wave";
        title = _("Wave settings");

        fetch_wave_settings.begin ();
    }

    async void fetch_wave_settings () {
        wave_settings = yield yam_talker.get_wave_settings ();

        if (wave_settings != null) {
            loadable_widget.show_result ();
            set_values ();

        } else {
            loadable_widget.show_error ();
        }
    }

    void set_values () {
        NarrowToggleButton? button_for_group = null;

        foreach (var item in wave_settings.blocks[0].items) {
            var narrow_button = new NarrowToggleButton () {
                label = item.name,
                icon_name = item.icon.get_internal_icon_name (item.id.normal),
            };

            if (button_for_group == null) {
                button_for_group = narrow_button;

            } else {
                narrow_button.group = button_for_group;
            }

            by_activity_box.append (narrow_button);
        }

        button_for_group = null;

        foreach (var item in wave_settings.setting_restrictions.diversity.possible_values) {
            if (item.value != "default") {
                var narrow_button = new NarrowToggleButton () {
                    label = item.name,
                };

                if (button_for_group == null) {
                    button_for_group = narrow_button;

                } else {
                    narrow_button.group = button_for_group;
                }

                by_diversity_box.append (narrow_button);
            }
        }

        button_for_group = null;

        foreach (var item in wave_settings.setting_restrictions.mood_energy.possible_values) {
            if (item.value != "all") {
                var narrow_button = new NarrowToggleButton () {
                    label = item.name,
                };

                if (button_for_group == null) {
                    button_for_group = narrow_button;

                } else {
                    narrow_button.group = button_for_group;
                }

                by_mood_energy_box.append (narrow_button);
            }
        }

        button_for_group = null;

        foreach (var item in wave_settings.setting_restrictions.language.possible_values) {
            if (item.value != "any") {
                var narrow_button = new NarrowToggleButton () {
                    label = item.name,
                };

                if (button_for_group == null) {
                    button_for_group = narrow_button;

                } else {
                    narrow_button.group = button_for_group;
                }

                by_language_box.append (narrow_button);
            }
        }
    }
}
