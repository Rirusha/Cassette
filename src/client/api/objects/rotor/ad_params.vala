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


namespace Cassette.Client.YaMAPI.Rotor {
    public class AdParams : YaMObject {

        public string partner_id { get; set; }
        public string category_id { get; set; }
        public string page_ref { get; set; }
        public string target_reg { get; set; }
        public string other_params { get; set; }
        public int ad_volume { get; set; }
        public string genre_id { get; set; }
        public string genre_name { get; set; }
    }
}
