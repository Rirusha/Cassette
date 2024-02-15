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

namespace CassetteClient.YaMAPI {
    public class Alert : YaMObject {

        public string alert_id { get; set; }
        public string text { get; set; }
        public string bg_color { get; set; }
        public string text_color { get; set; }
        public string alert_type { get; set; }
        public AlertButton button { get; set; }
        public bool close_button { get; set; }
    }
}
