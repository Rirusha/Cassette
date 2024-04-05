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


[GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/devel_view.ui")]
public class Cassette.DevelView : BaseView {

    [GtkChild]
    unowned Gtk.Button ultra_button;

    public override bool can_refresh { get; default = false; }

    construct {
        ultra_button.clicked.connect (on_ultra_button_clicked);
    }

    void on_ultra_button_clicked () {
        //  var client = yam_talker.client;

        //  var a = client.get_rotor_info (Cassette.Client.YaMAPI.Rotor.StationType.ON_YOUR_WAVE);
        //  client.rotor_feedback_started (Cassette.Client.YaMAPI.Rotor.StationType.ON_YOUR_WAVE);
        //  var tra = client.get_station_tracks (Cassette.Client.YaMAPI.Rotor.StationType.ON_YOUR_WAVE);

        //  var n = client.get_rotor_dashboard ();
        //  foreach (var m in n.stations) {
        //      message (m.station.name);
        //  }

        //  var c =client.get_station_list ();
        //  foreach (var k in c) {
        //      message (k.station.name);
        //  }

        //  var tra = client.get_tracks ({"102553949", "111654151", "54261186"});

        //  foreach (var seq in tra) {
        //      message (seq.title);
        //  }

        //  var lib = client.library_all_ids ();

        //  message (lib.liked_tracks[0]);
        //  message (lib.playlists[0]);

        //  Client.Logger.debug ("MARK I");
        //  client.playlist ("ps.ee2906f8-9350-46a3-88ce-3f98fd09514d", false, false);
        //  Client.Logger.debug ("MARK II");
        //  client.playlist ("ps.ee2906f8-9350-46a3-88ce-3f98fd09514d", false, true);

        root_view.add_view (new StationsView ());

        message ("Magic happaned, i swear…");
    }

    void set_values () {
        show_ready ();
    }

    public async override void first_show () {
        set_values ();
    }

    public async override bool try_load_from_cache () {
        return true;
    }

    public async override int try_load_from_web () {
        return -1;
    }

    public async override void refresh () {

    }
}
