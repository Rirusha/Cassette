/*
 * Copyright (C) 2024-2026 Vladimir Romanov <rirusha@altlinux.org>
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

[SingleInstance]
public sealed class Tape.CacheManager : Object {

    public Storager storager { get; default = new Storager (); }

    public async Bytes? load_image_by_uri (
        string uri,
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) {
        var image = yield storager.load_image (uri);

        if (image == null) {
            try {
                if (root.network_available) {
                    image = yield root.ym.client.get_content_of (uri, priority, cancellable);
                } else {
                    return image;
                }
            } catch (Error e) {
                warning ("Can't load image by uri '%s': %s", uri, e.message);
            }
        }

        if (image != null && root.settings.can_cache) {
            yield storager.save_image (image, uri, true);
        }

        return image;
    }

    internal async void white_list () {
        yield storager.remove_dir_file (storager.datadir_file);
        yield storager.remove_dir_file (storager.cachedir_file);
    }
}
