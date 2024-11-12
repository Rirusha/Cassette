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


namespace Cassette.Client.Cachier {

    public enum JobDoneStatus {
        SUCCESS,
        ABORTED,
        FAILED
    }

    //  Класс представляющий объект для кэширования объекта ямы и его составных частей по интерфейсам
    public class Job : Object {

        public HasTrackList yam_object { get; construct; }

        public string object_id { get; construct; }
        public ContentType object_type { get; construct; }
        public string object_title { get; construct; }

        int _now_saving_tracks_count = 0;
        public int now_saving_tracks_count {
            get {
                return _now_saving_tracks_count;
            }
            private set {
                _now_saving_tracks_count = value;

                if (cancellable.is_cancelled () && value == 0) {
                    unsave_async.begin (() => {
                        Idle.add (() => {
                            job_done (JobDoneStatus.ABORTED);

                            return Source.REMOVE;
                        }, Priority.HIGH_IDLE);
                    });
                }
            }
        }

        public signal void track_saving_started (
            int saved_tracks_count,
            int total_tracks_count,
            int now_saving_tracks_count);

        public signal void track_saving_ended (
            int saved_tracks_count,
            int total_tracks_count,
            int now_saving_tracks_count
        );

        JobDoneStatus? done_status = null;

        public int saved_tracks_count { get; private set; default = 0; }
        public int total_tracks_count { get; private set; default = 1; }

        //  Для отмены изменяется переменная should_stop, чтобы объект успел докэшировать то, что он кэширует
        Cancellable cancellable = new Cancellable ();

        public bool is_cancelled {
            get {
                return cancellable.is_cancelled ();
            }
        }

        public signal void cancelled ();

        /**
         * В случае завершения кэширования поднимает сигнал со статусом окончания:
         * завершено с ошибкой, успешно или отменено
         */
        public signal void job_done (JobDoneStatus status);

        // Сделано значимое действие. Например, не проверка, сохранен ли трек, а его загрузка.
        public signal void action_done ();

        public Job (HasTrackList yam_object) {
            Object (yam_object: yam_object);
        }

        construct {
            object_id = yam_object.oid;

            if (yam_object is YaMAPI.Playlist) {
                object_type = ContentType.PLAYLIST;
                object_title = ((YaMAPI.Playlist) yam_object).title;

            } else if (yam_object is YaMAPI.Album) {
                object_type = ContentType.ALBUM;
                object_title = ((YaMAPI.Album) yam_object).title;

            } else {
                assert_not_reached ();
            }

            cancellable.cancelled.connect (() => {
                cancelled ();
            });

            job_done.connect ((status) => {
                done_status = status;
                cachier.controller.stop_loading (object_type, object_id, null);

                switch (status) {
                    case JobDoneStatus.SUCCESS:
                        Logger.debug ("Job %s.%s was finished with success".printf (
                            object_type.to_string (),
                            yam_object.oid
                        ));
                        break;
                    case JobDoneStatus.ABORTED:
                        Logger.debug ("Job %s.%s was aborted".printf (
                            object_type.to_string (),
                            yam_object.oid
                        ));
                        break;
                    case JobDoneStatus.FAILED:
                        Logger.debug ("Job %s.%s was failed".printf (
                            object_type.to_string (),
                            yam_object.oid
                        ));
                        break;
                }
            });

            Logger.debug ("Job %s.%s was created".printf (object_type.to_string (), yam_object.oid));
        }

        public void abort () {
            cancellable.cancel ();
        }

        public async void abort_with_wait () {
            job_done.connect (() => {
                Idle.add (abort_with_wait.callback);
            });

            abort ();

            yield;
        }

