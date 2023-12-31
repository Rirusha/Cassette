/* account_info.vala
 *
 * Copyright 2023 Rirusha
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
 * You should have received a copy of the GNU Geneqral Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Gee;

namespace CassetteClient.YaMAPI {

    public class AccountInfo : YaMObject, HasID, HasCover {

        public string? oid {
            owned get {
                return account.uid;
            }
        }

        public Account account { get; set; default = new Account (); }
        public Permissions permissions { get; set; }
        public bool subeditor { get; set; }
        public int subeditor_level { get; set; }
        public bool pretrial_active { get; set; }
        public MasterHub masterhub { get; set; }
        public Plus plus { get; set; default = new Plus (); }
        public ArrayList<string> has_options { get; set; default = new ArrayList<string> (); }
        public string? default_email { get; set; }
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
