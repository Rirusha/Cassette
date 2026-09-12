/*
 * Copyright (C) 2025 Vladimir Romanov <rirusha@altlinux.org>
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
 * along with this program. If not, see
 * <https://www.gnu.org/licenses/gpl-3.0-standalone.html>.
 * 
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public sealed class Tape.HashModel : Object {

    Gee.HashSet<string> store = new Gee.HashSet<string> ();

    public int size {
        get {
            return store.size;
        }
    }

    public signal void changed ();

    public new void @set (string[] array) {
        store.clear ();
        store.add_all_array (array);
        changed ();
    }

    public void set_iterator (Gee.Iterator<string> iter) {
        store.clear ();
        store.add_all_iterator (iter);
        changed ();
    }

    public void clear () {
        store.clear ();
        changed ();
    }

    public void append (string item) {
        store.add (item);
        changed ();
    }

    public void remove (string item) {
        store.remove (item);
        changed ();
    }

    public bool contains (string needle) {
        return needle in store;
    }
}
