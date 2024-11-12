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


using Cassette.Client.YaMAPI.Rotor;

namespace Cassette.Client.YaMAPI {

    public class YaMClient : Object {

        const string YAM_BASE_URL = "https://api.music.yandex.net";

        public SoupWrapper soup_wrapper { get; construct; }

        public Account.About? me { get; private set; default = null; }

        public bool is_init_complete { get; set; default = false; }

        public YaMClient (SoupWrapper soup_wrapper) {
            Object (soup_wrapper: soup_wrapper);
        }

        construct {
            string os = Environment.get_os_info (OsInfoKey.NAME);
            string version = Environment.get_os_info (OsInfoKey.VERSION);

            soup_wrapper.add_headers_preset (
                "device",
                {{
                    "X-Yandex-Music-Device",
                    "os=%s; os_version=%s; manufacturer=%s; model=%s; clid=; device_id=random; uuid=random".printf (
                        os, version, "Rirusha", "Yandex Music API"
                    )
                }}
            );
        }

        public void init () throws ClientError, BadStatusCodeError {
            var datalist = Datalist<string> ();
            datalist.set_data ("grant_type", "sessionid");
            datalist.set_data ("client_id", "23cabbbdc6cd418abb4b39c32c41195d");
            datalist.set_data ("client_secret", "53bc75238f0c4d08a118e51fe9203300");
            datalist.set_data ("host", "oauth.yandex.ru");

            PostContent post_content = {PostContentType.X_WWW_FORM_URLENCODED};
            post_content.set_datalist (datalist);

            var bytes = soup_wrapper.post_sync (
                "https://oauth.yandex.ru/token",
                null,
                post_content
            );
            var jsoner = Jsoner.from_bytes (bytes, {"access_token"}, Case.SNAKE);

            string token = jsoner.deserialize_value ().get_string ();

            soup_wrapper.add_headers_preset (
                "default",
                {
                    {"Authorization", @"OAuth $token"},
                    {"X-Yandex-Music-Client", "YandexMusicAndroid/24023231"}
                }
            );
            soup_wrapper.add_headers_preset (
                "auth",
                {
                    {"Authorization", @"OAuth $token"}
                }
            );

            me = account_about ();
            is_init_complete = true;
        }

        /**
         * Получит содержимое по url
         *
         * @param url   url, по котором нужно получить контент
         *
         * @return      контент в байтах
         */
        public Bytes get_content_of (string url) throws ClientError, BadStatusCodeError {
            return soup_wrapper.get_sync (url);
        }

        /**
         * Проверить uid пользователя на наличие
         */
        void check_uid (ref string? uid) throws ClientError {
            if (uid == null) {
                if (me == null) {
                    throw new ClientError.AUTH_ERROR ("Auth Error");
                }

                uid = me.uid;
                if (uid == null) {
                    throw new ClientError.AUTH_ERROR ("Auth Error");
                }
            }
        }

        /**
         *
         */
        public void account_experiments () throws ClientError, BadStatusCodeError { }

        /**
         *
         */
        public void account_experiments_details () throws ClientError, BadStatusCodeError { }

        /**
         *
         */
        public void account_settings () throws ClientError, BadStatusCodeError { }

        /**
         * Получение информации о текущем пользователе
         */
        public Account.About account_about () throws ClientError, BadStatusCodeError {
            var bytes = soup_wrapper.get_sync (
                @"$(YAM_BASE_URL)/account/about",
                {"default"}
            );

            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            return (Account.About) jsoner.deserialize_object (typeof (Account.About));
        }

        /**
         *
         */
        public void albums_with_tracks (
            string album_id,
            bool rich_tracks
        ) throws ClientError, BadStatusCodeError { }

