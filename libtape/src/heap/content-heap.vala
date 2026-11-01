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

public abstract class Tape.Content : Deser.DataObject {

    public abstract string content_id {
        owned get;
    }

    ContentHeap heap;

    internal void bind_heap (ContentHeap heap) {
        this.heap = heap;
    }

    internal void update_by (Content another_content) {
        assert (get_type () == another_content.get_type ());

        freeze_notify ();
        foreach (var prop in another_content.get_class ().list_properties ()) {
            var val = Value (prop.value_type);
            another_content.get_property (prop.name, ref val);
            set_property (prop.name, val);
        }
        thaw_notify ();
    }

    public override void dispose () {
        base.dispose ();
        if (heap != null) {
            heap.unref_return (content_id);
        }
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
        if (check_content_id (id, content)) {
            bind_content (content);
            return content;
        }

        content = yield get_remote_content (id);
        if (check_content_id (id, content)) {
            bind_content (content);
            return content;
        }

        return null;
    }

    protected abstract async Content? get_remote_content (string id);

    protected abstract async Content? get_local_content (string id);

    void bind_content (Content content) {
        store[content.content_id] = content;
        content.bind_heap (this);
    }

    bool check_content_id (string id, Content? content) {
        if (content != null) {
            if (content.content_id != id) {
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