        public async void save_async () {
            cachier.controller.start_loading (object_type, object_id);

            var need_cache_track_ids = new Gee.ArrayList<string> ();
            var need_uncache_tracks = new Gee.ArrayList<YaMAPI.Track> ();

            var track_list = yam_object.get_filtered_track_list (true, true);

            Logger.debug ("Job %s.%s was started".printf (
                object_type.to_string (),
                yam_object.oid
            ));

            threader.add (() => {
                foreach (var track_info in track_list) {
                    need_cache_track_ids.add (track_info.id);
                }

                var obj_location = storager.object_cache_location (yam_object.get_type (), object_id);
                if (obj_location.is_tmp == false) {
                    var cachied_obj_wt = (HasTrackList) storager.load_object (yam_object.get_type (), object_id);

                    var cachied_obj_track_list = cachied_obj_wt.get_filtered_track_list (true, true);

                    foreach (var track_info in cachied_obj_track_list) {
                        if (!(track_info.id in need_cache_track_ids)) {
                            need_uncache_tracks.add (track_info);
                        }
                    }

                } else {
                    if (obj_location.file != null) {
                        storager.remove_file (obj_location.file);
                    }
                }

                storager.save_object (yam_object, false);

                Logger.debug ("Job %s.%s, object saved".printf (
                    object_type.to_string (),
                    yam_object.oid
                ));

                Idle.add (save_async.callback);
            });

            yield;

            // Удаление из кэшей треков, которые были удалены из объекта вне текущего клиента
            foreach (var track_info in need_uncache_tracks) {
                storager.db.remove_content_ref (track_info.id, object_id);
                if (storager.db.get_content_ref_count (track_info.id) == 0) {
                    yield storager.audio_cache_location (track_info.id).move_to_temp_async ();
                }

                var cover_items = track_info.get_cover_items_by_size (CoverSize.SMALL);

                if (cover_items.size != 0) {
                    string image_uri = cover_items[0];
                    storager.db.remove_content_ref (image_uri, object_id);
                    if (storager.db.get_content_ref_count (image_uri) == 0) {
                        yield storager.image_cache_location (image_uri).move_to_temp_async ();
                    }

                    Logger.debug ("Job %s.%s, track %s in db was fixed".printf (
                        object_type.to_string (),
                        yam_object.oid,
                        track_info.form_debug_info ()
                    ));
                }
            }

            threader.add_image (() => {
                var has_cover_yam_obj = yam_object as HasCover;
                if (has_cover_yam_obj != null) {
                    foreach (var cover_uri in has_cover_yam_obj.get_cover_items_by_size (CoverSize.BIG)) {
                        var image_location = storager.image_cache_location (cover_uri);
                        if (image_location.file != null) {
                            image_location.move_to_perm ();

                        } else {
                            Gdk.Pixbuf? pixbuf = null;

                            pixbuf = yam_talker.load_pixbuf (cover_uri);

                            if (pixbuf != null) {
                                storager.save_image (pixbuf, cover_uri, false);
                            } else {
                                Idle.add (() => {
                                    job_done (JobDoneStatus.FAILED);

                                    return Source.REMOVE;
                                }, Priority.HIGH_IDLE);

                                Idle.add (save_async.callback);
                                return;
                            }
                        }

                        storager.db.set_content_ref (cover_uri, object_id);
                    }

                    Logger.debug ("Job %s.%s, cover of object saved".printf (
                        object_type.to_string (),
                        yam_object.oid
                    ));
                }

                Idle.add (save_async.callback);
            });

            yield;

            total_tracks_count = track_list.size;
            foreach (var track_info in track_list) {
                save_track_async.begin (track_info);
            }

            if (total_tracks_count == 0) {
                Idle.add_once (() => {
                    job_done (JobDoneStatus.SUCCESS);
                });
            }
        }

        public async void unsave_async () {
            Logger.debug ("Job %s.%s, uncache object started".printf (
                object_type.to_string (),
                yam_object.oid
            ));

            string object_id = yam_object.oid;

            var has_cover_yam_obj = yam_object as HasCover;
            if (has_cover_yam_obj != null) {
                foreach (var cover_uri in has_cover_yam_obj.get_cover_items_by_size (CoverSize.BIG)) {
                    storager.db.remove_content_ref (cover_uri, object_id);

                    if (storager.db.get_content_ref_count (cover_uri) == 0) {
                        var image_location = storager.image_cache_location (cover_uri);
                        yield image_location.move_to_temp_async ();
                    }
                }
            }

            var object_location = storager.object_cache_location (yam_object.get_type (), yam_object.oid);
            yield object_location.move_to_temp_async ();
            if (settings.get_boolean ("can-cache")) {
                cachier.controller.change_state (object_type, object_id, CacheingState.TEMP);
            } else {
                cachier.controller.change_state (object_type, object_id, CacheingState.NONE);
            }

            var track_list = yam_object.get_filtered_track_list (true, true);

            foreach (var track_info in track_list) {
                var cover_items = track_info.get_cover_items_by_size (CoverSize.SMALL);

                if (cover_items.size != 0) {
                    string image_cover_uri = cover_items[0];
                    storager.db.remove_content_ref (image_cover_uri, track_info.id);
                    if (storager.db.get_content_ref_count (image_cover_uri) == 0) {
                        var image_location = storager.image_cache_location (image_cover_uri);
                        yield image_location.move_to_temp_async ();
                    }
                }

                storager.db.remove_content_ref (track_info.id, object_id);
                if (storager.db.get_content_ref_count (track_info.id) == 0) {
                    var track_location = storager.audio_cache_location (track_info.id);
                    yield track_location.move_to_temp_async ();
                    if (track_location.file != null && settings.get_boolean ("can-cache")) {
                        cachier.controller.change_state (ContentType.TRACK, track_info.id, CacheingState.TEMP);
                    } else {
                        cachier.controller.change_state (ContentType.TRACK, track_info.id, CacheingState.NONE);
                    }
                }

                Idle.add (unsave_async.callback);
                yield;
            }

            Logger.debug ("Job %s.%s, uncache object finished".printf (
                object_type.to_string (),
                yam_object.oid
            ));
        }

