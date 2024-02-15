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

namespace CassetteClient.YaMAPI {
    public class ApiError : YaMObject {

        public string msg {
            owned get {
                if (error_description != null) {
                    return @"$status_code: $error, $error_description";
                }
                if (name != null) {
                    return @"$status_code: $name, $message";
                }

                return @"$status_code: $error";
            }
        }

        public uint status_code { get; set; }
        public string error { get; set; default = "unknown error"; }
        public string error_description { get; set; default = null; }
        public string name { get; set; default = null; }
        public string message { get; set; default = ""; }

        public ApiError () {
            Object ();
        }
    }
}
