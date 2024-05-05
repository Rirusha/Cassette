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
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */


using Cassette.Client.YaMAPI;


namespace Cassette.Client {

    delegate void NetFunc () throws ClientError, BadStatusCodeError;

    /**
     * Класс для выполнения всяких вещей, связанных с интернетом, чтобы 
     * можно было оповестить пользователя о проблемах с соединением
     */
    public class YaMTalker : AbstractTalker {

        public YaMClient client { get; default = new YaMClient (create_soup_wrapper (true)); }
        public LikesController likes_controller { get; default = new LikesController (); }

        public signal void track_likes_start_change (string track_id);
        public signal void track_likes_end_change (string track_id, bool is_liked);

        public signal void track_dislikes_start_change (string track_id);
        public signal void track_dislikes_end_change (string track_id, bool is_disliked);

        public signal void playlist_changed (YaMAPI.Playlist new_playlist);
        public signal void playlists_updated ();
        public signal void playlist_start_delete (string oid);
        public signal void playlist_stop_delete (string oid);

        public signal void init_end ();

        Account.About? _me = null;
        public Account.About me {
            owned get {
                if (_me != null) {
                    return _me;
                }

                _me = client.me;
                if (_me == null) {
                    string my_uid = storager.db.get_additional_data ("me");
                    if (my_uid != null) {
                        _me = (Account.About) storager.load_object (typeof (Account.About), my_uid);
                    }

                    if (_me == null) {
                        return new Account.About ();
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

        public bool is_me (string? uid) {
            return uid == null || uid == me.uid;
        }

        public bool is_my_liked (string? uid, string kind) {
            return is_me (uid) && kind == "3";
        }

        public void init () throws BadStatusCodeError {
            client.soup_wrapper.reload_cookies (storager.cookies_file);

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

        /**
         * Update data that may have been changed by other clients.
         * Just internet check for now.
         */
        public async void update_all () {
            threader.add (() => {
                net_run_wout_code (() => {
                    client.get_content_of ("https://ya.ru/");
                });

                Idle.add (update_all.callback);
            });

            yield;
        }

        public Playlist? get_playlist_info (string? uid = null, string kind = "3") throws BadStatusCodeError {
            Playlist? playlist_info = null;

            net_run (() => {
                playlist_info = client.users_playlists_playlist (kind, true, uid);

                if (is_my_liked (uid, kind)) {
                    likes_controller.update_liked_tracks (playlist_info.tracks);
                }

                if (playlist_info.tracks.size != 0) {
                    if (playlist_info.tracks[0].track == null) {
                        string[] tracks_ids = new string[playlist_info.tracks.size];
                        for (int i = 0; i < tracks_ids.length; i++) {
                            tracks_ids[i] = playlist_info.tracks[i].id;
                        }

                        var track_list = client.tracks (tracks_ids);
                        playlist_info.set_track_list (track_list);
                    }
                }

                // Сохраняет объект, если он не сохранен в data
                // Постоянными объектами занимается уже Cachier.Job
                var object_location = storager.object_cache_location (playlist_info.get_type (), playlist_info.oid);
                if (object_location.is_tmp && settings.get_boolean ("can-cache")) {
                    storager.save_object (playlist_info, true);
                    cachier.controller.change_state (
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
                track_list = client.tracks (ids, true);
            });

            return track_list;
        }

        public void send_play (YaMAPI.Play[] play_objs) {
            net_run_wout_code (() => {
                client.plays (play_objs);
            });
        }

        //  public YaMAPI.Queue? get_queue () {
        //      YaMAPI.Queue? queue = null;

        //      net_run_wout_code (() => {
        //          var queues = client.queues ();

        //          if (queues.size == 0) {
        //              return;
        //          }

        //          queue = client.queue (queues[0].id);

        //          string[] track_ids = new string[queue.tracks.size];
        //          for (int i = 0; i < track_ids.length; i++) {
        //              track_ids[i] = queue.tracks[i].id;
        //          }
        //          queue.tracks = client.tracks (track_ids);
        //      });

        //      return queue;
        //  }

        //  public string? create_queue (YaMAPI.Queue queue) {
        //      string? queue_id = null;

        //      net_run_wout_code (() => {
        //          queue_id = client.create_queue (queue);
        //      });

        //      return queue_id;
        //  }

        //  public void update_position_queue (YaMAPI.Queue queue) {
        //      try {
        //          net_run (() => {
        //              // На случай если пользователь после формирования очереди быстро
        //              // сменит трек и id после создания не успеет придти
        //              if (queue.id == null) {
        //                  queue.id = create_queue (queue);
        //              }

        //              if (queue.id == null) {
        //                  return;
        //              }

        //              client.update_position_queue (queue.id, queue.current_index);
        //          });
        //      } catch (Cassette.Client.BadStatusCodeError e) {
        //          if (e is Cassette.Client.BadStatusCodeError.NOT_FOUND) {
        //              queue.id = null;

        //              update_position_queue (queue);
        //          }
        //      }
        //  }

        public string? get_download_uri (string track_id, bool is_hq) {
            string? track_uri = null;

            net_run_wout_code (() => {
                track_uri = client.track_download_uri (track_id, is_hq);
            });

            return track_uri;
        }

        string get_likable_type (LikableType content_type) {
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
                        player.rotor_feedback (Rotor.FeedbackType.LIKE, content_id);

                        track_dislikes_end_change (content_id, false);
                    }
                }
            });
        }

        public void unlike (LikableType content_type, string content_id) {
            net_run_wout_code (() => {
                track_likes_start_change (content_id);

                bool is_ok = client.remove_like (get_likable_type (content_type), content_id);
                if (is_ok) {
                    likes_controller.remove_liked (content_type, content_id);
                    player.rotor_feedback (Rotor.FeedbackType.UNLIKE, content_id);

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
                    player.rotor_feedback (Rotor.FeedbackType.DISLIKE, track_id);

                    track_dislikes_end_change (track_id, true);
                    likes_controller.remove_liked (LikableType.TRACK, track_id);
                    track_likes_end_change (track_id, false);
                }
            });
        }

        public void undislike (string track_id) {
            net_run_wout_code (() => {
                track_dislikes_start_change (track_id);

                bool is_ok = client.remove_dislike (track_id);
                if (is_ok) {
                    likes_controller.remove_disliked (track_id);
                    player.rotor_feedback (Rotor.FeedbackType.UNDISLIKE, track_id);

                    track_dislikes_end_change (track_id, false);
                }
            });
        }

        public Gee.ArrayList<Playlist>? get_playlist_list (string? uid = null) {
            Gee.ArrayList<Playlist>? playlist_list = null;

            net_run_wout_code (() => {
                playlist_list = client.users_playlists_list (uid);

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
                playlist_list = client.users_likes_playlists (uid);

                likes_controller.update_liked_playlists (playlist_list);
            });

            return playlist_list;
        }

        public YaMAPI.SimilarTracks? get_track_similar (string track_id) {
            YaMAPI.SimilarTracks? similar_tracks = null;

            net_run_wout_code (() => {
                similar_tracks = client.tracks_similar (track_id);
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
                } catch (Error e) { }
            });

            return image;
        }

        public Gdk.Texture? load_paintable (string image_uri) {
            Gdk.Texture? image = null;

            net_run_wout_code (() => {
                Bytes? bytes = client.get_content_of (image_uri);
                try {
                    image = Gdk.Texture.from_bytes (bytes);
                } catch (Error e) { }
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

        public Playlist? add_track_to_playlist (Track track_info, Playlist playlist_info) {
            return add_tracks_to_playlist ({track_info}, playlist_info);
        }

        //  playlist_info.kind,
        //  track_info,
        //  storager.settings.get_boolean ("add-tracks-to-start") ? 0 : playlist_info.track_count,
        //  playlist_info.revision

        public Playlist? add_tracks_to_playlist (Track[] tracks, Playlist playlist_info) {
            Playlist? new_playlist = null;

            var diff = new DifferenceBuilder ();

            diff.add_insert (
                settings.get_boolean ("add-tracks-to-start") ? 0 : playlist_info.track_count,
                tracks
            );

            net_run_wout_code (() => {
                new_playlist = client.users_playlists_change (
                    null,
                    playlist_info.kind,
                    diff.to_json (),
                    playlist_info.revision
                );
                playlist_changed (new_playlist);
            });

            return new_playlist;
        }

        public Playlist? remove_tracks_from_playlist (string kind, int position, int revision) {
            Playlist? new_playlist = null;

            var diff = new DifferenceBuilder ();

            diff.add_delete (position, position + 1);

            net_run_wout_code (() => {
                new_playlist = client.users_playlists_change (null, kind, diff.to_json (), revision);
                playlist_changed (new_playlist);
            });

            return new_playlist;
        }

        public Playlist? change_playlist_visibility (string kind, bool is_public) {
            Playlist? new_playlist = null;

            net_run_wout_code (() => {
                new_playlist = client.users_playlists_visibility (null, kind, is_public ? "public" : "private");
                playlist_changed (new_playlist);
            });

            return new_playlist;
        }

        public Playlist? create_playlist () {
            Playlist? new_playlist = null;

            net_run_wout_code (() => {
                // Translators: name of new created playlist
                new_playlist = client.users_playlists_create (null, _("New Playlist"));
                playlists_updated ();
            });

            return new_playlist;
        }

        public bool delete_playlist (string kind) {
            bool is_success = false;

            net_run_wout_code (() => {
                playlist_start_delete (kind);
                is_success = client.users_playlists_delete (null, kind);
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
                new_playlist = client.users_playlists_name (null, kind, new_name);
                playlist_changed (new_playlist);
            });

            return new_playlist;
        }

        Gee.ArrayList<YaMAPI.TrackShort>? get_disliked_tracks_short () {
            Gee.ArrayList<YaMAPI.TrackShort>? trackshort_list = null;

            net_run_wout_code (() => {
                trackshort_list = client.users_dislikes_tracks (null);

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
                var tracks = client.tracks (track_ids);
                track_list = new YaMAPI.TrackHeap ();
                track_list.tracks = tracks;
            });

            return track_list;
        }

        public Rotor.StationTracks? start_new_session (
            string station_id
        ) {
            Rotor.StationTracks? station_tracks = null;

            net_run_wout_code (() => {
                var ses_new = new Rotor.SessionNew ();
                ses_new.seeds.add (station_id);

                station_tracks = client.rotor_session_new (ses_new);
            });

            return station_tracks;
        }

        public void send_rotor_feedback (
            string radio_session_id,
            string batch_id,
            string feedback_type,
            string? track_id = null,
            double total_played_seconds = 0.0
        ) {
            net_run_wout_code (() => {
                var feedback_obj = new Rotor.Feedback () {
                    event = new Rotor.Event () {
                        type_ = feedback_type,
                        track_id = track_id,
                        total_played_seconds = total_played_seconds
                    },
                    batch_id = batch_id
                };

                client.rotor_session_feedback (
                    radio_session_id,
                    feedback_obj
                );
            });
        }

        public Rotor.StationTracks? get_session_tracks (
            string radio_session_id,
            Gee.ArrayList<string> queue
        ) {
            Rotor.StationTracks? station_tracks = null;

            net_run_wout_code (() => {
                var ses_queue = new Rotor.Queue () {
                    queue = queue
                };

                station_tracks = client.rotor_session_tracks (radio_session_id, ses_queue);
            });

            return station_tracks;
        }




        public async YaMAPI.Rotor.Dashboard? get_stations_dashboard () {
            YaMAPI.Rotor.Dashboard? dashboard = null;

            threader.add (() => {
                net_run_wout_code (() => {
                    dashboard = client.rotor_stations_dashboard ();
                });

                Idle.add (get_stations_dashboard.callback);
            });

            yield;

            return dashboard;
        }

        public async Gee.ArrayList<YaMAPI.Rotor.Station>? get_all_stations () {
            Gee.ArrayList<YaMAPI.Rotor.Station>? stations_list = null;

            threader.add (() => {
                net_run_wout_code (() => {
                    stations_list = client.rotor_stations_list ();
                });

                Idle.add (get_all_stations.callback);
            });

            yield;

            return stations_list;
        }
    }
}
