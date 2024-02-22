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


using Gee;

namespace CassetteClient.YaMAPI.Rotor {

    public class Wave : YaMObject {

        /*
         * TODO
         */
        public string name { get; set; }

        /*
         * TODO
         */
        public string station_id { get; set; }

        /*
         * TODO
         */
        public ArrayList<string> seeds { get; set; default = new ArrayList<string> (); }

        /*
         * TODO
         */
        public string if_for_from { get; set; }
    }
}
