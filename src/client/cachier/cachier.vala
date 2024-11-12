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

    public class Cachier : Object {
        public ArrayList<Job> job_list { get; default = new ArrayList<Job> (); }

        public Controller controller { get; default = new Controller (); }

        public signal void job_started (Job job);

        public signal void job_added (Job job);
        public signal void job_removed (Job job);

        public Cachier () {
            Object ();
        }

        public async void uncache (HasTrackList yam_obj) {
            /**
                Удалить или переместить во временную папку объект с треками
            */

            var job = new Job (yam_obj);

            yield job.unsave_async ();
        }

        public Job start_cache (HasTrackList yam_obj) {
            /**
                Начать сохранение объекта с треками
            */

            var job = new Job (yam_obj);
            job_list.add (job);
            job_added (job);

            job.job_done.connect (() => {
                job_list.remove (job);
                job_removed (job);
            });

            job.save_async.begin ();

            job_started (job);

            return job;
        }

        public Job? find_job (string yam_obj_id) {
            /**
                Находит job в списке job'ов. Если таковой нет, возвращает null
            */

            foreach (var job in job_list) {
                if (yam_obj_id == job.yam_object.oid) {
                    return job;
                }
            }

            return null;
        }

        public async void check_all_cache () {
            Logger.debug ("Started full saves check");

            var objs = storager.get_saved_objects ();

            foreach (var obj in objs) {
                HasTrackList new_obj = null;

                threader.add (() => {
                    if (obj is YaMAPI.Playlist) {
                        var pl_obj = (YaMAPI.Playlist) obj;

                        try {
                            new_obj = yam_talker.get_playlist_info (pl_obj.playlist_uuid);
                        } catch (BadStatusCodeError e) { }

                    } else {
                        assert_not_reached ();
                    }

                    Idle.add (check_all_cache.callback);
                });

                yield;

                if (new_obj != null) {
                    start_cache (new_obj);
                }
            }
        }

        public async void uncache_all () {
            var objs = storager.get_saved_objects ();

            foreach (var job in job_list) {
                yield job.abort_with_wait ();
            }

            foreach (var obj in objs) {
                yield uncache (obj);
            }
        }
    }

    ///////////
    // utils //
    ///////////

    public async static void save_track (YaMAPI.Track track_info) {
        /**
            Функция удобства, объединяющая сохранение аудио и изображения
        */

        download_audio_async.begin (track_info.id);
        get_image.begin (track_info, (int) CoverSize.SMALL);
    }

    public async static void download_audio_async (
        string track_id,
        owned string? track_uri = null,
        bool is_tmp = true) {
        /**
            Скачивание аудио по его id. Если не передан uri трека, то uri будет самостоятельно загружен.
            Аргумент is_tmp определяет место, куда будет загружено аудио
        */

        if (storager.audio_cache_location (track_id).file != null) {
            cachier.controller.stop_loading (ContentType.TRACK, track_id, null);
            return;
        }

        cachier.controller.start_loading (ContentType.TRACK, track_id);

        CacheingState? cacheing_state = null;

        threader.add_audio (() => {
            if (track_uri == null) {
                track_uri = yam_talker.get_download_uri (
                    track_id,
                   settings.get_boolean ("is-hq")
                );
            }

            if (track_uri != null && (settings.get_boolean ("can-cache") || !is_tmp)) {
                Bytes audio_bytes = yam_talker.load_track (track_uri);
                if (audio_bytes != null) {
                    storager.save_audio (audio_bytes, track_id, is_tmp);
                    if (is_tmp) {
                        cacheing_state = CacheingState.TEMP;
                    } else {
                        cacheing_state = CacheingState.PERM;
                    }
                }
            }

            Idle.add (download_audio_async.callback);
        });

        yield;

        cachier.controller.stop_loading (ContentType.TRACK, track_id, cacheing_state);
    }

    public async static string? get_track_uri (string track_id) {
        /**
            Выдает uri трека: локальный, если трек сохранен; интернет ссылку в ином случае.
            Если трек не был сохранен, то сохраняет его
        */

        string? track_uri = null;

        threader.add_audio (() => {
            track_uri = storager.load_audio (track_id);

            Idle.add (get_track_uri.callback);
        });

        yield;

        if (track_uri != null) {
            return track_uri;
        }

        threader.add_audio (() => {
            track_uri = yam_talker.get_download_uri (
                track_id,
            settings.get_boolean ("is-hq")
            );

            Idle.add (get_track_uri.callback);
        });

        yield;

        if (track_uri != null) {
            download_audio_async.begin (track_id, track_uri);
        }

        return track_uri;
    }

    // Получение изображения ямобъекта, если есть, иначе получение из сети и сохранение
    public async static Gdk.Pixbuf? get_image (HasCover yam_object, int size) {
        /**
            Выдает объект Pixbuf с артом трека. Если изображение не найдено локально, загружает его.
            Если арт не был сохранен, то сохраняет его
        */

        Gee.ArrayList<string> cover_uris = yam_object.get_cover_items_by_size (size);
        if (cover_uris.size == 0) {
            return null;
        }

        var pixbufs = new Gdk.Pixbuf?[cover_uris.size];

        threader.add_image (() => {
            for (int i = 0; i < cover_uris.size; i++) {

                if (cover_uris[i] != null) {
                    pixbufs[i] = storager.load_image (cover_uris[i]);

                    if (pixbufs[i] == null) {
                        pixbufs[i] = yam_talker.load_pixbuf (cover_uris[i]);

                        if (pixbufs[i] != null && settings.get_boolean ("can-cache")) {
                        storager.save_image (pixbufs[i], cover_uris[i], true);
                        }
                    }

                } else {
                    // Непонятна причина непустого массива с null внутри
                    // https://github.com/Rirusha/Cassette/issues/52
                    Logger.info ("Hello, send this to developer: %s, %d".printf (
                        yam_object.get_type ().to_string (),
                        cover_uris.size
                    ));
                }
            }

            Idle.add (get_image.callback);
        });

        yield;

        if (null in pixbufs) {
            return null;
        }

        if (pixbufs.length == 1) {
            return pixbufs[0];
        }

        int new_size = size / 2;
        var pixbuf = new Gdk.Pixbuf (Gdk.Colorspace.RGB, true, 8, size, size);

        if (pixbufs.length >= 2) {
            pixbufs[0].composite (
                pixbuf,
                0,
                0, new_size,
                new_size,
                0,
                0,
                0.5,
                0.5,
                Gdk.InterpType.BILINEAR,
                255
            );
            pixbufs[1].composite (
                pixbuf,
                new_size,
                0,
                new_size,
                new_size,
                new_size,
                0,
                0.5,
                0.5,
                Gdk.InterpType.BILINEAR,
                255
            );
        }

        if (pixbufs.length >= 3) {
            pixbufs[2].composite (
                pixbuf,
                0,
                new_size,
                new_size,
                new_size,
                0,
                new_size,
                0.5,
                0.5,
                Gdk.InterpType.BILINEAR,
                255
            );
        } else {
            pixbufs[1].composite (
                pixbuf,
                0,
                new_size,
                new_size,
                new_size,
                0,
                new_size,
                0.5,
                0.5,
                Gdk.InterpType.BILINEAR,
                255
            );
            pixbufs[0].composite (
                pixbuf,
                new_size,
                new_size,
                new_size,
                new_size,
                new_size,
                new_size,
                0.5,
                0.5,
                Gdk.InterpType.BILINEAR,
                255
            );

            return pixbuf;
        }

        if (pixbufs.length == 4) {
            pixbufs[3].composite (
                pixbuf,
                new_size,
                new_size,
                new_size,
                new_size,
                new_size,
                new_size,
                0.5,
                0.5,
                Gdk.InterpType.BILINEAR,
                255
            );
        } else {
            pixbufs[0].composite (
                pixbuf,
                new_size,
                new_size,
                new_size,
                new_size,
                new_size,
                new_size,
                0.5,
                0.5,
                Gdk.InterpType.BILINEAR,
                255);
        }
        return pixbuf;
    }
}
