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

namespace Cassette.Client.YaMAPI {
    public class Context : YaMObject {

        public string? id { get; set; default = null; }
        public string? type_ { get; set; default = null; }
        public string? description { get; set; default = null; }

        public Context () {
            Object ();
        }

        public Context.various () {
            Object (type_: "various");
        }

        public static Context from_obj (HasID yam_obj) {
            var context = new Context ();

            if (yam_obj is Playlist) {
                if (((Playlist) yam_obj).kind == "3") {
                    context.type_ = "my_music";
                    return context;
                }
                context.type_ = "playlist";
                context.description = ((Playlist) yam_obj).title;
            } else if (yam_obj is Album) {
                context.type_ = "album";
                context.description = ((Album) yam_obj).title;
            } else if (yam_obj is Artist) {
                context.type_ = "artist";
                context.description = ((Artist) yam_obj).name;
            } else if (yam_obj is int) {
                context.type_ = "search";
            } else {
                context.type_ = "various";
            }
            context.id = yam_obj.oid;

            return context;
        }
    }
}
