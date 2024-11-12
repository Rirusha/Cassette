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
using Gee;


namespace Cassette {
    [GtkTemplate (ui = "/space/rirusha/Cassette/ui/custom-pages-preferences.ui")]
    public class CustomPagesPreferences : Adw.PreferencesGroup {

        ArrayList<CustomPagePreferences> rows = new ArrayList<CustomPagePreferences> ();

        construct {
            map.connect (() => {
                foreach (var row in rows) {
                    remove (row);
                }
                rows.clear ();

                foreach (var page_info in application.main_window.pager.custom_pages) {
                    var page_pref = new CustomPagePreferences (page_info);
                    page_pref.deleted.connect ((sender) => {
                        rows.remove (sender);
                        remove (sender);

                        check_rows ();
                    });

                    rows.add (page_pref);
                    add (page_pref);
                }

                check_rows ();
            });
        }

        void check_rows () {
            if (rows.size == 0) {
                visible = false;
            } else {
                visible = true;
            }
        }
    }
}
