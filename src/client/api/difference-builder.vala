/* Copyright 2023-2024 Vladimir Vaskov
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
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Gee;

namespace Cassette.Client.YaMAPI {

    public class InsertOperation: Object {

        public int at { get; construct; }
        public ArrayList<Track> tracks { get; set; }

        public InsertOperation (int at, Track[] tracks) {
            Object (at: at);
            this.tracks = new ArrayList<Track>.wrap (tracks);
        }
    }

    public class DeleteOperation: Object {

        public int from { get; construct; }
        public int to { get; construct; }

        public DeleteOperation (int from, int to) {
            Object (from: from, to: to);
        }
    }

    public class DifferenceBuilder : Object {

        ArrayList<DeleteOperation> delete_operations = new ArrayList<DeleteOperation> ();
        ArrayList<InsertOperation> insert_operations = new ArrayList<InsertOperation> ();

        public DifferenceBuilder () {
            Object ();
        }

        public void add_insert (int at, Track[] tracks) {
            insert_operations.add (new InsertOperation (at, tracks));
        }

        public void add_delete (int from, int to) {
            delete_operations.add (new DeleteOperation (from, to));
        }

        public string to_json () {
            var builder = new Json.Builder ();
            builder.begin_array ();

            foreach (var insert_operation in insert_operations) {
                builder.begin_object ();
                builder.set_member_name ("op");
                builder.add_string_value ("insert");

                builder.set_member_name ("at");
                builder.add_int_value (insert_operation.at);

                builder.set_member_name ("tracks");
                builder.begin_array ();
                foreach (var track_info in insert_operation.tracks) {
                    builder.begin_object ();
                    builder.set_member_name ("id");
                    builder.add_string_value (track_info.id);

                    if (track_info.albums.size != 0) {
                        builder.set_member_name ("albumId");
                        builder.add_string_value (track_info.albums[0].id);
                    }
                    builder.end_object ();
                }
                builder.end_array ();
                builder.end_object ();
            }

            foreach (var delete_operation in delete_operations) {
                builder.begin_object ();
                builder.set_member_name ("op");
                builder.add_string_value ("delete");

                builder.set_member_name ("from");
                builder.add_int_value (delete_operation.from);

                builder.set_member_name ("to");
                builder.add_int_value (delete_operation.to);
                builder.end_object ();
            }

            builder.end_array ();

            var generator = new Json.Generator ();
            generator.set_root (builder.get_root ());

            return generator.to_data (null);
        }
    }
}
