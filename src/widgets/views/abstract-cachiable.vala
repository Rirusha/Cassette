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


using Cassette.Client;

namespace Cassette {
    public abstract class CachiableView : HasTracksView {

        internal struct ContentInfo {
            public string content_name;
            public string content_title;
        }

        public Gtk.Stack download_stack { get; set; }
        Gtk.Overlay overlay { get; default = new Gtk.Overlay (); }
        public Gtk.ProgressBar saving_progress_bar { get; default = new Gtk.ProgressBar (); }

        public new Gtk.Widget child {
            get {
                return overlay.child;
            }
            set {
                overlay.child = value;
            }
        }

        Cachier.Job? _job = null;
        Cachier.Job? job {
            get {
                return _job;
            }
            set {
                _job = value;

                if (_job != null) {
                    _job.action_done.connect (() => {
                        if (!saving_progress_bar.visible) {
                            saving_progress_bar.visible = true;
                        }
                    });

                    _job.cancelled.connect (() => {
                        download_stack.sensitive = false;
                    });

                    download_stack.set_visible_child_name ("abort");

                    if (_job.is_cancelled) {
                        download_stack.sensitive = false;
                    }
                    download_stack.sensitive = !_job.is_cancelled;

                    _job.track_saving_ended.connect ((saved, total) => {
                        saving_progress_bar.fraction = (double) saved / (double) total;
                    });

                    _job.job_done.connect ((obj, status) => {
                        switch (status) {
                            case Cachier.JobDoneStatus.SUCCESS:
                                var content_info = get_content_info (object_info);
                                // Translators: first %s - content type (Playlist), second - name
                                if (yell_status) {
                                    application.show_message (_("%s '%s' saved successfully").printf (
                                        content_info.content_name,
                                        content_info.content_title
                                    ));
                                }
                                download_stack.visible_child_name = "delete";
                                break;

                            case Cachier.JobDoneStatus.FAILED:
                                var content_info = get_content_info (object_info);
                                // Translators: first %s - content type (Playlist), second - name
                                application.show_message (_("%s '%s' saving was stopped, due to network error").printf (
                                    content_info.content_name,
                                    content_info.content_title
                                ));
                                download_stack.visible_child_name = "save";
                                break;

                            case Cachier.JobDoneStatus.ABORTED:
                                var content_info = get_content_info (object_info);
                                // Translators: first %s - content type (Playlist), second - name
                                application.show_message (_("%s '%s' saving was aborted").printf (
                                    content_info.content_name,
                                    content_info.content_title
                                ));
                                download_stack.visible_child_name = "save";
                                break;
                        }

                        download_stack.sensitive = true;
                        saving_progress_bar.fraction = 0;
                        saving_progress_bar.visible = false;

                        _job = null;
                    });
                }
            }
        }

        bool yell_status = true;

        construct {
            base.child = overlay;

            saving_progress_bar.add_css_class ("osd");
            saving_progress_bar.visible = false;

            saving_progress_bar.valign = Gtk.Align.START;
            saving_progress_bar.vexpand = false;

            overlay.add_overlay (saving_progress_bar);
        }

        public async override void first_show () {
            download_stack.sensitive = false;
            bool cache_success = yield try_load_from_cache ();
            int soup_code = yield try_load_from_web ();
            if (!cache_success) {
                if (soup_code != -1) {
                    root_view.show_error (this, soup_code);
                } else {
                    check_cache ();
                }
            } else {
                if (soup_code == -1) {
                    check_cache ();
                }
            }
        }

        public async override void refresh () {
            int soup_code = yield try_load_from_web ();
            if (soup_code != -1) {
                bool cache_success = yield try_load_from_cache ();
                if (!cache_success) {
                    root_view.show_error (this, soup_code);
                    return;
                }
            } else {
                check_cache ();
            }
        }

        ContentInfo get_content_info (HasTrackList obj_info) {
            string content_name = "";
            string content_title = "";

            if (obj_info is YaMAPI.Playlist) {
                var playlist_info = obj_info as YaMAPI.Playlist;
                content_name = _("Playlist");
                content_title = playlist_info.title;

            } else if (obj_info is YaMAPI.Album) {
                var album_info = obj_info as YaMAPI.Album;
                content_name = _("Album");
                content_title = album_info.title;

            } else {
                assert_not_reached ();
            }

            return {content_name, content_title};
        }

        protected void start_saving (bool yell_status) {
            download_stack.visible_child_name = "abort";
            this.yell_status = yell_status;

            job = cachier.start_cache (object_info);

            if (yell_status) {
                var content_info = get_content_info (object_info);
                // Translators: %s - content type (e.g. "Playlist")
                application.show_message (_("%s saving has started").printf (
                    content_info.content_name
                ));
            }
        }

        protected virtual void check_cache () {
            download_stack.sensitive = true;

            if (job == null) {
                job = cachier.find_job (object_info.oid);

                if (job == null) {
                    var location = storager.object_cache_location (object_info.get_type (), object_info.oid);
                    if (!location.is_tmp) {
                        start_saving (false);
                    }
                }
            }
        }

        public virtual void abort_saving () {
            if (job != null) {
                job.abort ();
            }
        }

        public virtual void uncache_playlist (bool yell_status) {
            download_stack.sensitive = false;
            this.yell_status = yell_status;

            cachier.uncache.begin (object_info, () => {
                download_stack.visible_child_name = "save";
                download_stack.sensitive = true;

                if (yell_status) {
                    var content_info = get_content_info (object_info);
                    // Translators: first %s - content type (Playlist), second - name
                    application.show_message (_("%s '%s' was moved from data to cache").printf (
                        content_info.content_name,
                        content_info.content_title
                    ));
                }
            });

            if (yell_status) {
                var content_info = get_content_info (object_info);
                // Translators: first %s - content type (Playlist), second - name
                application.show_message (_("%s removing has started. Please do not close the app").printf (
                    content_info.content_name
                ));
            }
        }
    }
}
