/* cachier.vala
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

namespace CassetteClient.Cachier {

    public enum JobDoneStatus {
        SUCCESS,
        ABORTED,
        FAILED
    }

    //  Класс представляющий объект для кэширования объекта ямы и его составных частей по интерфейсам
    public class YaMObjectCachier : Object {

        public HasTrackList yam_object { get; construct; }
        public Gtk.ProgressBar? progress_bar { get; construct; }
        //  Для отмены изменяется переменная should_stop, чтобы объект успел докэшировать то, что он кэшировать
        bool should_stop = false;
        bool is_abort;

        string object_id;
        ContentType object_type;

        bool progress_bar_visible = false;

        //  В случае завершения кэширования поднимает сигнал со статусом окончания: завершено с ошибкой, успешно или отменено
        public signal void job_done (JobDoneStatus status);

        public YaMObjectCachier (HasTrackList yam_object) {
            Object (yam_object: yam_object);
        }

        public YaMObjectCachier.with_progress_bar (HasTrackList yam_object, Gtk.ProgressBar progress_bar) {
            Object (yam_object: yam_object, progress_bar: progress_bar);
        }

        construct {
            object_id = ((HasID) yam_object).oid;

            if (yam_object is YaMAPI.Playlist) {
                object_type = ContentType.PLAYLIST;
            } else if (yam_object is YaMAPI.Album) {
                object_type = ContentType.ALBUM;
            } else {
                assert_not_reached ();
            }

            job_done.connect (() => {
                cachier_controller.stop_loading (object_type, object_id, null);
            });
        }

        public async void cache_async () {
            cachier_controller.start_loading (object_type, object_id);

            var need_cache_track_ids = new Gee.ArrayList<string> ();
            var need_uncache_tracks = new Gee.ArrayList<YaMAPI.Track> ();

            var track_list = yam_object.get_filtered_track_list (true, true);

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
                    storager.remove_file (obj_location.path);
                }

                storager.save_object ((HasID) yam_object, false);

                Idle.add (cache_async.callback);
            });

            yield;

            foreach (var track_info in need_uncache_tracks) {
                storager.db.remove_content_ref (track_info.id, object_id);
                if (storager.db.get_content_ref_count (track_info.id) == 0) {
                    yield storager.audio_cache_location (track_info.id).move_to_temp ();
                }

                string image_uri = track_info.get_cover_items_by_size (TRACK_ART_SIZE)[0];
                storager.db.remove_content_ref (image_uri, object_id);
                if (storager.db.get_content_ref_count (image_uri) == 0) {
                    yield storager.image_cache_location (image_uri).move_to_temp ();
                }
            }

            var has_cover_yam_obj = yam_object as HasCover;
            if (has_cover_yam_obj != null) {
                foreach (var cover_uri in has_cover_yam_obj.get_cover_items_by_size (BIG_ART_SIZE)) {
                    var image_location = storager.image_cache_location (cover_uri);
                    if (image_location.path != null) {
                        yield image_location.move_to_perm ();

                    } else {
                        Gdk.Pixbuf? pixbuf = null;

                        threader.add_image (() => {
                            pixbuf = yam_talker.load_pixbuf (cover_uri);

                            Idle.add (cache_async.callback);
                        });

                        yield;

                        if (pixbuf != null) {
                            storager.save_image (pixbuf, cover_uri, false);
                        } else {
                            job_done (JobDoneStatus.FAILED);
                            return;
                        }
                    }

                    storager.db.set_content_ref (cover_uri, object_id);
                }
            }

            for (int i = 0; i < track_list.size; i++) {
                if (progress_bar != null && progress_bar_visible) {
                    progress_bar.visible = true;
                    progress_bar.fraction = (double) i / (double) track_list.size;
                }

                YaMAPI.Track track_info = track_list[i];
                string image_cover_uri = track_info.get_cover_items_by_size (TRACK_ART_SIZE)[0];

                cachier_controller.start_loading (ContentType.TRACK, track_info.id);

                var image_location = storager.image_cache_location (image_cover_uri);
                if (image_location.path != null) {
                    if (image_location.is_tmp == true) {
                        progress_bar_visible = true;
                        yield image_location.move_to_perm ();
                    }
                } else {
                    Gdk.Pixbuf? pixbuf = null;

                    threader.add_image (() => {
                        pixbuf = yam_talker.load_pixbuf (image_cover_uri);

                        Idle.add (cache_async.callback);
                    });

                    yield;

                    if (pixbuf != null) {
                        progress_bar_visible = true;
                        storager.save_image (pixbuf, image_cover_uri, false);
                    } else {
                        job_done (JobDoneStatus.FAILED);
                        return;
                    }
                }

                storager.db.set_content_ref (image_cover_uri, track_info.id);

                if (should_stop) {
                    if (is_abort) {
                        yield uncache_async ();
                        job_done (JobDoneStatus.ABORTED);
                    }
                    return;
                }

                var track_location = storager.audio_cache_location (track_info.id);
                if (track_location.path != null) {
                    if (track_location.is_tmp == true) {
                        progress_bar_visible = true;
                        yield track_location.move_to_perm ();
                    }

                } else {
                    string? track_uri = null;

                    threader.add_image (() => {
                        track_uri = yam_talker.get_download_uri (track_info.id, true);

                        Idle.add (cache_async.callback);
                    });

                    yield;

                    if (track_uri != null) {
                        Bytes? audio_bytes = null;

                        threader.add_image (() => {
                            audio_bytes = yam_talker.load_track (track_uri);

                            Idle.add (cache_async.callback);
                        });

                        yield;

                        if (audio_bytes != null) {
                            progress_bar_visible = true;
                            storager.save_audio (audio_bytes, track_info.id, false);
                        }
                    } else {
                        job_done (JobDoneStatus.FAILED);
                        return;
                    }
                }

                storager.db.set_content_ref (track_info.id, object_id);
                cachier_controller.stop_loading (ContentType.TRACK, track_info.id, CacheingState.PERM);

                if (should_stop) {
                    if (is_abort) {
                        yield uncache_async ();
                        job_done (JobDoneStatus.ABORTED);
                    }
                    return;
                }

                Idle.add (cache_async.callback);
                yield;
            }
            job_done (JobDoneStatus.SUCCESS);
        }

        public async void uncache_async () {
            string object_id = ((HasID) yam_object).oid;

            var has_cover_yam_obj = yam_object as HasCover;
            if (has_cover_yam_obj != null) {
                foreach (var cover_uri in has_cover_yam_obj.get_cover_items_by_size (BIG_ART_SIZE)) {
                    storager.db.remove_content_ref (cover_uri, object_id);

                    if (storager.db.get_content_ref_count (cover_uri) == 0) {
                        var image_location = storager.image_cache_location (cover_uri);
                        yield image_location.move_to_temp ();
                    }
                }
            }

            var yam_object_with_id = yam_object as HasID;
            if (yam_object_with_id != null) {
                var object_location = storager.object_cache_location (yam_object_with_id.get_type (), yam_object_with_id.oid);
                yield object_location.move_to_temp ();
                if (storager.settings.get_boolean ("can-cache")) {
                    cachier_controller.change_state (ContentType.PLAYLIST, object_id, CacheingState.TEMP);
                } else {
                    cachier_controller.change_state (ContentType.PLAYLIST, object_id, CacheingState.NONE);
                }

            }

            var track_list = yam_object.get_filtered_track_list (true, true);

            foreach (var track_info in track_list) {
                string image_cover_uri = track_info.get_cover_items_by_size (TRACK_ART_SIZE)[0];
                storager.db.remove_content_ref (image_cover_uri, track_info.id);
                if (storager.db.get_content_ref_count (image_cover_uri) == 0) {
                    var image_location = storager.image_cache_location (image_cover_uri);
                    yield image_location.move_to_temp ();
                }

                storager.db.remove_content_ref (track_info.id, object_id);
                if (storager.db.get_content_ref_count (track_info.id) == 0) {
                    var track_location = storager.audio_cache_location (track_info.id);
                    yield track_location.move_to_temp ();
                    if (track_location.path != null && storager.settings.get_boolean ("can-cache")) {
                        cachier_controller.change_state (ContentType.TRACK, track_info.id, CacheingState.TEMP);
                    } else {
                        cachier_controller.change_state (ContentType.TRACK, track_info.id, CacheingState.NONE);
                    }
                }

                Idle.add (uncache_async.callback);
                yield;
            }
        }

        public void abort () {
            should_stop = true;
            is_abort = true;
        }

        public void stop () {
            should_stop = true;
            is_abort = false;
        }
    }
}
