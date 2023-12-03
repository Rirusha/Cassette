/* yam_talker.vala
 *
 * Copyright 2023 Rirusha
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


using CassetteClient.YaMAPI;


namespace CassetteClient {

    delegate void NetFunc () throws ClientError, BadStatusCodeError;
    
    // Класс для выполнения всяких вещей, связанных с интернетом, чтобы можно было оповестить пользователя о проблемах с соединением
    public class YaMTalker : AbstractTalker {

        public YaMClient client { get; private set; }
        public LikesController likes_controller { get; default = new LikesController (); }

        public signal void track_likes_start_change (string track_id);
        public signal void track_likes_end_change (string track_id, bool is_liked);

        public signal void track_dislikes_start_change (string track_id);
        public signal void track_dislikes_end_change (string track_id, bool is_disliked);

        public signal void object_updated (string oid);
        public signal void playlists_updated ();
        public signal void playlist_start_delete (string oid);
        public signal void playlist_stop_delete (string oid);

        public signal void init_end ();

        private AccountInfo? _me = null;
        public AccountInfo me {
            owned get {
                if (_me != null) {
                    return _me;
                }

                _me = client.me;
                if (_me == null) {
                    string my_uid = storager.db.get_additional_data ("me");
                    if (my_uid != null) {
                        _me = (AccountInfo) storager.load_object (typeof (AccountInfo), my_uid);
                    }

                    if (_me == null) {
                        return new AccountInfo ();
                    }
                }

                return _me;
            }
        }

        public override void init_if_not () throws BadStatusCodeError {
            bool is_need_init = false;

            if (client == null) {
                is_need_init = true;
            } else {
                is_need_init = !client.is_init_complete;
            }

            if (is_need_init) {
                init ();
            }
        }

        public void init () throws BadStatusCodeError {
            client = new YaMClient (create_soup_wrapper (true));

            net_run (() => {
                client.init ();

                storager.db.set_additional_data ("me", me.oid);
                storager.save_object (me, false);

                get_playlist_info (null, "3");
                get_likes_playlist_list (null);
                get_disliked_tracks_short ();

                _me = null;

                init_end ();
            }, false);
        }

        public Playlist? get_playlist_info (string? uid = null, string kind = "3") throws BadStatusCodeError {
            Playlist? playlist_info = null;

            net_run (() => {
                playlist_info = client.get_playlist_info (uid, kind);

                if (kind == "3") {
                    likes_controller.update_liked_tracks (playlist_info.tracks);
                }

                if (playlist_info.tracks.size != 0) {
                    if (playlist_info.tracks[0].track == null) {
                        string[] tracks_ids = new string[playlist_info.tracks.size];
                        for (int i = 0; i < tracks_ids.length; i++) {
                            tracks_ids[i] = playlist_info.tracks[i].id;
                        }

                        var track_list = client.get_tracks (tracks_ids);
                        playlist_info.set_track_list (track_list);
                    }
                }

                // Пересохраняет объект, если он уже сохранен во временную.
                // Постоянными объектами занимается уже YaMObjectCachier
                var object_location = storager.object_cache_location (playlist_info.get_type (), playlist_info.oid);
                if (object_location.is_tmp) {
                    storager.save_object (playlist_info, true);
                    cachier_controller.change_state (
                        Cachier.ContentType.PLAYLIST,
                        playlist_info.oid,
                        Cachier.CacheingState.TEMP);
                }
            });

            return playlist_info;
        }

        public Gee.ArrayList<Track>? get_tracks_info (string[] ids) {
            Gee.ArrayList<Track>? track_list = null;

            net_run_wout_code (() => {
                track_list = client.get_tracks (ids, true);
            });

            return track_list;
        }

        public void play_audio (YaMAPI.Track track_info, string? playlist_id, double play_position_sec) {
            string album_id = "unknown";
            if (track_info.albums.size != 0) {
                album_id = track_info.albums[0].id;
            }

            net_run_wout_code (() => {
                client.play_audio (
                    null,
                    track_info.id,
                    album_id,
                    playlist_id,
                    track_info.duration_ms / 1000,
                    play_position_sec,
                    play_position_sec
                );
            });
        }

        public YaMAPI.Queue? get_queue () {
            YaMAPI.Queue? queue = null;

            net_run_wout_code (() => {
                var queues = client.queues ();

                if (queues.size == 0) {
                    return;
                }

                queue = client.queue (queues[0].id);

                string[] track_ids = new string[queue.tracks.size];
                for (int i = 0; i < track_ids.length; i++) {
                    track_ids[i] = queue.tracks[i].id;
                }
                queue.tracks = client.get_tracks (track_ids);
            });

            return queue;
        }

        public string? create_queue (YaMAPI.Queue queue) {
            string? queue_id = null;

            net_run_wout_code (() => {
                queue_id = client.create_queue (queue);
            });

            return queue_id;
        }

        public void update_position_queue (YaMAPI.Queue queue) {
            net_run_wout_code (() => {
                //  На случай если пользователь после формирования очереди быстро сменит трек и id после создания не успеет придти
                if (queue.id == null) {
                    queue.id = create_queue (queue);
                }

                client.update_position_queue (queue.id, queue.current_index);
            });
        }

        public string? get_download_uri (string track_id, bool is_hq) {
            string? track_uri = null;

            net_run_wout_code (() => {
                track_uri = client.get_download_uri (track_id, is_hq);
            });

            return track_uri;
        }

        private string get_likable_type (LikableType content_type) {
            switch (content_type) {
                case LikableType.TRACK:
                    return "track";
                case LikableType.PLAYLIST:
                    return "playlist";
                case LikableType.ALBUM:
                    return "album";
                default:
                    assert_not_reached ();
            }
        }

        public void like (LikableType content_type, string content_id) {
            net_run_wout_code (() => {
                track_likes_start_change (content_id);
                
                bool is_ok = client.like (get_likable_type (content_type), content_id);
                if (is_ok) {
                    likes_controller.add_liked (content_type, content_id);
                    track_likes_end_change (content_id, true);
                    if (content_type == LikableType.TRACK) {
                        likes_controller.remove_disliked (content_id);
                        track_dislikes_end_change (content_id, false);
                    }
                }
            });
        }

        public void remove_like (LikableType content_type, string content_id) {
            net_run_wout_code (() => {
                track_likes_start_change (content_id);
                
                bool is_ok = client.remove_like (get_likable_type (content_type), content_id);
                if (is_ok) {
                    likes_controller.remove_liked (content_type, content_id);
                    track_likes_end_change (content_id, false);
                }
            });
        }

        public void dislike (string track_id) {
            net_run_wout_code (() => {
                track_dislikes_start_change (track_id);
                
                bool is_ok = client.dislike (track_id);
                if (is_ok) {
                    likes_controller.add_disliked (track_id);
                    track_dislikes_end_change (track_id, true);
                    likes_controller.remove_liked (LikableType.TRACK, track_id);
                    track_likes_end_change (track_id, false);
                }
            });
        }

        public void remove_dislike (string track_id) {
            net_run_wout_code (() => {
                track_dislikes_start_change (track_id);

                bool is_ok = client.remove_dislike (track_id);
                if (is_ok) {
                    likes_controller.remove_disliked (track_id);
                    track_dislikes_end_change (track_id, false);
                }
            });
        }

        public Gee.ArrayList<Playlist>? get_playlist_list (string? uid = null) {
            Gee.ArrayList<Playlist>? playlist_list = null;

            net_run_wout_code (() => {
                playlist_list = client.get_playlists_list (uid);

                if (uid == null) {
                    string[] playlists_kinds = new string[playlist_list.size];
                    for (int i = 0; i < playlist_list.size; i++) {
                        playlists_kinds[i] = playlist_list[i].kind.to_string ();
                    }

                    storager.db.set_additional_data ("my_playlists", string.joinv (",", playlists_kinds));
                }
            });

            return playlist_list;
        }

        public Gee.ArrayList<LikedPlaylist>? get_likes_playlist_list (string? uid = null) {
            Gee.ArrayList<LikedPlaylist>? playlist_list = null;

            net_run_wout_code (() => {
                playlist_list = client.get_likes_playlists_list (uid);

                likes_controller.update_liked_playlists (playlist_list);
            });

            return playlist_list;
        }

        public YaMAPI.SimilarTracks? get_track_similar (string track_id) {
            YaMAPI.SimilarTracks? similar_tracks = null;

            net_run_wout_code (() => {
                similar_tracks = client.similar_tracks (track_id);
            });

            return similar_tracks;
        }

        public YaMAPI.Lyrics? get_lyrics (string track_id, bool is_sync) {
            YaMAPI.Lyrics? lyrics = null;

            net_run_wout_code (() => {
                lyrics = client.track_lyrics (track_id, is_sync);
                var txt = load_text (lyrics.download_url);
                lyrics.text = new Gee.ArrayList<string>.wrap (txt.split ("\n"));
            });

            return lyrics;
        }

        public string? load_text (string uri) {
            string? text = null;

            net_run_wout_code (() => {
                Bytes? bytes = client.get_content_of (uri);
                text = (string) bytes.get_data ();
            });

            return text;
        }

        // Получает изображение из сети как pixbuf
        public Gdk.Pixbuf? load_pixbuf (string image_uri) {
            Gdk.Pixbuf? image = null;

            net_run_wout_code (() => {
                Bytes? bytes = client.get_content_of (image_uri);
                var stream = new MemoryInputStream.from_bytes (bytes);
                try {
                    image = new Gdk.Pixbuf.from_stream (stream);
                } catch (Error e) {  }
            });

            return image;
        }

        public Gdk.Texture? load_paintable (string image_uri) {
            Gdk.Texture? image = null;

            net_run_wout_code (() => {
                Bytes? bytes = client.get_content_of (image_uri);
                try {
                    image = Gdk.Texture.from_bytes (bytes);
                } catch (Error e) {  }
            });

            return image;
        }

        public Bytes? load_track (string track_uri) {
            Bytes? content = null;

            net_run_wout_code (() => {
                content = client.get_content_of (track_uri);
            });

            return content;
        }

        public Playlist? add_track_to_playlist (string kind, Track track, int position, int revision) {
            return add_tracks_to_playlist (kind, {track}, position, revision);
        }

        public Playlist? add_tracks_to_playlist (string kind, Track[] tracks, int position, int revision) {
            Playlist? new_playlist = null;

            var diff = new DifferenceBuilder ();

            diff.add_insert (position, tracks);

            net_run_wout_code (() => {
                new_playlist = client.change_playlist (null, kind, diff.to_json (), revision);
                object_updated (new_playlist.oid);
            });

            return new_playlist;
        }

        public Playlist? remove_tracks_from_playlist (string kind, int position, int revision) {
            Playlist? new_playlist = null;

            var diff = new DifferenceBuilder ();

            diff.add_delete (position, position + 1);

            net_run_wout_code (() => {
                new_playlist = client.change_playlist (null, kind, diff.to_json (), revision);
                object_updated (new_playlist.oid);
            });

            return new_playlist;
        }

        public Playlist? change_playlist_visibility (string kind, bool is_public) {
            Playlist? new_playlist = null;

            net_run_wout_code (() => {
                new_playlist = client.change_playlist_visibility (null, kind, is_public ? "public" : "private");
                object_updated (new_playlist.oid);
            });

            return new_playlist;
        }

        public Playlist? create_playlist () {
            Playlist? new_playlist = null;

            net_run_wout_code (() => {
                // Translators: name of new created playlist
                new_playlist = client.create_playlist (null, _("New Playlist"));
                playlists_updated ();
            });

            return new_playlist;
        }

        public bool delete_playlist (string kind) {
            bool is_success = false;

            net_run_wout_code (() => {
                playlist_start_delete (kind);
                is_success = client.delete_playlist (null, kind);
                if (is_success) {
                    playlists_updated ();
                } else {
                    playlist_stop_delete (kind);
                }
            });

            return is_success;
        }

        public Playlist? change_playlist_name (string kind, string new_name) {
            Playlist? new_playlist = null;

            net_run_wout_code (() => {
                new_playlist = client.change_playlist_name (null, kind, new_name);
                object_updated (new_playlist.oid);
            });

            return new_playlist;
        }

        private Gee.ArrayList<YaMAPI.TrackShort>? get_disliked_tracks_short () {
            Gee.ArrayList<YaMAPI.TrackShort>? trackshort_list = null;

            net_run_wout_code (() => {
                trackshort_list = client.get_disliked_tracks (null);

                likes_controller.update_disliked_tracks (trackshort_list);
            });

            return trackshort_list;
        }

        public YaMAPI.TrackHeap? get_disliked_tracks () {
            YaMAPI.TrackHeap? track_list = null;

            net_run_wout_code (() => {
                var trackshort_list = get_disliked_tracks_short ();

                string[] track_ids = new string[trackshort_list.size];
                for (int i = 0; i < track_ids.length; i++) {
                    track_ids[i] = trackshort_list[i].id;
                }
                var tracks = client.get_tracks (track_ids);
                track_list = new YaMAPI.TrackHeap ();
                track_list.tracks = tracks;
            });

            return track_list;
        }
    }
}