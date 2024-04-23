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
using Gee;


namespace Cassette {
    //  Кнопка дизлайка
    public class DislikeButton : CustomButton, Initable {

        protected string content_id { get; set; }

        public bool is_disliked {
            get {
                return !real_button.has_css_class ("dim-label");
            }
            set {
                if (value) {
                    if (!is_disliked) {
                        real_button.remove_css_class ("dim-label");
                        real_button.tooltip_text = _("Remove dislike");
                    }
                } else {
                    if (is_disliked) {
                        real_button.add_css_class ("dim-label");
                        real_button.tooltip_text = _("Set dislike");
                    }
                }
            }
        }

        public DislikeButton () {
            Object ();
        }

        construct {
            valign = Gtk.Align.CENTER;
            halign = Gtk.Align.CENTER;

            is_disliked = false;

            real_button.icon_name = "adwaita-disliked-symbolic";
            real_button.add_css_class ("dim-label");
            real_button.clicked.connect (like_dislike);

            yam_talker.track_dislikes_start_change.connect (disliked_start_change);
            yam_talker.track_dislikes_end_change.connect (disliked_changed);
            yam_talker.track_likes_start_change.connect ((track_id) => {
                if (track_id == content_id) {
                    real_button.sensitive = false;
                }
            });
            yam_talker.track_likes_end_change.connect ((track_id) => {
                if (track_id == content_id) {
                    real_button.sensitive = true;
                }
            });

            application.application_state_changed.connect (application_state_changed);
        }

        public void init_content (string content_id) {
            this.content_id = content_id;
            check_disliked ();

            application_state_changed (application.application_state);
        }

        void check_disliked () {
            if (content_id != null) {
                is_disliked = yam_talker.likes_controller.get_content_is_disliked (content_id);
            }
        }

        void application_state_changed (ApplicationState new_state) {
            switch (new_state) {
                case ApplicationState.ONLINE:
                    real_button.sensitive = true;
                    check_disliked ();
                    break;
                case ApplicationState.OFFLINE:
                    real_button.sensitive = false;
                    break;
                default:
                    break;
            }
        }

        public void disliked_start_change (string track_id) {
            if (content_id == null) {
                return;
            }
            if (track_id == content_id) {
                real_button.sensitive = false;
            }
        }

        public void disliked_changed (string track_id, bool is_disliked) {
            if (content_id == null) {
                return;
            }

            if (track_id == content_id) {
                this.is_disliked = is_disliked;
                real_button.sensitive = true;

                if (is_disliked && player.mode.get_current_track_info ().id == track_id) {
                    player.next ();
                }
            }
        }

        async void like_dislike () {
            assert (content_id != null);

            real_button.sensitive = false;

            threader.add (() => {
                if (is_disliked) {
                    yam_talker.undislike (content_id);
                } else {
                    yam_talker.dislike (content_id);
                }

                Idle.add (like_dislike.callback);
            });

            yield;
        }
    }
}