        /**
         *
         */
        public Playlist playlist (
            string playlist_uuid,
            bool resume_stream,
            bool rich_tracks
        ) throws ClientError, BadStatusCodeError {
            var bytes = soup_wrapper.get_sync (
                @"$(YAM_BASE_URL)/playlist/$playlist_uuid",
                {"default"},
                {
                    {"resumeStream", resume_stream.to_string ()},
                    {"richTracks", rich_tracks.to_string ()}
                }
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            return (Playlist) jsoner.deserialize_object (typeof (Playlist));
        }

        /**
         *
         */
        public void playlists () throws ClientError, BadStatusCodeError { }

        /**
         *
         */
        public void artists_tracks (
            string artist_id
        ) throws ClientError, BadStatusCodeError { }

        /**
         *
         */
        public void artists_track_ids (
            string artist_id
        ) throws ClientError, BadStatusCodeError { }

        /**
         *
         */
        public void artists_safe_direct_albums (
            string artist_id
        ) throws ClientError, BadStatusCodeError { }

        /**
         *
         */
        public void artists_brief_info (
            string artist_id
        ) throws ClientError, BadStatusCodeError { }

        /**
         *
         */
        public void artists_similar (
            string artist_id
        ) throws ClientError, BadStatusCodeError { }

        /**
         *
         */
        public void artists_discography_albums (
            string artist_id
        ) throws ClientError, BadStatusCodeError { }

        /**
         *
         */
        public void artists_direct_albums (
            string artist_id
        ) throws ClientError, BadStatusCodeError { }

        /**
         *
         */
        public void artists_also_albums (
            string artist_id
        ) throws ClientError, BadStatusCodeError { }

        /**
         *
         */
        public void artists_concerts (
            string artist_id
        ) throws ClientError, BadStatusCodeError { }

        /**
         *
         */
        public void users_playlists_list_kinds (
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /**
         *
         */
        public void users_playlists (
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /**
         *
         */
        public Gee.ArrayList<Playlist> users_playlists_list (
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);

            Bytes bytes = soup_wrapper.get_sync (
                @"$(YAM_BASE_URL)/users/$uid/playlists/list",
                {"default"}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            var playlist_array = new Gee.ArrayList<Playlist> ();
            jsoner.deserialize_array (ref playlist_array);

            return playlist_array;
        }

        /**
         *
         */
        public Playlist users_playlists_playlist (
            string playlist_kind,
            bool rich_tracks,
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);

            var bytes = soup_wrapper.get_sync (
                @"$(YAM_BASE_URL)/users/$uid/playlists/$playlist_kind",
                {"default"},
                {{"richTracks", rich_tracks.to_string ()}}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            return (Playlist) jsoner.deserialize_object (typeof (Playlist));
        }

        /**
         *
         */
        public void users_playlists_playlist_change_relative (
            string playlist_kind,
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        public bool users_playlists_delete (
            owned string? uid,
            string kind
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);

            Bytes bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/users/$uid/playlists/$kind/delete",
                {"default"}
            );

            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);
            if (jsoner.root != null) {
                return true;
            }
            return false;
        }

        public Playlist users_playlists_change (
            owned string? uid,
            string kind,
            string diff,
            int revision = 1
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);

            var datalist = Datalist<string> ();
            datalist.set_data ("kind", kind);
            datalist.set_data ("revision", revision.to_string ());
            datalist.set_data ("diff", diff);

            PostContent post_content = {PostContentType.X_WWW_FORM_URLENCODED};
            post_content.set_datalist (datalist);

            Bytes bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/users/$(uid)/playlists/$kind/change",
                {"default"},
                post_content
            );

            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            return (Playlist) jsoner.deserialize_object (typeof (Playlist));
        }

        public Playlist users_playlists_create (
            owned string? uid,
            string title,
            string visibility = "private"
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);

            var datalist = Datalist<string> ();
            datalist.set_data ("title", title);
            datalist.set_data ("visibility", visibility);

            PostContent post_content = {PostContentType.X_WWW_FORM_URLENCODED};
            post_content.set_datalist (datalist);

