/* queue.vala
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

namespace CassetteClient.YaMAPI {
    public class Queue : YaMObject {

        public string id { get; set; }
        public Context context { get; set; }
        public ArrayList<Track> tracks { get; set; default = new ArrayList<Track> (); }
        public int current_index { get; set; }
        public string? modified { get; set; }

        public Queue () {
            Object ();
        }

        public void randomize_index () {
            current_index = Random.int_range (0, tracks.size);
        }

        public Bytes to_json () {
            var builder = new Json.Builder ();
            builder.begin_object ();

            builder.set_member_name ("context");
            builder.begin_object ();
                builder.set_member_name ("description");
                if (context.description == null) {
                    builder.add_null_value ();
                } else {
                    builder.add_string_value (context.description);
                }

                builder.set_member_name ("id");
                builder.add_string_value (context.id);

                builder.set_member_name ("type");
                builder.add_string_value (context.type_);
            builder.end_object ();

            builder.set_member_name ("tracks");
            builder.begin_array ();
            foreach (var track_info in tracks) {
                builder.begin_object ();
                builder.set_member_name ("trackId");
                builder.add_string_value (track_info.id);

                builder.set_member_name ("albumId");
                string album_id = track_info.albums.size != 0 ? track_info.albums[0].id : null;
                if (album_id == null) {
                    builder.add_null_value ();
                } else {
                    builder.add_string_value (album_id);
                }

                builder.set_member_name ("from");
                builder.add_string_value (@"desktop_win-own_$(context.type_)-track-default");
                builder.end_object ();
            }
            builder.end_array ();

            builder.set_member_name ("currentIndex");
            builder.add_int_value (current_index);

            builder.set_member_name ("from");
            builder.add_null_value ();

            builder.set_member_name ("isInteractive");
            builder.add_boolean_value (true);
            builder.end_object ();

            var generator = new Json.Generator ();
            generator.set_root (builder.get_root ());

            return new Bytes (generator.to_data (null).data);
        }
    }
}
