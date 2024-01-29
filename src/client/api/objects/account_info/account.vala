/* account.vala
 *
 * Copyright 2023-2024 Rirusha
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

namespace CassetteClient.YaMAPI {
    public class Account : YaMObject {

        public string uid { get; set; }
        public string? login { get; set; }
        public int region { get; set; }
        public string? full_name { get; set; }
        public string? second_name { get; set; }
        public string? first_name { get; set; }
        public string? display_name { get; set; }
        public string? birthday { get; set; }
        public bool service_available { get; set; }
        public ArrayList<PassportPhone> passport_phones { get; set; default = new ArrayList<PassportPhone> (); }
        public bool child { get; set; }

        public Account () {
            Object ();
        }

        public string get_user_name () {
            if (display_name != null) {
                return display_name;
            }
            return full_name;
        }
    }
}