            Bytes bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/users/$uid/playlists/create",
                {"default"},
                post_content
            );

            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            return (Playlist) jsoner.deserialize_object (typeof (Playlist));
        }

        public Playlist users_playlists_name (
            owned string? uid,
            string kind,
            string new_name
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);

            var datalist = Datalist<string> ();
            datalist.set_data ("value", new_name);

            PostContent post_content = {PostContentType.X_WWW_FORM_URLENCODED};
            post_content.set_datalist (datalist);

            Bytes bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/users/$uid/playlists/$kind/name",
                {"default"},
                post_content
            );

            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            return (Playlist) jsoner.deserialize_object (typeof (Playlist));
        }

        public PlaylistRecommendations users_playlists_recommendations (
            owned string? uid,
            string kind
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);

            var bytes = soup_wrapper.get_sync (
                @"$(YAM_BASE_URL)/users/$uid/playlists/$kind/recommendations",
                {"default"}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            return (PlaylistRecommendations) jsoner.deserialize_object (typeof (PlaylistRecommendations));
        }

        public Playlist users_playlists_visibility (
            owned string? uid,
            string kind,
            string visibility
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);

            var datalist = Datalist<string> ();
            datalist.set_data ("value", visibility);

            PostContent post_content = {PostContentType.X_WWW_FORM_URLENCODED};
            post_content.set_datalist (datalist);

            Bytes bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/users/$uid/playlists/$kind/visibility",
                {"default"},
                post_content
            );

            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            return (Playlist) jsoner.deserialize_object (typeof (Playlist));
        }

        public Playlist users_palylists_cover_upload (
            owned string? uid,
            string kind,
            uint[] new_cover,
            string filename,
            string content_type
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);

            var post_builder = new StringBuilder ();

            post_builder.append (Uuid.string_random ());
            post_builder.append_printf ("Content-Disposition: form-data; name=\"image\"; filename=\"%s\"\n", filename);
            post_builder.append_printf ("Content-Type: %s\n", content_type);
            post_builder.append_printf ("Content-Length: %d\n", new_cover.length);
            post_builder.append ("\n");
            post_builder.append ((string) new_cover);

            PostContent post_content = {PostContentType.X_WWW_FORM_URLENCODED, post_builder.free_and_steal ()};

            Bytes bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/users/$uid/playlists/$kind/cover/upload",
                {"default"},
                post_content
            );

            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            return (Playlist) jsoner.deserialize_object (typeof (Playlist));
        }

        public Playlist users_palylists_cover_clear (
            owned string? uid,
            string kind,
            uint[] new_cover
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);

            Bytes bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/users/$uid/playlists/$kind/cover/clear",
                {"default"}
            );

            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            return (Playlist) jsoner.deserialize_object (typeof (Playlist));
        }

        /**
         *
         */
        public void users_likes_albums (
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /**
         *
         */
        public void users_likes_artists (
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /**
         *
         */
        public Gee.ArrayList<LikedPlaylist> users_likes_playlists (
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);

            Bytes bytes = soup_wrapper.get_sync (
                @"$(YAM_BASE_URL)/users/$uid/likes/playlists",
                {"default"}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            var playlist_array = new Gee.ArrayList<LikedPlaylist> ();
            jsoner.deserialize_array (ref playlist_array);
            return playlist_array;
        }

        /**
         *
         */
        public int64 users_likes_tracks_add (
            string track_id,
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);

            var bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/users/$uid/likes/tracks/add",
                {"default"},
                null,
                {{"track-id", track_id}}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result", "revision"}, Case.CAMEL);

            var value = jsoner.deserialize_value ();

            if (value.type () == Type.INT64) {
                return value.get_int64 ();
            }
            return 0;
        }

        /**
         *
         */
        public int64 users_likes_tracks_remove (
            string track_id,
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);

            var bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/users/$uid/likes/tracks/$track_id/remove",
                {"default"}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result", "revision"}, Case.CAMEL);

            var value = jsoner.deserialize_value ();

            if (value.type () == Type.INT64) {
                return value.get_int64 ();
            }
            return 0;
        }

        public Gee.ArrayList<TrackShort> users_dislikes_tracks (
            owned string? uid,
            int if_modified_since_revision = 0
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);

            var bytes = soup_wrapper.get_sync (
                @"$(YAM_BASE_URL)/users/$uid/dislikes/tracks",
                {"default"},
                {{"if_modified_since_revision", if_modified_since_revision.to_string ()}}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result", "library", "tracks"}, Case.CAMEL);

            var our_array = new Gee.ArrayList<TrackShort> ();
            jsoner.deserialize_array (ref our_array);

            return our_array;
        }

        /**
         *
         */
        public int64 users_dislikes_tracks_add (
            string track_id,
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);

            var bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/users/$uid/dislikes/tracks/add",
                {"default"},
                null,
                {{"track-id", track_id}}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result", "revision"}, Case.CAMEL);

            var value = jsoner.deserialize_value ();

            if (value.type () == Type.INT64) {
                return value.get_int64 ();
            }
            return 0;
        }

        /**
         *
         */
        public int64 users_dislikes_tracks_remove (
            string track_id,
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);

            var bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/users/$uid/dislikes/tracks/$track_id/remove",
                {"default"}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result", "revision"}, Case.CAMEL);

            var value = jsoner.deserialize_value ();

            if (value.type () == Type.INT64) {
                return value.get_int64 ();
            }
            return 0;
        }

        /**
         *
         */
        public bool users_likes_artists_add (
            string artist_id,
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);

            var bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/users/$uid/likes/artists/add",
                {"default"},
                null,
                {{"artist-id", artist_id}}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            var value = jsoner.deserialize_value ();

            if (value.type () == Type.STRING) {
                return value.get_string () == "ok";
            }
            return false;
        }

        /**
         *
         */
        public bool users_likes_artists_remove (
            string artist_id,
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);

            var bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/users/$uid/likes/artists/$artist_id/remove",
                {"default"}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            var value = jsoner.deserialize_value ();

            if (value.type () == Type.STRING) {
                return value.get_string () == "ok";
            }
            return false;
        }

        /**
         *
         */
        public bool users_dislikes_artists_add (
            string artist_id,
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);

            var bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/users/$uid/dislikes/artists/add",
                {"default"},
                null,
                {{"artist-id", artist_id}}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            var value = jsoner.deserialize_value ();

            if (value.type () == Type.STRING) {
                return value.get_string () == "ok";
            }
            return false;
        }

        /**
         *
         */
        public bool users_dislikes_artists_remove (
            string artist_id,
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);

            var bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/users/$uid/dislikes/artists/$artist_id/remove",
                {"default"}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            var value = jsoner.deserialize_value ();

            if (value.type () == Type.STRING) {
                return value.get_string () == "ok";
            }
            return false;
        }

        /**
         *
         */
        public bool users_likes_albums_add (
            string album_id,
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);

            var bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/users/$uid/likes/albums/add",
                {"default"},
                null,
                {{"album-id", album_id}}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            var value = jsoner.deserialize_value ();

            if (value.type () == Type.STRING) {
                return value.get_string () == "ok";
            }
            return false;
        }

        /**
         *
         */
        public bool users_likes_albums_remove (
            string album_id,
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);

            var bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/users/$uid/likes/albums/$album_id/remove",
                {"default"}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            var value = jsoner.deserialize_value ();

            if (value.type () == Type.STRING) {
                return value.get_string () == "ok";
            }
            return false;
        }

        /**
         *
         */
        public bool users_likes_playlists_add (
            string playlist_uid,
            string owner_uid,
            string playlist_kind,
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);

            var bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/users/$uid/likes/playlists/add",
                {"default"},
                null,
                {
                    {"playlist-uuid", playlist_uid},
                    {"owner-uid", owner_uid},
                    {"kind", playlist_kind}
                }
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            var value = jsoner.deserialize_value ();

            if (value.type () == Type.STRING) {
                return value.get_string () == "ok";
            }
            return false;
        }

        /**
         *
         */
        public bool users_likes_playlists_remove (
            string playlist_uid,
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);

            var bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/users/$uid/likes/playlists/$playlist_uid/remove",
                {"default"}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            var value = jsoner.deserialize_value ();

            if (value.type () == Type.STRING) {
                return value.get_string () == "ok";
            }
            return false;
        }

        /**
         *
         */
        public void users_presaves_add (
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /**
         *
         */
        public void users_presaves_remove (
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /**
         *
         */
        public void users_search_history (
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /**
         *
         */
        public void users_search_history_clear (
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /**
         * Получение данных о библиотеке пользователя
         */
        public Library.AllIds library_all_ids () throws ClientError, BadStatusCodeError {
            var bytes = soup_wrapper.get_sync (
                @"$(YAM_BASE_URL)/library/all-ids",
                {"default"}
            );

            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            return jsoner.deserialize_lib_data ();
        }

        /**
         *
         */
        public void landing3_metatags () throws ClientError, BadStatusCodeError { }

        /**
         *
         */
        public void metatags_metatag (
            string metatag
        ) throws ClientError, BadStatusCodeError { }

        /**
         *
         */
        public void metatags_albums (
            string metatag
        ) throws ClientError, BadStatusCodeError { }

        /**
         *
         */
        public void metatags_artists (
            string metatag
        ) throws ClientError, BadStatusCodeError { }

        /**
         *
         */
        public void metatags_playlists (
            string metatag
        ) throws ClientError, BadStatusCodeError { }

        /**
         *
         */
        public void top_category (
            string category
        ) throws ClientError, BadStatusCodeError { }

        /**
         *
         */
        public void rotor_station_info (
            string station_id
        ) throws ClientError, BadStatusCodeError { }

        /**
         *
         */
        public void rotor_station_stream () throws ClientError, BadStatusCodeError { }

        /**
         *
         */
        public StationTracks rotor_session_new (
            SessionNew session_new
        ) throws ClientError, BadStatusCodeError {
            PostContent post_content = {
                PostContentType.JSON,
                Jsoner.serialize (session_new, Case.CAMEL)
            };

            Bytes bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/rotor/session/new",
                {"default"},
                post_content
            );

            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            return (StationTracks) jsoner.deserialize_object (typeof (StationTracks));
        }

        /**
         *
         */
        public StationTracks rotor_session_tracks (
            string radio_session_id,
            Rotor.Queue queue
        ) throws ClientError, BadStatusCodeError {
            PostContent post_content = {
                PostContentType.JSON,
                Jsoner.serialize (queue, Case.CAMEL)
            };

            Bytes bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/rotor/session/$radio_session_id/tracks",
                {"default"},
                post_content
            );

            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            return (StationTracks) jsoner.deserialize_object (typeof (StationTracks));
        }

        /**
         *
         */
        public void rotor_session_feedback (
            string radio_session_id,
            Rotor.Feedback feedback
        ) throws ClientError, BadStatusCodeError {
            PostContent post_content = {
                PostContentType.JSON,
                Jsoner.serialize (feedback, Case.CAMEL)
            };

            soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/rotor/session/$radio_session_id/feedback",
                {"default"},
                post_content
            );
        }

        /**
         * Метод для получения всех возможных настроек волны
         *
         * @return  объект ``Cassette.Client.YaMAPI.Rotor.Settings``, содержащий все настройки
         */
        public Rotor.Settings rotor_wave_settings () throws ClientError, BadStatusCodeError {
            var bytes = soup_wrapper.get_sync (
                @"$(YAM_BASE_URL)/rotor/wave/settings",
                {"default"},
                {{"language", get_language ()}}
            );

            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            return (Rotor.Settings) jsoner.deserialize_object (typeof (Rotor.Settings));
        }

        /**
         * Получение последней прослушиваемой волны текущим пользователем
         */
        public Rotor.Wave rotor_wave_last () throws ClientError, BadStatusCodeError {
            var bytes = soup_wrapper.get_sync (
                @"$(YAM_BASE_URL)/rotor/wave/last",
                {"default"},
                {{"language", get_language ()}}
            );

            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            return (Wave) jsoner.deserialize_object (typeof (Wave));
        }

        /**
         * Сбросить значение последней прослушиваемой станции.
         *
         * @return  успех выполнения
         */
        public bool rotor_wave_last_reset () throws ClientError, BadStatusCodeError {
            var bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/rotor/wave/last/reset",
                {"default"}
            );

            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            if (jsoner.root == null) {
                return false;
            }

            return jsoner.deserialize_value ().get_string () == "ok";
        }

        public Dashboard rotor_stations_dashboard () throws ClientError, BadStatusCodeError {
            var bytes = soup_wrapper.get_sync (
                @"$(YAM_BASE_URL)/rotor/stations/dashboard",
                {"default", "device"},
                {{"language", get_language ()}}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            return (Dashboard) jsoner.deserialize_object (typeof (Dashboard));
        }

        public Gee.ArrayList<Station> rotor_stations_list () throws ClientError, BadStatusCodeError {
            var bytes = soup_wrapper.get_sync (
                @"$(YAM_BASE_URL)/rotor/stations/list",
                {"default", "device"},
                {{"language", get_language ()}}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            var sl_array = new Gee.ArrayList<Station> ();
            jsoner.deserialize_array (ref sl_array);

            return sl_array;
        }

        /**
         *
         */
        public void search_feedback () throws ClientError, BadStatusCodeError { }

        /**
         *
         */
        public void search_instant_mixed () throws ClientError, BadStatusCodeError { }

        /**
         * Метод отправки фидбека о прослушивании трека.
         *
         * @param play_id               id сессии прослушивания
         * @param total_played_seconds  общее количество прослушанного времени в секундах
         * @param end_position_seconds  секунда, на которой закончилось прослушивание
         * @param track_length_seconds  общее количество секунд в треке
         * @param track_id              id трека
         * @param album_id              id вльбома, может быть ``null``
         * @param from                  
         * @param context               контекст воспроизведения (То же что и ``Queue.context.type``)
         * @param context_item          id контекста, (Тоже же, что и ``Queue.context.id``)
         * @param radio_session_id      id сессии волны
         *
         * @return                      успех выполнения
         */
        public bool plays (
            Play[] play_objs
        ) throws ClientError, BadStatusCodeError {
            var plays_obj = new Plays ();
            plays_obj.plays.add_all_array (play_objs);

            PostContent post_content = {
                PostContentType.JSON,
                Jsoner.serialize (plays_obj, Case.CAMEL)
            };

            Bytes bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/plays",
                {"default"},
                post_content,
                {{"clientNow", get_timestamp ()}}
            );

            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            if (jsoner.root == null) {
                return false;
            }

            return jsoner.deserialize_value ().get_string () == "ok";
        }

        /**
         *
         */
        public void rewind_slides_user () throws ClientError, BadStatusCodeError { }

        /**
         *
         */
        public void rewind_slides_artist (
            string artist_id
        ) throws ClientError, BadStatusCodeError { }

        /**
         *
         */
        public void pins () throws ClientError, BadStatusCodeError { }

        /**
         *
         */
        public void pins_albums (
            bool pin
        ) throws ClientError, BadStatusCodeError { }

        /**
         *
         */
        public void pins_playlist (
            bool pin
        ) throws ClientError, BadStatusCodeError { }

         /**
         *
         */
        public void pins_artist (
            bool pin
        ) throws ClientError, BadStatusCodeError { }

        /**
         *
         */
        public void pins_wave (
            bool pin
        ) throws ClientError, BadStatusCodeError { }

        /**
         *
         */
        public void tags_playlist_ids (
            string tag_id
        ) throws ClientError, BadStatusCodeError { }

        /**
         *
         */
        public void feed_promotions_promo (
            string promo_id
        ) throws ClientError, BadStatusCodeError { }

        public Gee.ArrayList<Track> tracks (
            string[] id_list,
            bool with_positions = false
        ) throws ClientError, BadStatusCodeError {
            var datalist = Datalist<string> ();
            datalist.set_data ("track-ids", string.joinv (",", id_list));
            datalist.set_data ("with-positions", with_positions.to_string ());

            PostContent post_content = {PostContentType.X_WWW_FORM_URLENCODED};
            post_content.set_datalist (datalist);

            var bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/tracks",
                {"default"},
                post_content
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            var array_list = new Gee.ArrayList<Track> ();
            jsoner.deserialize_array (ref array_list);
            return array_list;
        }

        public string? track_download_uri (
            string track_id,
            bool hq = true
        ) throws ClientError, BadStatusCodeError {
            var di_array = tracks_download_info (track_id);

            int bitrate = hq? 0 : 500;
            string dl_info_uri = "";
            foreach (DownloadInfo download_info in di_array) {
                if (hq == (bitrate < download_info.bitrate_in_kbps)) {
                    bitrate = download_info.bitrate_in_kbps;
                    dl_info_uri = download_info.download_info_url;
                }
            }

            return form_download_uri (dl_info_uri);
        }

        public Gee.ArrayList<DownloadInfo> tracks_download_info (
            string track_id
        ) throws ClientError, BadStatusCodeError {
            Bytes bytes = soup_wrapper.get_sync (
                @"$(YAM_BASE_URL)/tracks/$track_id/download-info",
                {"default"}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            var di_array = new Gee.ArrayList<DownloadInfo> ();
            jsoner.deserialize_array (ref di_array);

            return di_array;
        }

        string? form_download_uri (string dl_info_uri) throws ClientError, BadStatusCodeError {
            Bytes bytes = get_content_of (dl_info_uri);
            string xml_string = (string) bytes.get_data ();

            Xml.Parser.init ();
            var doc = Xml.Parser.parse_memory (xml_string, xml_string.length);

            var root = doc->get_root_element ();

            var children = root->children;
            var host = children->get_content ();

            children = children->next;
            var path = children->get_content ();

            children = children->next;
            var ts = children->get_content ();

            children = children->next;
            children = children->next;
            var s = children->get_content ();

            var str = "XGRlBW9FXlekgbPrRHuSiA" + path[1:] + s;
            var sign = Checksum.compute_for_string (ChecksumType.MD5, str, str.length);

            return @"https://$host/get-mp3/$sign/$ts/$path";
        }

        public Lyrics track_lyrics (string track_id, bool is_sync) throws ClientError, BadStatusCodeError {
            string format = is_sync ? "LRC" : "TEXT";
            string timestamp = new DateTime.now_utc ().to_unix ().to_string ();
            string msg = @"$track_id$timestamp";

            var hmac = new Hmac (ChecksumType.SHA256, "p93jhgh689SBReK6ghtw62".data);
            hmac.update (msg.data);
            uint8[] hmac_sign = new uint8[32];
            size_t digest_length = 32;
            hmac.get_digest (hmac_sign, ref digest_length);
            string sign = Base64.encode (hmac_sign);

            Bytes bytes = soup_wrapper.get_sync (
                @"$(YAM_BASE_URL)/tracks/$track_id/lyrics",
                {"default"},
                {
                    {"format", format},
                    {"timeStamp", timestamp},
                    {"sign", sign}
                }
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            var lyrics = (Lyrics) jsoner.deserialize_object (typeof (Lyrics));
            lyrics.is_sync = is_sync;

            return lyrics;
        }

        public SimilarTracks tracks_similar (string track_id) throws ClientError, BadStatusCodeError {
            Bytes bytes = soup_wrapper.get_sync (
                @"$(YAM_BASE_URL)/tracks/$track_id/similar",
                {"default"}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            return (SimilarTracks) jsoner.deserialize_object (typeof (SimilarTracks));
        }


































        //////////////////////////////////////////////////////
        // Методы ниже должны быть ззаменены на методы выше //
        //////////////////////////////////////////////////////

        //  [Version (deprecated = true)]
        //  public Gee.ArrayList<ShortQueue> queues () throws ClientError, BadStatusCodeError {
        //      Bytes bytes = soup_wrapper.get_sync (
        //          @"$(YAM_BASE_URL)/queues",
        //          {"default", "device"}
        //      );
        //      var jsoner = Jsoner.from_bytes (bytes, {"result", "queues"}, Case.CAMEL);

        //      var queue_list = new Gee.ArrayList<ShortQueue> ();
        //      jsoner.deserialize_array (ref queue_list);
        //      return queue_list;
        //  }

        //  [Version (deprecated = true)]
        //  public Queue queue (string queue_id) throws ClientError, BadStatusCodeError {
        //      Bytes bytes = soup_wrapper.get_sync (
        //          @"$(YAM_BASE_URL)/queues/$queue_id",
        //          {"default"}
        //      );
        //      var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

        //      Queue queue = (Queue) jsoner.deserialize_object (typeof (Queue));

        //      return queue;
        //  }

        //  [Version (deprecated = true)]
        //  public string? create_queue (Queue queue) throws ClientError, BadStatusCodeError {
        //      Bytes bytes = soup_wrapper.post_sync (
        //          @"$(YAM_BASE_URL)/queues",
        //          {"default", "device"},
        //          {PostContentType.JSON, queue.to_json ()}
        //      );

        //      var jsoner = Jsoner.from_bytes (bytes, {"result", "id"}, Case.CAMEL);
        //      var val_id = jsoner.deserialize_value ();

        //      if (val_id == null || !val_id.holds (Type.STRING)) {
        //          return null;
        //      } else {
        //          return val_id.get_string ();
        //      }
        //  }

        //  [Version (deprecated = true)]
        //  public void update_position_queue (string queue_id, int position) throws ClientError, BadStatusCodeError {
        //      Bytes bytes = soup_wrapper.post_sync (
        //          @"$(YAM_BASE_URL)/queues/$queue_id/update-position",
        //          {"default", "device"},
        //          null,
        //          {
        //              {"currentIndex", position.to_string ()},
        //              {"isInteractive", "True"}
        //          }
        //      );

        //      var jsoner = Jsoner.from_bytes (bytes, {"result", "status"}, Case.CAMEL);
        //      string res = jsoner.deserialize_value ().get_string ();

        //      if (res != "ok") {
        //          throw new ClientError.ANSWER_ERROR ("Update queue position failed");
        //      }
        //  }

        ///////////
        // Radio //
        ///////////
    }
}
