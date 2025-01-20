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
using Gee;


namespace Cassette {
    //  Кнопка лайка
    public class LikeButton : CustomButton, Initable {

        protected string content_id { get; set; }
        public LikableType object_content_type { get; construct; }

        bool is_liked {
            get {
                return icon_name == "like-symbolic";
            }
            set {
                if (value) {
                    if (!is_liked && should_change_likes_count && likes_count != -1) {
                        likes_count++;
                    }

                    icon_name = "like-symbolic";
                    real_button.tooltip_text = _("Remove like");
                } else {
                    if (is_liked && should_change_likes_count && likes_count != -1) {
                        likes_count--;
                    }

                    icon_name = "not-like-symbolic";
                    real_button.tooltip_text = _("Set like");
                }

                should_change_likes_count = true;
            }
        }

        bool should_change_likes_count = false;

        int _likes_count = -1;
        public int likes_count {
            get {
                return _likes_count;
            }
            set {
                _likes_count = value;

                if (show_label) {
                    if (_likes_count > 0) {
                        label = prettify_num (_likes_count);
                    } else {
                        label = "";
                    }
                }
            }
        }

        public bool show_label { get; construct; default = true; }

        public LikeButton (LikableType object_content_type) {
            Object (object_content_type: object_content_type);
        }

        public LikeButton.without_label (LikableType object_content_type) {
            Object (object_content_type: object_content_type, show_label: false);
        }

        construct {
            valign = Gtk.Align.CENTER;
            halign = Gtk.Align.CENTER;

            //  is_liked = false;

            // Ставится false, так как should_change_likes_count меняется во время выставления is_liked на true
            // выше, что в свою очередь нужно для корректного отображения при неполадках с сетью
            //  should_change_likes_count = false;

            real_button.clicked.connect (like_dislike);

            yam_talker.track_likes_start_change.connect (liked_start_change);
            yam_talker.track_likes_end_change.connect (liked_changed);
            yam_talker.track_dislikes_start_change.connect ((track_id) => {
                if (track_id == content_id) {
                    real_button.sensitive = false;
                }
            });
            yam_talker.track_dislikes_end_change.connect ((track_id) => {
                if (track_id == content_id) {
                    real_button.sensitive = true;
                }
            });

            application.application_state_changed.connect (application_state_changed);
        }

        public void init_content (string content_id) {
            this.content_id = content_id;
            check_liked ();

            application_state_changed (application.application_state, application.application_state);
        }

        void check_liked () {
            if (content_id != null) {
                is_liked = yam_talker.likes_controller.get_content_is_liked (object_content_type, content_id);
            }
        }

        void application_state_changed (ApplicationState new_state, ApplicationState old_state) {
            switch (new_state) {
                case ApplicationState.ONLINE:
                    real_button.sensitive = true;
                    check_liked ();
                    break;

                case ApplicationState.OFFLINE:
                    real_button.sensitive = false;
                    break;

                default:
                    break;
            }
        }

        public void liked_start_change (string track_id) {
            if (content_id == null) {
                return;
            }
            if (track_id == content_id) {
                real_button.sensitive = false;
            }
        }

        public void liked_changed (string track_id, bool is_liked) {
            if (content_id == null) {
                return;
            }

            if (track_id == content_id) {
                this.is_liked = is_liked;
                real_button.sensitive = true;
            }
        }

        async void like_dislike () {
            assert (content_id != null);

            real_button.sensitive = false;

            if (is_liked) {
                yield yam_talker.unlike (object_content_type, content_id);

            } else {
                yield yam_talker.like (object_content_type, content_id);
            }
        }
    }
}
