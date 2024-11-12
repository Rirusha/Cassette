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


using Cassette.Client;


namespace Cassette {
    [GtkTemplate (ui = "/space/rirusha/Cassette/ui/custom-page-preferences.ui")]
    public class CustomPagePreferences : Adw.PreferencesRow {
        [GtkChild]
        unowned Gtk.Entry page_title_entry;
        [GtkChild]
        unowned Gtk.Entry page_icon_name_entry;
        [GtkChild]
        unowned Gtk.Button page_save_button;
        [GtkChild]
        unowned Gtk.Button page_remove_button;

        public string page_id { get; construct; }
        public string page_title { get; construct; }
        public string page_icon_name { get; construct; }

        public signal void deleted (CustomPagePreferences sender);

        public CustomPagePreferences (PageInfo page_info) {
            Object (page_id: page_info.id, page_title: page_info.title, page_icon_name: page_info.icon_name);
        }

        construct {
            page_title_entry.text = page_title;
            page_icon_name_entry.text = page_icon_name;

            page_save_button.clicked.connect (() => {
                if (page_title != page_title_entry.text || page_icon_name != page_icon_name_entry.text) {
                    application.main_window.pager.update_page (page_id, page_title_entry.text, page_icon_name_entry.text);
                }
            });

            page_remove_button.clicked.connect (() => {
                deleted (this);
                application.main_window.pager.remove_page (page_id);
            });
        }
    }
}
