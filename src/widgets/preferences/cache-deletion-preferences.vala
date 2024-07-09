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


using Cassette.Client;
using Cassette.Client.Cachier;
using Gee;


namespace Cassette {
    [GtkTemplate (ui = "/io/github/Rirusha/Cassette/ui/cache-deletion-preferences.ui")]
    public class CacheDeletionPreferences : Adw.PreferencesRow {
        [GtkChild]
        unowned Gtk.Stack temp_stack;
        [GtkChild]
        unowned Gtk.Spinner temp_spinner;
        [GtkChild]
        unowned Gtk.Label temp_size_label;
        [GtkChild]
        unowned Gtk.Label temp_type_label;
        [GtkChild]
        unowned Gtk.Button temp_delete_button;
        [GtkChild]
        unowned Gtk.Button perm_delete_button;
        [GtkChild]
        unowned Gtk.Stack perm_stack;
        [GtkChild]
        unowned Gtk.Spinner perm_spinner;
        [GtkChild]
        unowned Gtk.Label perm_size_label;
        [GtkChild]
        unowned Gtk.Label perm_type_label;

        public Adw.PreferencesWindow pref_win { get; set; }
        Adw.Window? loading_win = null;

        construct {
            map.connect (update_data);

            temp_delete_button.clicked.connect (() => {
                ask_about_deletion (true);
            });
            perm_delete_button.clicked.connect (() => {
                ask_about_deletion (false);
            });
        }

        void update_data () {
            temp_spinner.start ();
                storager.get_temp_size.begin ((obj, res) => {
                    HumanitySize humanity_size = storager.get_temp_size.end (res);

                    temp_size_label.label = humanity_size.size;
                    temp_type_label.label = humanity_size.unit;

                    temp_stack.visible_child_name = "ready";
                    temp_spinner.stop ();
                });

                perm_spinner.start ();
                storager.get_perm_size.begin ((obj, res) => {
                    HumanitySize humanity_size = storager.get_perm_size.end (res);

                    perm_size_label.label = humanity_size.size;
                    perm_type_label.label = humanity_size.unit;

                    perm_stack.visible_child_name = "ready";
                    perm_spinner.stop ();
                });
        }

        void ask_about_deletion (bool is_tmp) {
            var dialog = new Adw.AlertDialog (
                is_tmp ? _("Delete cache files?") :
                    _("Moved saved files?"),
                is_tmp ? _("All cache will be deleted. This doesn't affect on saved playlists or albums") :
                    _("All saved playlists and albums will be moved to cache files. This could take a while.")
            );

            // Translators: cancel of deleting playlist
            dialog.add_response ("cancel", _("Cancel"));
            dialog.add_response ("delete", _("Delete"));

            dialog.set_response_appearance ("delete", Adw.ResponseAppearance.DESTRUCTIVE);

            dialog.default_response = "cancel";
            dialog.close_response = "cancel";

            dialog.response.connect ((dialog, response) => {
                if (response == "delete") {
                    delete_files (is_tmp);
                }
            });

            dialog.present (pref_win);
        }

        public void delete_files (bool is_tmp) {
            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 16) {
                margin_top = 16,
                margin_bottom = 16,
                margin_start = 16,
                margin_end = 16
            };

            loading_win = new Adw.Window () {
                resizable = false,
                transient_for = pref_win,
                modal = true,
                content = box
            };

            box.append (new LoadingSpinner ());

            var label = new Gtk.Label (is_tmp? _("Deleting…") : _("Moving…"));
            label.add_css_class ("title-1");
            box.append (label);

            loading_win.present ();

            if (is_tmp) {
                storager.delete_temp_cache.begin (() => {
                    loading_win.close ();
                    loading_win = null;

                    update_data ();
                });
            } else {
                cachier.uncache_all.begin (() => {
                    loading_win.close ();
                    loading_win = null;

                    update_data ();
                });
            }
        }
    }
}
