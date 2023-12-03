/* login_info.vala
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
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Gee;

namespace CassetteClient.YaMAuth {
    public class LoginInfo : YaMObject {

        public string status { get; set; }
        public bool use_new_suggest_by_phone { get; set; }
        public int primary_alias_type { get; set; }
        public string? csrf_token { get; set; }
        public string track_id { get; set; }
        public string? account_type { get; set; }
        public bool can_register { get; set; }
        public bool can_authorize { get; set; }
        public ArrayList<string>? auth_methods { get; set; default = new Gee.ArrayList<string> (); }
        public ArrayList<string>? allowed_account_types { get; set; default = new Gee.ArrayList<string> (); }
        public string preferred_auth_method { get; set; }
        public string? login { get; set; }
        public string? phone_number { get; set; }
        public string? country { get; set; }
        public bool is_rfc_2fa_enabled { get; set; }

        public LoginInfo () {
            Object ();
        }
    }
}