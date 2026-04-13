/*
 * Copyright (C) 2026 Vladimir Romanov <rirusha@altlinux.org>
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

public class Cassette.MenuItem : Buildable {

    public bool needs_attention { get; set; }

    public uint badge_number { get; set; }

    public string? label { get; set; }

    public string? icon_name { get; set; }

    public string action_name { get; set; }

    public Variant? action_target { get; set; }

    Menu _submenu;
    public Menu submenu {
        get {
            return _submenu;
        }
        set {
            _submenu = value;

            if (_submenu != null) {
                _submenu.bind_property ("needs-attention", this, "needs-attention", SYNC_CREATE);
                _submenu.bind_property ("badge-number", this, "badge-number", SYNC_CREATE);
            }
        }
    }

    HashTable<string, Object> customs = new HashTable<string, Object> (str_hash, str_equal);

    public override void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        if (type == null) {
            critical ("When trying to add child to %s child-type must be specified", get_type ().name ());
            return;
        }
        add_custom (type, child);
    }

    public void add_custom (string name, Object custom) {
        customs[name] = custom;
    }

    public void remove_custom_factory (string name) {
        customs.remove (name);
    }

    public unowned Object? get_custom (string name) {
        if (customs.contains (name)) {
            return customs[name];
        }
        return null;
    }
}
