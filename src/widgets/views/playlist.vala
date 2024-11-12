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
    [GtkTemplate (ui = "/space/rirusha/Cassette/ui/playlist-view.ui")]
    public class PlaylistView : CachiableView {
        [GtkChild]
        unowned SaveStack save_stack;
        [GtkChild]
        unowned Gtk.ScrolledWindow scrolled_window;
        [GtkChild]
        unowned CoverImage cover_image;
        [GtkChild]
        unowned Gtk.Label duration_label;
        //  [GtkChild]
        //  unowned Gtk.Entry playlist_name_entry;
        [GtkChild]
        unowned Gtk.Label playlist_name_label;
        [GtkChild]
        unowned Gtk.Label playlist_desc_label;
        [GtkChild]
        unowned Gtk.Label playlist_status;
        [GtkChild]
        unowned Gtk.Button play_button;
        [GtkChild]
        unowned PlayMarkContext play_mark_context;
        [GtkChild]
        unowned LikeButton like_button;
        [GtkChild]
        unowned Gtk.Button save_button;
        [GtkChild]
        unowned Gtk.Button delete_button;
        [GtkChild]
        unowned Gtk.Button abort_button;
        [GtkChild]
        unowned Gtk.Button add_page_button;
        [GtkChild]
        unowned Gtk.Box main_box;
        [GtkChild]
        unowned PlaylistOptionsButton playlist_options_button;
        [GtkChild]
        unowned Gtk.Switch visibility_switch;
        [GtkChild]
        unowned Gtk.Button edit_button;
        [GtkChild]
        unowned Gtk.Button remove_button;

        public override bool can_refresh { get; default = true; }

        public string? uid { get; construct set; }
        public string kind { get; construct set; }

        public PlaylistView (string? uid, string kind) {
            Object (uid: uid, kind: kind);
        }

        construct {
            visibility_switch.state_set.connect (on_switch_change);

            if (yam_talker.is_me (uid) && kind != "3") {
                visibility_switch.visible = true;
                remove_button.visible = true;

                remove_button.clicked.connect (() => {
                    var dialog = new Adw.AlertDialog (
                        _("Delete playlist?"),
                        _("Playlist '%s' will be permanently deleted.").printf (((YaMAPI.Playlist) object_info).title)
                    );

                    // Translators: cancel of deleting playlist
                    dialog.add_response ("cancel", _("Cancel"));
                    dialog.add_response ("delete", _("Delete"));

                    dialog.set_response_appearance ("delete", Adw.ResponseAppearance.DESTRUCTIVE);

                    dialog.default_response = "cancel";
                    dialog.close_response = "cancel";

                    dialog.response.connect ((dialog, response) => {
                        if (response == "delete") {
                            playlist_delete_async.begin ((obj, res) => {
                                if (playlist_delete_async.end (res)) {
                                    root_view.backward ();
                                    application.main_window.pager.remove_page (object_info.oid);

                                    application.show_message (_("Playlist '%s' was deleted").printf (
                                        ((YaMAPI.Playlist) object_info).title
                                    ));
                                }
                            });
                        }
                    });

                    dialog.present (application.main_window);
                });
            }

            //  playlist_name_entry.activate.connect (() => {
            //      string old_playlist_title = ((YaMAPI.Playlist) object_info).title;

            //      if (old_playlist_title == "") {
            //          application.show_message (_("Playlist name can't be empty"));
            //          return;
            //      }

            //      playlist_name_entry_activate_async.begin ((obj, res) => {
            //          var new_playlist_info = playlist_name_entry_activate_async.end (res);

            //          application.show_message (_("Playlist '%s' was renamed to '%s'").printf (
            //              old_playlist_title, new_playlist_info.title
            //          ));
            //      });
            //  });

            track_list = new TrackList (scrolled_window.vadjustment);
            main_box.append (track_list);

            save_button.clicked.connect (() => {
                start_saving (true);
            });
            abort_button.clicked.connect (abort_saving);
            delete_button.clicked.connect (() => {
                uncache_playlist (true);
            });

            play_button.clicked.connect (play_mark_context.trigger);

            play_mark_context.triggered_not_playing.connect (start_playing);

            if (kind != "3" || (uid != null && uid != yam_talker.me.oid)) {
                add_page_button.visible = true;
                add_page_button.clicked.connect (() => {
                    var playlist_info = object_info as YaMAPI.Playlist;
                    application.main_window.pager.add_custom_page ({
                        playlist_info.oid,
                        playlist_info.title,
                        "multimedia-player-symbolic",
                        typeof (PlaylistView).name (),
                        {uid, kind}
                    });
                });
            }

            yam_talker.playlist_changed.connect ((new_playlist) => {
                if (new_playlist.oid == ((YaMAPI.Playlist) object_info).oid) {
                    object_info = new_playlist;
                    set_values ();
                }
            });

            block_widget (edit_button, BlockReason.NOT_IMPLEMENTED);
            block_widget (like_button, BlockReason.NOT_IMPLEMENTED);
        }

        //  async YaMAPI.Playlist? playlist_name_entry_activate_async () {
        //      YaMAPI.Playlist? new_playlist = null;

        //      threader.add (() => {
        //          new_playlist = yam_talker.change_playlist_name (kind, playlist_name_entry.text);

        //          Idle.add (playlist_name_entry_activate_async.callback);
        //      });

        //      yield;

        //      return new_playlist;
        //  }

        public async bool playlist_delete_async () {
            bool success = false;

            threader.add (() => {
                success = yam_talker.delete_playlist (kind);

                Idle.add (playlist_delete_async.callback);
            });

            yield;

            if (success) {
                uncache_playlist (false);
            }

            return success;
        }

        void set_values () {
            var playlist_info = object_info as YaMAPI.Playlist;

            if (playlist_info.owner.uid == yam_talker.me.oid && playlist_info.kind != "3") {
                edit_button.visible = true;
            }

            visibility_switch.state_set.disconnect (on_switch_change);
            visibility_switch.active = playlist_info.is_public;
            visibility_switch.state_set.connect (on_switch_change);

            action_set_enabled ("playlist.share", playlist_info.is_public);

            //  playlist_name_entry.text = playlist_info.title;
            playlist_name_label.label = playlist_info.title;

            if (playlist_info.description != null) {
                playlist_desc_label.label = playlist_info.description;
            }
            if (playlist_info.kind == "3") {
                like_button.visible = false;
            } else {
                like_button.likes_count = playlist_info.likes_count;

                // Понять, где брать инфу о количестве лайков своих плейлистов (не загружая все плейлисты)
                if (playlist_info.uid == yam_talker.me.oid) {
                    like_button.visible = false;
                }
            }

            duration_label.label = ms2str (playlist_info.duration_ms, false);

            if (playlist_info.kind == "3") {
                if (playlist_info.owner.uid == yam_talker.me.oid) {
                    playlist_status.visible = false;
                } else {
                    playlist_status.label = _("Owner: %s").printf (playlist_info.owner.name);
                }
            } else {
                string format_string;
                if (playlist_info.owner.sex == "female") {
                    // Translators: %s is female person
                    format_string = C_ ("female person", "%s updated playlist %s");

                } else {
                    // Translators: %s is male person
                    format_string = C_ ("male person", "%s updated playlist %s");
                }

                playlist_status.label = format_string.printf (playlist_info.owner.name, get_when (playlist_info.modified));
            }

            var ptrack_list = playlist_info.get_track_list ();
            if (!track_list.compare_tracks (ptrack_list)) {
                track_list.set_tracks_default (ptrack_list, playlist_info);
            }

            if (playlist_info.track_count > 0) {
                play_button.sensitive = true;
            } else {
                play_button.sensitive = false;
            }

            like_button.init_content (playlist_info.oid);
            save_stack.init_content (playlist_info.oid);
            play_mark_context.init_content (playlist_info.oid);
            playlist_options_button.playlist_info = playlist_info;

            show_ready ();
        }

        public bool on_switch_change (Gtk.Switch sw, bool is_active) {
            on_switch_change_async.begin (is_active, (obj, res) => {
                YaMAPI.Playlist? playlist_info = on_switch_change_async.end (res);

                if (playlist_info == null) {
                    application.show_message (_("Can't change visibility of '%s'").printf (playlist_info.title));
                    return;
                }

                visibility_switch.state_set.disconnect (on_switch_change);
                if (playlist_info.is_public) {
                    application.show_message (_("Playlist '%s' is public now").printf (playlist_info.title));
                    visibility_switch.active = true;
                } else {
                    application.show_message (_("Playlist '%s' is private now").printf (playlist_info.title));
                    visibility_switch.active = false;
                }
                visibility_switch.state_set.connect (on_switch_change);
            });
            return false;
        }

        async YaMAPI.Playlist? on_switch_change_async (bool is_active) {
            YaMAPI.Playlist? playlist_info = null;

            threader.add (() => {
                playlist_info = yam_talker.change_playlist_visibility (((YaMAPI.Playlist) object_info).kind, is_active);

                Idle.add (on_switch_change_async.callback);
            });

            yield;

            return playlist_info;
        }

        public async override int try_load_from_web () {
            int code = 0;

            threader.add (() => {
                try {
                    object_info = yam_talker.get_playlist_info_old (uid, kind);
                } catch (BadStatusCodeError e) {
                    code = e.code;
                }

                Idle.add (try_load_from_web.callback);
            });

            yield;

            if (object_info != null) {
                set_values ();

                cover_image.init_content ((HasCover) this.object_info);
                cover_image.load_image.begin ();
                return -1;
            }
            return code;
        }

        public async override bool try_load_from_cache () {
            if (uid == null) {
                if (yam_talker.me.oid == null) {
                    return false;
                }
                uid = yam_talker.me.oid;
            }

            threader.add (() => {
                object_info = (YaMAPI.Playlist) storager.load_object (typeof (YaMAPI.Playlist), @"$uid:$kind");

                Idle.add (try_load_from_cache.callback);
            });

            yield;

            if (object_info != null) {
                set_values ();

                cover_image.init_content ((HasCover) this.object_info);
                cover_image.load_image.begin ();
                return true;
            }
            return false;
        }
    }
}
