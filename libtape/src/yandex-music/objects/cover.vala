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

public class Tape.YaMAPICover : Deser.DataObject {

    public GLib.GenericArray<string> uris {
        owned get {
            if (uri != null) {
                var result = new GLib.GenericArray<string> ();
                result.add (uri);
                return result;
            } else {
                return items_uri;
            }
        }
    }

    [Description (nick = "type")]
    public string? type_ { get; set; }

    public GLib.GenericArray<string> items_uri { get; set; default = new GLib.GenericArray<string> (); }

    public string? uri { get; set; default = null; }

    public string? version { get; set; }

    public bool custom { get; set; }

    public YaMAPICover () {
        Object ();
    }

    public YaMAPICover.liked () {
        Object (uri: "music.yandex.ru/blocks/playlist-cover/playlist-cover_like.png");
    }

    public YaMAPICover.empty () {
        Object (uri: "music.yandex.ru/blocks/playlist-cover/playlist-cover_no_cover0.png");
    }

    public override Deser.ValueCodec get_property_codec (GLib.ParamSpec property) throws Deser.Error {
        if (property.name == "items-uri") return Deser.create_codec_for_array<string> ();
        return base.get_property_codec (property);
    }
}
