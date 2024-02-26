/* Copyright 2023-2024 Rirusha
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-only
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
                    "os=%s; os_version=%s; manufacturer=Rirusha; model=Yandex Music API; clid=; device_id=random; uuid=random".printf (
                        os, version
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

        public Bytes get_content_of (string uri) throws ClientError, BadStatusCodeError {
            return soup_wrapper.get_sync (uri);
        }

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
         * TODO: Placeholder
         */
        public void account_experiments () throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void account_experiments_details () throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void account_settings () throws ClientError, BadStatusCodeError { }

        /*
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
         * TODO: Placeholder
         */
        public void albums_with_tracks (
            string album_id,
            bool rich_tracks
        ) throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void playlist (
            string playlist_uuid
        ) throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void playlists () throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void artists_tracks (
            string artist_id
        ) throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void artists_track_ids (
            string artist_id
        ) throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void artists_safe_direct_albums (
            string artist_id
        ) throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void artists_brief_info (
            string artist_id
        ) throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void artists_similar (
            string artist_id
        ) throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void artists_discography_albums (
            string artist_id
        ) throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void artists_direct_albums (
            string artist_id
        ) throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void artists_also_albums (
            string artist_id
        ) throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void artists_concerts (
            string artist_id
        ) throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void users_playlists_list_kinds (
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /**
         * TODO: Placeholder
         */
        public void users_playlists (
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /**
         * TODO: Placeholder
         */
        public void users_playlists_list (
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /**
         * TODO: Placeholder
         */
        public void users_playlists_playlist (
            owned string? uid = null,
            string playlist_kind,
            bool rich_tracks
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /**
         * TODO: Placeholder
         */
        public void users_playlists_playlist_change_relative (
            owned string? uid = null,
            string playlist_kind
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /**
         * TODO: Placeholder
         */
        public void users_likes_albums (
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /**
         * TODO: Placeholder
         */
        public void users_likes_artists (
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /**
         * TODO: Placeholder
         */
        public void users_likes_playlists (
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /**
         * TODO: Placeholder
         */
        public void users_likes_tracks_add (
            owned string? uid = null,
            string track_id
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /**
         * TODO: Placeholder
         */
        public void users_likes_tracks_remove (
            owned string? uid = null,
            string track_id
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /**
         * TODO: Placeholder
         */
        public void users_dislikes_tracks_add (
            owned string? uid = null,
            string track_id
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /**
         * TODO: Placeholder
         */
        public void users_dislikes_tracks_remove (
            owned string? uid = null,
            string track_id
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /**
         * TODO: Placeholder
         */
        public void users_likes_artists_add (
            owned string? uid = null,
            string artist_id
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /**
         * TODO: Placeholder
         */
        public void users_likes_artists_remove (
            owned string? uid = null,
            string artist_id
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /**
         * TODO: Placeholder
         */
        public void users_dislikes_artists_add (
            owned string? uid = null,
            string artist_id
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /**
         * TODO: Placeholder
         */
        public void users_dislikes_artists_remove (
            owned string? uid = null,
            string artist_id
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /**
         * TODO: Placeholder
         */
        public void users_likes_albums_add (
            owned string? uid = null,
            string album_id
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /**
         * TODO: Placeholder
         */
        public void users_likes_albums_remove (
            owned string? uid = null,
            string album_id
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /**
         * TODO: Placeholder
         */
        public void users_likes_playlists_add (
            owned string? uid = null,
            string playlist_uid,
            string playlist_kind
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /**
         * TODO: Placeholder
         */
        public void users_likes_playlists_remove (
            owned string? uid = null,
            string playlist_uid,
            string playlist_kind
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /**
         * TODO: Placeholder
         */
        public void users_presaves_add (
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /**
         * TODO: Placeholder
         */
        public void users_presaves_remove (
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /**
         * TODO: Placeholder
         */
        public void users_search_history (
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /**
         * TODO: Placeholder
         */
        public void users_search_history_clear (
            owned string? uid = null
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);
        }

        /*
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
         * TODO: Placeholder
         */
        public void landing3_metatags () throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void metatags_metatag (
            string metatag
        ) throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void metatags_albums (
            string metatag
        ) throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void metatags_artists (
            string metatag
        ) throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void metatags_playlists (
            string metatag
        ) throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void top_category (
            string category
        ) throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void rotor_station_info (
            string station_id
        ) throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void rotor_station_stream () throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void rotor_session_new () throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void rotor_session_tracks (
            string radio_session_id
        ) throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void rotor_session_feedback (
            string radio_session_id
        ) throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void rotor_wave_settings () throws ClientError, BadStatusCodeError { }

        /*
         * Получение последней прослушиваемой волны текущим пользователем
         */
        public Rotor.Wave rotor_wave_last () throws ClientError, BadStatusCodeError {
            var bytes = soup_wrapper.get_sync (
                @"$(YAM_BASE_URL)/rotor/wave/last",
                {"default"}
            );

            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            return (Rotor.Wave) jsoner.deserialize_object (typeof (Rotor.Wave));
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

        /**
         * TODO: Placeholder
         */
        public void search_feedback () throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
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
            string play_id,
            double total_played_seconds,
            double end_position_seconds,
            double track_length_seconds,
            string track_id,
            string? album_id,
            string from,
            string context,
            string context_item,
            string? radio_session_id = null
        ) throws ClientError, BadStatusCodeError {
            var play = new Play () {
                play_id = play_id,
                timestamp = get_timestamp (),
                total_played_seconds = total_played_seconds,
                end_position_seconds = end_position_seconds,
                track_length_seconds = track_length_seconds,
                track_id = track_id,
                album_id = album_id,
                from = from,
                context = context,
                context_item = context_item,
                add_tracks_to_player_time = Play.generate_add_tracks_to_player_time (),
                audio_auto = "none",
                audio_output_name = "Динамики",
                audio_output_type = "Speaker",
                radio_session_id = radio_session_id
            };

            PostContent post_content = {
                PostContentType.JSON,
                Jsoner.serialize (play)
            };

            Bytes bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/plays",
                {"default"},
                post_content,
                {{"clientNow", get_timestamp ()}}
            );

            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);
            string res = jsoner.deserialize_value ().get_string ();

            if (res != "ok") {
                throw new ClientError.ANSWER_ERROR ("Send play-audio failed");
            }
        }

        /**
         * TODO: Placeholder
         */
        public void rewind_slides_user () throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void rewind_slides_artist (
            string artist_id
        ) throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void pins () throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void pins_albums (
            bool pin
        ) throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void pins_playlist (
            bool pin
        ) throws ClientError, BadStatusCodeError { }

         /**
         * TODO: Placeholder
         */
        public void pins_artist (
            bool pin
        ) throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void pins_wave (
            bool pin
        ) throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void tags_playlist_ids (
            string tag_id
        ) throws ClientError, BadStatusCodeError { }

        /**
         * TODO: Placeholder
         */
        public void feed_promotions_promo (
            string promo_id
        ) throws ClientError, BadStatusCodeError { }

        ////////////////////////////////////////////////////////////
        // TODO: Методы ниже должны быть ззаменены на методы выше //
        ////////////////////////////////////////////////////////////

        [Deprocated]
        public Playlist get_playlist_info (owned string? uid = null, string kind = "3") throws ClientError, BadStatusCodeError {
            check_uid (ref uid);

            var bytes = soup_wrapper.get_sync (
                @"$(YAM_BASE_URL)/users/$uid/playlists/$kind",
                {"default"}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            return (Playlist) jsoner.deserialize_object (typeof (Playlist));
        }

        [Deprocated]
        public Gee.ArrayList<Track> get_tracks (
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

        [Deprocated]
        public Gee.ArrayList<ShortQueue> queues () throws ClientError, BadStatusCodeError {
            Bytes bytes = soup_wrapper.get_sync (
                @"$(YAM_BASE_URL)/queues",
                {"default", "device"}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result", "queues"}, Case.CAMEL);

            var queue_list = new Gee.ArrayList<ShortQueue> ();
            jsoner.deserialize_array (ref queue_list);
            return queue_list;
        }

        [Deprocated]
        public Queue queue (string queue_id) throws ClientError, BadStatusCodeError {
            Bytes bytes = soup_wrapper.get_sync (
                @"$(YAM_BASE_URL)/queues/$queue_id",
                {"default"}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            Queue queue = (Queue) jsoner.deserialize_object (typeof (Queue));

            return queue;
        }

        [Deprocated]
        public string? create_queue (Queue queue) throws ClientError, BadStatusCodeError {
            Bytes bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/queues",
                {"default", "device"},
                {PostContentType.JSON, queue.to_json ()}
            );

            var jsoner = Jsoner.from_bytes (bytes, {"result", "id"}, Case.CAMEL);
            var val_id = jsoner.deserialize_value ();

            if (val_id == null || !val_id.holds (Type.STRING)) {
                return null;
            } else {
                return val_id.get_string ();
            }
        }

        [Deprocated]
        public void update_position_queue (string queue_id, int position) throws ClientError, BadStatusCodeError {
            Bytes bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/queues/$queue_id/update-position",
                {"default", "device"},
                null,
                {
                    {"currentIndex", position.to_string ()},
                    {"isInteractive", "True"}
                }
            );

            var jsoner = Jsoner.from_bytes (bytes, {"result", "status"}, Case.CAMEL);
            string res = jsoner.deserialize_value ().get_string ();

            if (res != "ok") {
                throw new ClientError.ANSWER_ERROR ("Update queue position failed");
            }
        }

        [Deprocated]
        public void play_audio (
            owned string? uid,
            string track_id,
            string album_id,
            string? playlist_id,
            double track_length_seconds,
            double total_played_seconds,
            double end_position_seconds
        ) throws ClientError, BadStatusCodeError {
            check_uid (ref uid);

            var time = new DateTime.now_utc ().format_iso8601 ();

            var datalist = Datalist<string> ();
            datalist.set_data ("track-id", track_id);
            datalist.set_data ("from-cache", "False");
            datalist.set_data ("from", "Cassette");
            datalist.set_data ("play-id", "");
            datalist.set_data ("uid", uid);
            datalist.set_data ("timestamp", time);
            datalist.set_data ("track-length-seconds", track_length_seconds.to_string ());
            datalist.set_data ("total-played-seconds", total_played_seconds.to_string ());
            datalist.set_data ("end-position-seconds", end_position_seconds.to_string ());
            datalist.set_data ("album-id", album_id);
            datalist.set_data ("playlist-id", playlist_id);
            datalist.set_data ("client-now", time);

            PostContent post_content = {PostContentType.X_WWW_FORM_URLENCODED};
            post_content.set_datalist (datalist);

            Bytes bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/play-audio",
                {"default"},
                post_content
            );

            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);
            string res = jsoner.deserialize_value ().get_string ();

            if (res != "ok") {
                throw new ClientError.ANSWER_ERROR ("Send play-audio failed");
            }
        }

        [Deprocated]
        public string? get_download_uri (string track_id, bool hq = true) throws ClientError, BadStatusCodeError {
            Bytes bytes = soup_wrapper.get_sync (@"$(YAM_BASE_URL)/tracks/$track_id/download-info", {"default"});
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            var di_array = new Gee.ArrayList<DownloadInfo> ();
            jsoner.deserialize_array (ref di_array);

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

        [Deprocated]
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

        [Deprocated]
        public bool like (string what, string id) throws ClientError, BadStatusCodeError {
            string? uid = null;
            check_uid (ref uid);

            var datalist = Datalist<string> ();
            datalist.set_data (@"$what-ids", id);

            PostContent post_content = {PostContentType.X_WWW_FORM_URLENCODED};
            post_content.set_datalist (datalist);

            Bytes bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/users/$uid/likes/$(what)s/add-multiple",
                {"default"},
                post_content
            );

            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);
            if (jsoner.root != null) {
                return true;
            }
            return false;
        }

        [Deprocated]
        public bool remove_like (string what, string id) throws ClientError, BadStatusCodeError {
            string? uid = null;
            check_uid (ref uid);

            var datalist = Datalist<string> ();
            datalist.set_data (@"$what-ids", id);

            PostContent post_content = {PostContentType.X_WWW_FORM_URLENCODED};
            post_content.set_datalist (datalist);

            Bytes bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/users/$uid/likes/$(what)s/remove",
                {"default"},
                post_content
            );

            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);
            if (jsoner.root != null) {
                return true;
            }
            return false;
        }

        [Deprocated]
        public bool dislike (string id) throws ClientError, BadStatusCodeError {
            string? uid = null;
            check_uid (ref uid);

            var datalist = Datalist<string> ();
            datalist.set_data ("track-ids", id);

            PostContent post_content = {PostContentType.X_WWW_FORM_URLENCODED};
            post_content.set_datalist (datalist);

            Bytes bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/users/$uid/dislikes/tracks/add-multiple",
                {"default"},
                post_content
            );

            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);
            if (jsoner.root != null) {
                return true;
            }
            return false;
        }

        [Deprocated]
        public bool remove_dislike (string id) throws ClientError, BadStatusCodeError {
            string? uid = null;
            check_uid (ref uid);

            var datalist = Datalist<string> ();
            datalist.set_data ("track-ids", id);

            PostContent post_content = {PostContentType.X_WWW_FORM_URLENCODED};
            post_content.set_datalist (datalist);

            Bytes bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/users/$uid/dislikes/tracks/remove",
                {"default"},
                post_content
            );

            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);
            if (jsoner.root != null) {
                return true;
            }
            return false;
        }

        [Deprocated]
        public Gee.ArrayList<Playlist> get_playlists_list (owned string? uid = null) throws ClientError, BadStatusCodeError {
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

        [Deprocated]
        public Gee.ArrayList<LikedPlaylist> get_likes_playlists_list (
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

        [Deprocated]
        public SimilarTracks similar_tracks (string track_id) throws ClientError, BadStatusCodeError {
            Bytes bytes = soup_wrapper.get_sync (
                @"$(YAM_BASE_URL)/tracks/$track_id/similar",
                {"default"}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            return (SimilarTracks) jsoner.deserialize_object (typeof (SimilarTracks));
        }

        [Deprocated]
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

        [Deprocated]
        public Playlist change_playlist (
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

        [Deprocated]
        public Playlist change_playlist_visibility (
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

        [Deprocated]
        public Playlist create_playlist (
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

        [Deprocated]
        public bool delete_playlist (
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

        [Deprocated]
        public Playlist change_playlist_name (
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

        [Deprocated]
        public PlaylistRecommendations get_playlist_recommendations (
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

        [Deprocated]
        public Gee.ArrayList<TrackShort> get_disliked_tracks (
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

        ///////////
        // Radio //
        ///////////

        [Deprocated]
        public Dashboard get_rotor_dashboard () throws ClientError, BadStatusCodeError {
            var bytes = soup_wrapper.get_sync (
                @"$(YAM_BASE_URL)/rotor/stations/dashboard",
                {"default", "device"},
                {{"language", get_language ()}}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            return (Dashboard) jsoner.deserialize_object (typeof (Dashboard));
        }

        [Deprocated]
        public Gee.ArrayList<StationInfo> get_station_list () throws ClientError, BadStatusCodeError {
            var bytes = soup_wrapper.get_sync (
                @"$(YAM_BASE_URL)/rotor/stations/list",
                {"default", "device"},
                {{"language", get_language ()}}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            var our_array = new Gee.ArrayList<StationInfo> ();
            jsoner.deserialize_array (ref our_array);

            return our_array;
        }

        [Deprocated]
        public StationInfo get_rotor_info (
            string station_type
        ) throws ClientError, BadStatusCodeError {
            var bytes = soup_wrapper.get_sync (
                @"$(YAM_BASE_URL)/rotor/station/$station_type/info",
                {"default", "device"}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            var our_array = new Gee.ArrayList<StationInfo> ();
            jsoner.deserialize_array (ref our_array);

            if (our_array.size == 0) {
                throw new ClientError.SOUP_ERROR ("Wrong station name: %s".printf (station_type));
            }

            return our_array[0];
        }

        [Deprocated]
        public bool rotor_feedback_started (
            string station_type
        ) throws ClientError, BadStatusCodeError {
            var datalist = Datalist<string> ();
            datalist.set_data ("type", FeedbackType.STARTED);
            datalist.set_data ("timestamp", new DateTime.now_utc ().format_iso8601 ());
            datalist.set_data ("from", @"mobile-radio-$station_type");

            PostContent post_content = {PostContentType.JSON};
            post_content.set_datalist (datalist);

            Bytes bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/rotor/station/$station_type/feedback",
                {"default", "device"},
                post_content
            );

            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);
            if (jsoner.root != null) {
                return true;
            }
            return false;
        }

        [Deprocated]
        public bool rotor_feedback_track_started (
            string station_type,
            string batch_id,
            string track_id
        ) throws ClientError, BadStatusCodeError {
            var datalist = Datalist<string> ();
            datalist.set_data ("type", FeedbackType.TRACK_STARTED);
            datalist.set_data ("timestamp", new DateTime.now_utc ().format_iso8601 ());
            datalist.set_data ("trackId", track_id);

            PostContent post_content = {PostContentType.JSON};
            post_content.set_datalist (datalist);

            Bytes bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/rotor/station/$station_type/feedback",
                {"default", "device"},
                post_content,
                {{"batch-id", batch_id}}
            );

            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);
            if (jsoner.root != null) {
                return true;
            }
            return false;
        }

        [Deprocated]
        public bool rotor_feedback_track_finished (
            string station_type,
            string batch_id,
            string track_id,
            double total_played_seconds
        ) throws ClientError, BadStatusCodeError {
            var datalist = Datalist<string> ();
            datalist.set_data ("type", FeedbackType.TRACK_FINISHED);
            datalist.set_data ("timestamp", new DateTime.now_utc ().format_iso8601 ());
            datalist.set_data ("trackId", track_id);
            datalist.set_data ("totalPlayedSeconds", total_played_seconds.to_string ());

            PostContent post_content = {PostContentType.JSON};
            post_content.set_datalist (datalist);

            Bytes bytes = soup_wrapper.post_sync (
                @"$(YAM_BASE_URL)/rotor/station/$station_type/feedback",
                {"default", "device"},
                post_content,
                {{"batch-id", batch_id}}
            );

            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);
            if (jsoner.root != null) {
                return true;
            }
            return false;
        }

        [Deprocated]
        public StationTracks get_station_tracks (
            string station_type
        ) throws ClientError, BadStatusCodeError {
            var bytes = soup_wrapper.get_sync (
                @"$(YAM_BASE_URL)/rotor/station/$station_type/tracks",
                {"default", "device"},
                {{"settings2", "true"}}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            return (StationTracks) jsoner.deserialize_object (typeof (StationTracks));
        }
    }
}
