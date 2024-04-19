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


using Cassette.Client;


namespace Cassette {
    [GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/preferences_dialog.ui")]
    public class PreferencesDialog : Adw.PreferencesDialog {
        [GtkChild]
        unowned Adw.SwitchRow show_save_stack_switch;
        [GtkChild]
        unowned Adw.SwitchRow show_temp_save_stack_switch;
        [GtkChild]
        unowned Adw.SwitchRow is_hq_switch;
        [GtkChild]
        unowned Adw.SwitchRow child_visible_switch;
        [GtkChild]
        unowned Adw.SwitchRow explicit_visible_switch;
        [GtkChild]
        unowned Adw.SwitchRow show_replaced_mark_switch;
        [GtkChild]
        unowned Adw.SwitchRow available_visible_switch;
        [GtkChild]
        unowned Adw.SwitchRow add_tracks_to_start_switch;
        [GtkChild]
        unowned Adw.SwitchRow show_playing_track_notif_switch;
        [GtkChild]
        unowned Adw.SwitchRow show_main_switch;
        [GtkChild]
        unowned Adw.SwitchRow show_liked_switch;
        [GtkChild]
        unowned Adw.SwitchRow show_playlists_switch;
        [GtkChild]
        unowned Adw.SwitchRow can_cache_switch;
        [GtkChild]
        unowned Adw.SpinRow max_thread_number_spin;
        [GtkChild]
        unowned CacheDeletionPreferences deletion_preferences;
        [GtkChild]
        unowned Adw.SwitchRow debug_mode_switch;
        [GtkChild]
        unowned Adw.SwitchRow use_only_dialogs_switch;

        construct {
            //  deletion_preferences.pref_win = this;

            show_save_stack_switch.notify["active"].connect (on_show_save_stack_switch_changed);

            max_thread_number_spin.value = Cassette.Client.settings.get_int ("max-thread-number");
            can_cache_switch.active = Cassette.Client.settings.get_boolean ("can-cache");

            can_cache_switch.notify["active"].connect (() => {
                if (!can_cache_switch.active) {
                    ask_about_deletion ();
                } else {
                    Cassette.Client.settings.set_boolean ("can-cache", true);
                }
            });

            Cassette.Client.settings.bind ("add-tracks-to-start", add_tracks_to_start_switch, "active", GLib.SettingsBindFlags.DEFAULT);
            Cassette.settings.bind ("available-visible", available_visible_switch, "active", GLib.SettingsBindFlags.DEFAULT);
            Cassette.settings.bind ("show-playing-track-notif", show_playing_track_notif_switch, "active", GLib.SettingsBindFlags.DEFAULT);
            Cassette.settings.bind ("child-visible", child_visible_switch, "active", GLib.SettingsBindFlags.DEFAULT);
            Cassette.settings.bind ("explicit-visible", explicit_visible_switch, "active", GLib.SettingsBindFlags.DEFAULT);
            Cassette.settings.bind ("show-replaced-mark", show_replaced_mark_switch, "active", GLib.SettingsBindFlags.DEFAULT);
            Cassette.settings.bind ("show-save-stack", show_save_stack_switch, "active", GLib.SettingsBindFlags.DEFAULT);
            Cassette.settings.bind ("show-temp-save-mark", show_temp_save_stack_switch, "active", GLib.SettingsBindFlags.DEFAULT);
            Cassette.Client.settings.bind ("is-hq", is_hq_switch, "active", GLib.SettingsBindFlags.DEFAULT);
            Cassette.Client.settings.bind ("debug-mode", debug_mode_switch, "active", GLib.SettingsBindFlags.DEFAULT);
            Cassette.settings.bind ("use-only-dialogs", use_only_dialogs_switch, "active", GLib.SettingsBindFlags.DEFAULT);

            Cassette.settings.bind ("show-main", show_main_switch, "active", GLib.SettingsBindFlags.DEFAULT);
            Cassette.settings.bind ("show-liked", show_liked_switch, "active", GLib.SettingsBindFlags.DEFAULT);
            Cassette.settings.bind ("show-playlists", show_playlists_switch, "active", GLib.SettingsBindFlags.DEFAULT);

            max_thread_number_spin.notify["value"].connect (() => {
                Cassette.Client.settings.set_int ("max-thread-number", (int) max_thread_number_spin.value);
            });

            on_show_save_stack_switch_changed ();

            if (Cassette.application.is_devel) {
                add_css_class ("devel");
            }

            focus_widget = null;
        }

        void on_show_save_stack_switch_changed () {
            show_temp_save_stack_switch.sensitive = show_save_stack_switch.active;
        }

        void ask_about_deletion () {
            var dialog = new Adw.AlertDialog (
                _("Delete temporary files?"),
                _("All temporary cache will be deleted. This doesn't affect on saved playlists or albums")
            );

            // Translators: cancel of deleting playlist
            dialog.add_response ("cancel", _("Cancel"));
            dialog.add_response ("delete", _("Delete"));

            dialog.set_response_appearance ("delete", Adw.ResponseAppearance.DESTRUCTIVE);

            dialog.default_response = "cancel";
            dialog.close_response = "cancel";

            dialog.response.connect ((dialog, response) => {
                if (response == "delete") {
                    deletion_preferences.delete_files (true);
                    Cassette.Client.settings.set_boolean ("can-cache", can_cache_switch.active);
                } else {
                    can_cache_switch.active = true;
                }
            });

            dialog.present (this);
        }
    }
}
