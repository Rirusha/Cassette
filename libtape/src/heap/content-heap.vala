/*
 * Copyright (C) 2023-2026 Vladimir Romanov
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

public class Tape.Content : Object {

    public string id { get; set; }

    internal ContentHeap heap { get; set; }

    public Content (string id) {
        Object (id: id);
    }

    public override void dispose () {
        base.dispose ();
        heap.unref_return (id);
    }
}

internal abstract class Tape.ContentHeap : Object {

    HashTable<string, unowned Content> store = new HashTable<string, unowned Content> (GLib.str_hash, GLib.str_equal);

    public async Content? get_content (string id) {
        Content content;

        if (id in store) {
            return store[id];
        }

        content = yield get_local_content (id);
        if (check_fresh_content_id (id, content)) {
            bind_content (content);
            return content;
        }

        content = yield get_remote_content (id);
        if (check_fresh_content_id (id, content)) {
            bind_content (content);
            return content;
        }

        return null;
    }

    protected abstract async Content? get_remote_content (string id);

    protected abstract async Content? get_local_content (string id);

    void bind_content (Content content) {
        store[content.id] = content;
        content.heap = this;
    }

    bool check_fresh_content_id (string id, Content? content) {
        if (content != null) {
            if (content.id != id) {
                warning ("Content id mismatch. Type: %s", content.get_type ().name ());
                return false;
            }
            return true;
        }
        return false;
    }

    internal void unref_return (string id) {
        store.remove (id);
    }
}
