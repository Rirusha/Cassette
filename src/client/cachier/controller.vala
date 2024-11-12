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

using Gee;

namespace Cassette.Client.Cachier {
    public enum ContentType {
        TRACK,
        PLAYLIST,
        ALBUM,
        IMAGE
    }

    public enum CacheingState {
        NONE,
        LOADING,
        TEMP,
        PERM
    }

  class ContentInfo : Object {
        public ContentType content_type { get; construct; }
        public string content_id { get; construct; }

        public ContentInfo (ContentType content_type, string content_id) {
            Object (content_type: content_type, content_id: content_id);
        }
    }

    // Контроллер состояния кэширования треков. Все отображалки состояния привязаны к этому контроллеру
    public class Controller : Object {
        ArrayList<ContentInfo?> loading_content = new ArrayList<ContentInfo?> ();

        public signal void content_cache_state_changed (
            ContentType content_type,
            string content_id,
            CacheingState state);

        ContentInfo? find_content_info (ContentInfo content_info) {
            /**
                Поиск информации о контенте в списке сохраняемого. Возвращает null, если не найдено

                content_info: информация о контенте
            */

            lock (loading_content) {
                foreach (var ci in loading_content) {
                    if (content_info.content_id == ci.content_id && content_info.content_type == ci.content_type) {
                        return ci;
                    }
                }

                return null;
            }
        }

        void add_content_info (ContentInfo content_info) {
            /**
                Добавить информацию о контенте в список сохраняемого

                content_info: информация о контенте
            */

            lock (loading_content) {
                if (find_content_info (content_info) == null) {
                    loading_content.add (content_info);
                }
            }
        }

        void remove_content_info (ContentInfo content_info) {
            /**
                Удалить информацию о контенте в список сохраняемого

                content_info: информация о контенте
            */

            lock (loading_content) {
                var ci = find_content_info (content_info);
                if (ci != null) {
                    loading_content.remove (ci);
                }
            }
        }

        public void change_state (ContentType content_type, string content_id, CacheingState state) {
            /**
                Изменить состояние контента

                content_type: тип контента
                content_id: id контента
                content_info: информация о контенте
            */

            if (state != CacheingState.LOADING) {
                remove_content_info (new ContentInfo (content_type, content_id));
            }

            content_cache_state_changed (content_type, content_id, state);
        }

        public void start_loading (ContentType content_type, string content_id) {
            /**
                Пометить контент как то, что начало загружаться

                content_type: тип контента
                content_id: id контента
            */

            add_content_info (new ContentInfo (content_type, content_id));

            content_cache_state_changed (content_type, content_id, CacheingState.LOADING);
        }

        public void stop_loading (ContentType content_type, string content_id, CacheingState? state) {
            /**
                Пометить контент как то, что закончило загрузку

                content_type: тип контента
                content_id: id контента
                content_info: информация о контенте. Если null, то текущее состояние будет 
                    определено самостоятельно
            */

            remove_content_info (new ContentInfo (content_type, content_id));

            content_cache_state_changed (
                content_type, content_id, state != null? state : get_content_cache_state (content_type, content_id));
        }

        public CacheingState get_content_cache_state (ContentType content_type, string content_id) {
            /**
                Получить состояние сохранения по типу контента и его id

                content_type: тип контента
                content_id: id контента
            */

            if (find_content_info (new ContentInfo (content_type, content_id)) != null) {
                return CacheingState.LOADING;
            }

            Location location;
            switch (content_type) {
                case ContentType.TRACK:
                    location = storager.audio_cache_location (content_id);
                    break;
                case ContentType.PLAYLIST:
                    location = storager.object_cache_location (typeof (YaMAPI.Playlist), content_id);
                    break;
                case ContentType.ALBUM:
                    location = storager.object_cache_location (typeof (YaMAPI.Album), content_id);
                    break;
                default:
                    assert_not_reached ();
            }

            if (location.file != null && location.is_tmp == true) {
                return CacheingState.TEMP;
            }

            if (location.is_tmp == false) {
                return CacheingState.PERM;
            }

            return CacheingState.NONE;
        }
    }
}