        async void save_track_async (YaMAPI.Track track_info) {
            Logger.debug ("Job %s.%s, saving track %s was started".printf (
                object_type.to_string (),
                yam_object.oid,
                track_info.form_debug_info ()
            ));

            threader.add_cache (() => {
                lock (now_saving_tracks_count) {
                    now_saving_tracks_count++;
                    Idle.add_once (() => {
                        track_saving_started (saved_tracks_count, total_tracks_count, now_saving_tracks_count);
                    });
                }

                Logger.debug ("Job %s.%s, audio of track %s was started".printf (
                    object_type.to_string (),
                    yam_object.oid,
                    track_info.form_debug_info ()
                ));

                Idle.add (() => {
                    cachier.controller.start_loading (ContentType.TRACK, track_info.id);

                    return Source.REMOVE;
                }, Priority.HIGH_IDLE);

                var track_location = storager.audio_cache_location (track_info.id);
                if (track_location.file != null) {
                    if (track_location.is_tmp == true) {
                        track_location.move_to_perm ();

                        Idle.add_once (() => {
                            action_done ();
                        });
                    }

                } else {
                    string? track_uri = null;

                    track_uri = yam_talker.get_download_uri (track_info.id, true);

                    if (track_uri != null) {
                        Bytes? audio_bytes = null;

                        audio_bytes = yam_talker.load_track (track_uri);

                        if (audio_bytes != null) {
                            storager.save_audio (audio_bytes, track_info.id, false);

                            Idle.add_once (() => {
                                action_done ();
                            });
                        }
                    } else {
                        cancellable.cancel ();
                        Idle.add (() => {
                            job_done (JobDoneStatus.FAILED);

                            return Source.REMOVE;
                        }, Priority.HIGH_IDLE);

                        Idle.add (save_track_async.callback);
                        return;
                    }
                }

                storager.db.set_content_ref (track_info.id, object_id);

                Logger.debug ("Job %s.%s, audio of track %s was saved".printf (
                    object_type.to_string (),
                    yam_object.oid,
                    track_info.form_debug_info ()
                ));

                Logger.debug ("Job %s.%s, cover of track %s was started".printf (
                    object_type.to_string (),
                    yam_object.oid,
                    track_info.form_debug_info ()
                ));

                var cover_items = track_info.get_cover_items_by_size (CoverSize.SMALL);

                if (cover_items.size != 0) {
                    string image_cover_uri = cover_items[0];
                    var image_location = storager.image_cache_location (image_cover_uri);
                    if (image_location.file != null) {
                        if (image_location.is_tmp == true) {
                            image_location.move_to_perm ();

                            Idle.add_once (() => {
                                action_done ();
                            });
                        }

                    } else {
                        Gdk.Pixbuf? pixbuf = null;

                        pixbuf = yam_talker.load_pixbuf (image_cover_uri);

                        if (pixbuf != null) {
                            storager.save_image (pixbuf, image_cover_uri, false);

                            Idle.add_once (() => {
                                action_done ();
                            });

                        } else {
                            cancellable.cancel ();
                            Idle.add (() => {
                                job_done (JobDoneStatus.FAILED);

                                return Source.REMOVE;
                            }, Priority.HIGH_IDLE);

                            Idle.add (save_track_async.callback);
                            return;
                        }
                    }

                    storager.db.set_content_ref (image_cover_uri, track_info.id);

                    Logger.debug ("Job %s.%s, cover of track %s was saved".printf (
                        object_type.to_string (),
                        yam_object.oid,
                        track_info.form_debug_info ()
                    ));
                }

                Idle.add (() => {
                    cachier.controller.stop_loading (ContentType.TRACK, track_info.id, CacheingState.PERM);

                    Logger.debug ("Job %s.%s, saving track %s was finished".printf (
                        object_type.to_string (),
                        yam_object.oid,
                        track_info.form_debug_info ()
                    ));

                    return Source.REMOVE;
                }, Priority.HIGH_IDLE);

                lock (now_saving_tracks_count) {
                    now_saving_tracks_count--;
                }

                Idle.add (save_track_async.callback);
            }, cancellable);

            yield;

            lock (saved_tracks_count) {
                saved_tracks_count++;
            }

            Idle.add_once (() => {
                track_saving_ended (saved_tracks_count, total_tracks_count, now_saving_tracks_count);
            });

            if (!cancellable.is_cancelled ()) {
                lock (saved_tracks_count) {
                    Idle.add_once (() => {
                        if (saved_tracks_count == total_tracks_count && done_status == null) {
                            job_done (JobDoneStatus.SUCCESS);
                        }
                    });
                }
            }

            Idle.add (save_track_async.callback);
            yield;
        }
    }
}
