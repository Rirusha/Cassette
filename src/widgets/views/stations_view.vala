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
        unowned Gtk.FlowBox dashboard_flow_box;
        [GtkChild]
        unowned Gtk.FlowBox genre_flow_box;
        [GtkChild]
        unowned Gtk.FlowBox mood_flow_box;
        [GtkChild]
        unowned Gtk.FlowBox activity_flow_box;
        [GtkChild]
        unowned Gtk.FlowBox epoch_flow_box;
        [GtkChild]
        unowned Gtk.FlowBox other_flow_box;

        public override bool can_refresh {
            get {
                return true;
            }
        }

        async void set_values_async (
            YaMAPI.Rotor.Dashboard dashboard,
            Gee.ArrayList<YaMAPI.Rotor.Station> stations_list
        ) {
            clear_flow_box (dashboard_flow_box);
            clear_flow_box (genre_flow_box);
            clear_flow_box (mood_flow_box);
            clear_flow_box (activity_flow_box);
            clear_flow_box (epoch_flow_box);
            clear_flow_box (other_flow_box);

            foreach (var station in dashboard.stations) {
                dashboard_flow_box.append (new ActionCardStation (station.station));

                Idle.add (set_values_async.callback);
                yield;
            }

            foreach (var station in stations_list) {
                Gtk.FlowBox target_flow_box;

                switch (station.station.id.type_) {
                    case "micro-genre":
                    case "genre":
                        target_flow_box = genre_flow_box;
                        break;
                    case "mood":
                        target_flow_box = mood_flow_box;
                        break;
                    case "activity":
                        target_flow_box = activity_flow_box;
                        break;
                    case "epoch":
                        target_flow_box = epoch_flow_box;
                        break;
                    default:
                        target_flow_box = other_flow_box;
                        break;
                }

                var action_card = new ActionCardStation (station.station);

                application.main_window.bind_property ("is-shrinked", action_card, "is-shrinked", BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE);

                target_flow_box.append (action_card);

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

                Idle.add (try_load_from_web.callback);
            });

            yield;

            if (dashboard != null && stations_list != null) {
                set_values_async.begin (dashboard, stations_list);

                return -1;
            }

            return 0;
        }

        public async override bool try_load_from_cache () {
            return false;
        }
    }
}
