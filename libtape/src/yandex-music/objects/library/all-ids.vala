/*
 * Copyright (C) 2024 Vladimir Romanov
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

using Gee;
using Deser;

public class Tape.YaMAPI.Library.AllIds : Deser.DataObject {

    public GLib.HashTable<string, int> default_library {
        get; set;
        default = new GLib.HashTable<string, int> (str_hash, str_equal);
    }

    public GLib.HashTable<string, int> artists {
        get; set;
        default = new GLib.HashTable<string, int> (str_hash, str_equal);
    }

    public GLib.HashTable<string, int> albums {
        get; set;
        default = new GLib.HashTable<string, int> (str_hash, str_equal);
    }

    public GLib.HashTable<string, int> playlists {
        get; set;
        default = new GLib.HashTable<string, int> (str_hash, str_equal);
    }

    public GLib.HashTable<string, int> users {
        get; set;
        default = new GLib.HashTable<string, int> (str_hash, str_equal);
    }

    public GLib.HashTable<string, int> genres {
        get; set;
        default = new GLib.HashTable<string, int> (str_hash, str_equal);
    }

    public GLib.HashTable<string, int> labels {
        get; set;
        default = new GLib.HashTable<string, int> (str_hash, str_equal);
    }

    public GLib.HashTable<string, int> library {
        get; set;
        default = new GLib.HashTable<string, int> (str_hash, str_equal);
    }

    public override Deser.ValueCodec get_property_codec (GLib.ParamSpec property) throws Deser.Error {
        if (property.name == "default-library") return Deser.create_codec_for_map<int> ();
        if (property.name == "artists") return Deser.create_codec_for_map<int> ();
        if (property.name == "albums") return Deser.create_codec_for_map<int> ();
        if (property.name == "playlists") return Deser.create_codec_for_map<int> ();
        if (property.name == "users") return Deser.create_codec_for_map<int> ();
        if (property.name == "genres") return Deser.create_codec_for_map<int> ();
        if (property.name == "labels") return Deser.create_codec_for_map<int> ();
        if (property.name == "library") return Deser.create_codec_for_map<int> ();
        return base.get_property_codec (property);
    }
}
