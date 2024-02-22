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
 * You should have received a copy of the GNU Geneqral Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */

using Gee;

namespace CassetteClient.YaMAPI {

    public class AccountInfo : YaMObject, HasID, HasCover {

        public string oid {
            owned get {
                return account.uid;
            }
        }

        public AccountStatus account { get; set; default = new AccountStatus (); }
        public Permissions permissions { get; set; }
        public bool subeditor { get; set; }
        public int subeditor_level { get; set; }
        public bool pretrial_active { get; set; }
        public Plus plus { get; set; default = new Plus (); }
        public ArrayList<string> has_options { get; set; default = new ArrayList<string> (); }
        public string? default_email { get; set; }
        public int skips_per_hours { get; set; }
        public bool station_exists { get; set; }
        public Rotor.StationData? station_data { get; set; }
        public Alert? bar_below { get; set; }
        public AvatarInfo avatar_info { get; set; }

        public AccountInfo () {
            Object ();
        }

        public Gee.ArrayList<string> get_cover_items_by_size (int size) {
            var uris = new Gee.ArrayList<string> ();

            string avatar_uri = avatar_info.get_avatar_uri (size);
            if (avatar_info != null) {
                uris.add (avatar_uri);
            }

            return uris;
        }
    }
}
