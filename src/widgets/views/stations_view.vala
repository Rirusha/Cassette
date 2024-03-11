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

    [GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/stations_view.ui")]
    public class StationsView : BaseView {

        [GtkChild]
        unowned Gtk.ListBox list_box;

        public override bool can_refresh {
            get {
                return false;
            }
        }

        async void set_values_async (
            YaMAPI.Rotor.Dashboard dashboard,
            Gee.ArrayList<YaMAPI.Rotor.Station> stations_list
        ) {
            foreach (var station in dashboard.stations) {
                list_box.append (new Adw.ActionRow () {
                    title = station.station.name,
                    icon_name = YaMAPI.Rotor.Icon.get_internal_icon_name ("")
                });

                Idle.add (set_values_async.callback);
                yield;
            }

            foreach (var station in stations_list) {
                list_box.append (new Adw.ActionRow () {
                    title = station.station.name,
                    icon_name = YaMAPI.Rotor.Icon.get_internal_icon_name ("")
                });

                Idle.add (set_values_async.callback);
                yield;
            }

            show_ready ();
        }

        public async override int try_load_from_web () {
            YaMAPI.Rotor.Dashboard? dashboard = null;
            Gee.ArrayList<YaMAPI.Rotor.Station>? stations_list = null;

            threader.add (() => {
                dashboard = yam_talker.client.rotor_stations_dashboard ();
                stations_list = yam_talker.client.rotor_stations_list ();

                message (Jsoner.serialize (dashboard));

                Idle.add (try_load_from_web.callback);
            });

            yield;

            if (dashboard != null && stations_list != null) {
                set_values (dashboard, stations_list);

                return -1;
            }

            return 0;
        }

        public async override bool try_load_from_cache () {
            return false;
        }
    }
}