/* Copyright 2023-2024 Rirusha
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
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace CassetteClient {

    public delegate void ObjectChangedFunc (YaMObject yam_obj);

    public interface HasID : YaMObject {
        public abstract string? oid { owned get; }
    }

    public interface HasCover : YaMObject {
        public abstract Gee.ArrayList<string> get_cover_items_by_size (int size);
    }

    public interface HasTrackList : YaMObject, HasID {
        public abstract Gee.ArrayList<YaMAPI.Track> get_filtered_track_list (bool show_explicit, bool show_child, string? exception_track_id = null);
    }

    // Класс, от которого наследуются все ямобъекты. Функционал на будущее
    public abstract class YaMObject : Object { }
}
