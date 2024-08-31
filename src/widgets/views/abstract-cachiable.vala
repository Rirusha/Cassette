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


using Cassette.Client;

namespace Cassette {
    public abstract class CachiableView : HasTracksView {
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
                                var content_info = get_content_info (object_info, true, true);
                                // Translators: first %s - content type (Playlist), second - name
                                if (yell_status) {
                                    application.show_message (_("%s%s successfully cached").printf (
                                        content_info[0],
                                        content_info[1]
                                    ));
                                }
                                download_stack.visible_child_name = "delete";
                                break;

                            case Cachier.JobDoneStatus.FAILED:
                                var content_info = get_content_info (object_info, false, true);
                                // Translators: first %s - content type (Playlist), second - name
                                application.show_message (_("Caching of %s%s was canceled, due to network error")
                                    .printf (
                                        content_info[0],
                                        content_info[1]
                                    ));
                                download_stack.visible_child_name = "save";
                                break;

                            case Cachier.JobDoneStatus.ABORTED:
                                var content_info = get_content_info (object_info, false, true);
                                // Translators: first %s - content type (Playlist), second - name
                                application.show_message (_("Caching of %s%s was aborted").printf (
                                    content_info[0],
                                    content_info[1]
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

        string[] get_content_info (HasTrackList obj_info, bool first_big, bool with_title) {
            string content_name = "";
            string content_title = "";

            var playlist_info = obj_info as YaMAPI.Playlist;
            if (playlist_info != null) {
                content_name = _("Playlist");
                content_name = first_big? content_name : content_name.down ();
                if (with_title) {
                    content_title = " '%s'".printf (playlist_info.title);
                }
            } else {
                var album_info = obj_info as YaMAPI.Album;
                if (album_info != null) {
                    content_name = _("Album");
                    content_name = first_big? content_name : content_name.down ();
                    if (with_title) {
                        content_title += " '%s'".printf (album_info.title);
                    }
                } else {
                    assert_not_reached ();
                }
            }

            return {content_name, content_title};
        }

        protected void start_saving (bool yell_status) {
            download_stack.visible_child_name = "abort";
            this.yell_status = yell_status;

            job = cachier.start_cache (object_info);

            if (yell_status) {
                var content_info = get_content_info (object_info, false, false);
                // Translators: first %s - content type (Playlist), second - name
                application.show_message (_("Caching of %s%s started").printf (content_info[0], content_info[1]));
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
                    var content_info = get_content_info (object_info, true, true);
                    // Translators: first %s - content type (Playlist), second - name
                    application.show_message (_("%s%s was removed from cache folder").printf (
                        content_info[0],
                        content_info[1]
                    ));
                }
            });

            if (yell_status) {
                var content_info = get_content_info (object_info, true, false);
                // Translators: first %s - content type (Playlist), second - name
                application.show_message (_("%s%s is removing, please do not close the app").printf (
                    content_info[0],
                    content_info[1]
                ));
            }
        }
    }
}
