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


using CassetteClient.YaMAPI.Rotor;

namespace CassetteClient.YaMAPI {

    public class YaMClient : Object {

        const string YAM_BASE_URL = "https://api.music.yandex.net";

        public SoupWrapper soup_wrapper { get; construct; }

        public AccountInfo? me { get; private set; default = null; }

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

            get_account_info ();
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

                uid = me.oid;
                if (uid == null) {
                    throw new ClientError.AUTH_ERROR ("Auth Error");
                }
            }
        }

        public AccountInfo get_account_info () throws ClientError, BadStatusCodeError {
            if (me != null) {
                return me;
            }

            Bytes bytes = soup_wrapper.get_sync (
                @"$(YAM_BASE_URL)/account/status",
                {"default"}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            me = (AccountInfo) jsoner.deserialize_object (typeof (AccountInfo));

            bytes = soup_wrapper.get_sync (
                "https://login.yandex.ru/info",
                {"auth"},
                {{"format", "json"}},
                {{"Host", "login.yandex.ru"}}
            );
            jsoner = Jsoner.from_bytes (bytes, null, Case.SNAKE);

            me.avatar_info = (AvatarInfo) jsoner.deserialize_object (typeof (AvatarInfo));

            return me;
        }

        public Playlist get_playlist_info (owned string? uid = null, string kind = "3") throws ClientError, BadStatusCodeError {
            check_uid (ref uid);

            var bytes = soup_wrapper.get_sync (
                @"$(YAM_BASE_URL)/users/$uid/playlists/$kind",
                {"default"}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            return (Playlist) jsoner.deserialize_object (typeof (Playlist));
        }

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

        public Queue queue (string queue_id) throws ClientError, BadStatusCodeError {
            Bytes bytes = soup_wrapper.get_sync (
                @"$(YAM_BASE_URL)/queues/$queue_id",
                {"default"}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            Queue queue = (Queue) jsoner.deserialize_object (typeof (Queue));

            return queue;
        }

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

        public SimilarTracks similar_tracks (string track_id) throws ClientError, BadStatusCodeError {
            Bytes bytes = soup_wrapper.get_sync (
                @"$(YAM_BASE_URL)/tracks/$track_id/similar",
                {"default"}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            return (SimilarTracks) jsoner.deserialize_object (typeof (SimilarTracks));
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

        public Dashboard get_rotor_dashboard () throws ClientError, BadStatusCodeError {
            var bytes = soup_wrapper.get_sync (
                @"$(YAM_BASE_URL)/rotor/stations/dashboard",
                {"default", "device"},
                {{"language", get_language ()}}
            );
            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            return (Dashboard) jsoner.deserialize_object (typeof (Dashboard));
        }

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

        /////////
        // New //
        /////////

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

        /*
         * Получение последней прослушиваемой волны текущим пользователем
         */
        public Rotor.Wave rotor_wave_last () {
            var bytes = soup_wrapper.get_sync (
                @"$(YAM_BASE_URL)/rotor/wave/last",
                {"default"}
            ); 

            var jsoner = Jsoner.from_bytes (bytes, {"result"}, Case.CAMEL);

            return (Rotor.Wave) jsoner.deserialize_object (typeof (Rotor.Wave));
        }
    }
}
