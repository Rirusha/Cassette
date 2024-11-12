/* Copyright 2023-2024 Vladimir Vaskov
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
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Cassette.Client {

    public delegate void ObjectChangedFunc (YaMObject yam_obj);

    /**
     * Интерфейс объектов, имеющих уникальный идентификатор.
     * Существует, так как, например
     * ``Cassette.Client.YaMAPI.Playlist`` имеют составной id, разделенный
     * на свойства uid и kind
     */
    public interface HasID : YaMObject {
        /**
         * Уникальный идентификатор объекта
         */
        public abstract string oid { owned get; }
    }

    /**
     * Интерфейс объектов, имеющих обложку.
     */
    public interface HasCover : YaMObject {
        /**
         * Получение списка изображений, которые входят в обложку.
         *  
         * @param size размер изображений в частности
         *
         * @return     список изображений, которые входят в обложку    
         */
        public abstract Gee.ArrayList<string> get_cover_items_by_size (int size);
    }

    /**
     * Интерфейс объектов, имеющих список треков.
     */
    public interface HasTrackList : YaMObject, HasID {
        /**
         * Получение отфильтрованного по переданным параметрам списка треков.
         * Функция также не включает в список недоступные треки. 
         *  
         * @param show_explicit         включать треки, непредназначенные для несовершеннолетних
         * @param show_child            включать детские треки
         * @param exception_track_id    id трека, на который фильтрация работать не будет.
         *                              Нужно в случае включения трека из результатов поиска внутри списка треков,
         *                              который не виден пользоваетлю вне поиска.
         *
         * @return                      отфильтрованный список треков
         */
        public abstract Gee.ArrayList<YaMAPI.Track> get_filtered_track_list (
            bool show_explicit,
            bool show_child,
            string? exception_track_id = null
        );
    }

    /**
     * Абстрактный класс, от которого наследуются все ямобъекты.
     * Функционал на будущее
     */
    public abstract class YaMObject : Object { }
}
