/* cachiable_view.vala
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


using CassetteClient;


namespace Cassette {
    public abstract class CachiableView : HasTracksView {
        protected Gtk.Stack download_stack { get; set; }
        protected Gtk.ProgressBar loading_progress_bar { get; set; }

        Cachier.YaMObjectCachier? yamc = null;

        construct {
            cachier_controller.content_cache_state_changed.connect ((content_type, content_id) => {
                if (object_info == null) {
                    return;
                }

                if (content_type == Cachier.ContentType.PLAYLIST || content_type == Cachier.ContentType.ALBUM) {
                    if (((YaMAPI.Playlist) object_info).oid == content_id && yamc == null) {
                        download_stack.sensitive = false;
                        download_stack.tooltip_text = _("Cache state of this object was changed out of this view. Please refresh");
                    }
                }
            });
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

        string[] get_content_name (HasTrackList obj_info, bool first_big, bool with_title) {
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

        public virtual void start_saving (bool tell_status) {
            if (yamc != null) {
                yamc.stop ();
                yamc = null;
            }

            download_stack.visible_child_name = "abort";

            yamc = new Cachier.YaMObjectCachier.with_progress_bar (object_info, loading_progress_bar);
            yamc.job_done.connect ((obj, status) => {
                switch (status) {
                    case Cachier.JobDoneStatus.SUCCESS:
                        if (tell_status) {
                            var content_info = get_content_name (yamc.yam_object, true, true);
                            // Translators: first %s - content type (Playlist), second - name
                            application.show_message (_("%s%s successfully cached").printf (content_info[0], content_info[1]), true);
                        }
                        download_stack.visible_child_name = "delete";
                        break;
                    case Cachier.JobDoneStatus.FAILED:
                        var content_info = get_content_name (yamc.yam_object, false, true);
                        // Translators: first %s - content type (Playlist), second - name
                        application.show_message (_("Caching of %s%s was canceled, due to network error").printf (content_info[0], content_info[1]));
                        download_stack.visible_child_name = "save";
                        break;
                    case Cachier.JobDoneStatus.ABORTED:
                        var content_info = get_content_name (yamc.yam_object, false, true);
                        // Translators: first %s - content type (Playlist), second - name
                        application.show_message (_("Caching of %s%s was aborted").printf (content_info[0], content_info[1]));
                        download_stack.visible_child_name = "save";
                        break;
                }
                download_stack.sensitive = true;
                loading_progress_bar.fraction = 0;
                loading_progress_bar.visible = false;
                yamc = null;
            });
            yamc.cache_async.begin ();

            if (tell_status) {
                var content_info = get_content_name (yamc.yam_object, false, false);
                // Translators: first %s - content type (Playlist), second - name
                application.show_message (_("Cacheing of %s%s started").printf (content_info[0], content_info[1]));
            }
        }

        public virtual void abort_saving () {
            download_stack.sensitive = false;
            yamc.abort ();
        }

        public virtual void uncache_playlist (bool tell_status) {
            download_stack.sensitive = false;
            yamc = new Cachier.YaMObjectCachier (object_info);

            yamc.uncache_async.begin (() => {
                download_stack.visible_child_name = "save";
                download_stack.sensitive = true;

                if (tell_status) {
                    var content_info = get_content_name (yamc.yam_object, true, true);
                    // Translators: first %s - content type (Playlist), second - name
                    application.show_message (_("%s%s was removed from cache folder").printf (content_info[0], content_info[1]), true);
                }
            });

            if (tell_status) {
                var content_info = get_content_name (yamc.yam_object, true, false);
                // Translators: first %s - content type (Playlist), second - name
                application.show_message (_("%s%s is removing, please do not close the app").printf (content_info[0], content_info[1]));
            }
        }

        public virtual void check_cache () {
            var location = storager.object_cache_location (object_info.get_type (), ((HasID) object_info).oid);
            if (location.is_tmp == false) {
                start_saving (false);
            }
            download_stack.sensitive = true;
        }
    }
}