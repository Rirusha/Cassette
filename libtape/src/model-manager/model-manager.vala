/*
 * Copyright (C) 2026 Vladimir Romanov
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

[SingleInstance]
internal sealed class Tape.ModelManager : Object {

    HashTable<string, ulong> lists_refs = new HashTable<string, ulong> (str_hash, str_equal);
    HashTable<string, ulong> objects_refs = new HashTable<string, ulong> (str_hash, str_equal);

    HashTable<string, ListModel> lists = new HashTable<string, ListModel> (str_hash, str_equal);
    HashTable<string, Object> objects = new HashTable<string, Object> (str_hash, str_equal);

    public void unref_list (string id) {
        if (!lists_refs.contains (id)) {
            critical ("No content to unref for id %s", id);
            return;
        }

        ulong new_val = lists_refs.get (id) - 1;
        if (new_val == 0) {
            lists_refs.remove (id);
        } else {
            lists_refs.set (id, new_val);
        }
    }

    public void unref_content (string id, Type _type) {
        var content_id = get_content_id (id, _type);

        if (!objects_refs.contains (content_id)) {
            critical ("No content to unref for id %s", content_id);
            return;
        }

        ulong new_val = objects_refs.get (content_id) - 1;
        if (new_val == 0) {
            objects_refs.remove (content_id);
        } else {
            objects_refs.set (content_id, new_val);
        }
    }

    static string get_content_id (string id, Type _type) {
        return @"$(_type.name ()):$id";
    }
}
