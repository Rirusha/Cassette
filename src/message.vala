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

public sealed class Cassette.Message : Object {

    public string message { get; set; default = ""; }

    public string? warn_body { get; set; default = null; }

    public Message (string message, string? warn_body = null) {
        Object (message: message, warn_body: warn_body);
    }

    public static Variant build_variant (string message, string? warn_body = null) {
        string[] arr;

        if (warn_body == null) {
            arr = { message };
        } else {
            arr = { message, warn_body };
        }

        return new Variant.strv (arr);
    }

    public static Message from_variant (Variant variant) {
        var arr = variant.get_strv ();

        assert (1 <= arr.length <= 2);

        return new Message (arr[0], arr.length == 2 ? arr[1] : null);
    }

    public Variant to_variant () {
        string[] arr;

        if (warn_body == null) {
            arr = { message };
        } else {
            arr = { message, warn_body };
        }

        return new Variant.strv (arr);
    }
}
