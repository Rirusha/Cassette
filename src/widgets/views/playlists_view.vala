/* playlists_view.vala
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
    [GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/playlists_view.ui")]
    public class PlaylistsView : BaseView {
        [GtkChild]
        unowned Gtk.Label playlists_label;
        [GtkChild]
        unowned Gtk.FlowBox flow_box;
        [GtkChild]
        unowned Gtk.Label liked_playlists_label;
        [GtkChild]
        unowned Gtk.FlowBox likes_flow_box;

        public override bool can_refresh { get; default = true; }

        public override RootView root_view { get; set; }

        public string? uid { get; construct set; }

        PlaylistsView (string? uid) {
            Object (uid: uid);
        }

        construct {
            yam_talker.playlists_updated.connect (() => {
                refresh.begin ();
            });
        }

        void set_values (Gee.ArrayList<YaMAPI.Playlist?>? playlists_info, Gee.ArrayList<YaMAPI.LikedPlaylist?>? likes_playlists_info) {
            while (flow_box.get_last_child () != null) {
                flow_box.remove (flow_box.get_last_child ());
            }
            while (likes_flow_box.get_last_child () != null) {
                likes_flow_box.remove (likes_flow_box.get_last_child ());
            }

            flow_box.append (new PlaylistMicro (this, new YaMAPI.Playlist.liked ()));
            flow_box.append (new PlaylistCreateButton ());

            if (playlists_info != null) {
                if (playlists_info.size == 0) {
                    playlists_label.visible = false;
                }

                foreach (var playlist_info in playlists_info) {
                    if (playlist_info != null) {
                        flow_box.append (new PlaylistMicro (this, playlist_info));
                    } else {
                        flow_box.append (new PlaylistMicro.empty ());
                    }
                }
            } else {
                playlists_label.visible = false;
            }

            if (likes_playlists_info != null) {
                if (likes_playlists_info.size == 0) {
                    liked_playlists_label.visible = false;
                }

                foreach (var liked_playlist in likes_playlists_info) {
                    if (liked_playlist != null) {
                        likes_flow_box.append (new PlaylistMicro (this, liked_playlist.playlist));
                    } else {
                        likes_flow_box.append (new PlaylistMicro.empty ());
                    }
                }
            } else {
                liked_playlists_label.visible = false;
            }

            show_ready ();
        }

        public async override void first_show () {
            yield refresh ();
        }

        public async override int try_load_from_web () {
            Gee.ArrayList<YaMAPI.Playlist>? playlists_info = null;
            Gee.ArrayList<YaMAPI.LikedPlaylist>? liked_playlists_info = null;

            threader.add (() => {
                playlists_info = yam_talker.get_playlist_list (uid);
                liked_playlists_info = yam_talker.get_likes_playlist_list (uid);

                Idle.add (try_load_from_web.callback);
            });

            yield;

            if (playlists_info != null && liked_playlists_info != null) {
                set_values (playlists_info, liked_playlists_info);

                return -1;
            }
            return 0;
        }

        public async override bool try_load_from_cache () {
            var playlists_kinds_str = storager.db.get_additional_data ("my_playlists");
            var playlists_info = new Gee.ArrayList<YaMAPI.Playlist?> ();

            threader.add (() => {
                string uid = yam_talker.me.oid;
                if (playlists_kinds_str != null && uid != null) {
                    string[] playlists_kinds = playlists_kinds_str.split (",");
                    foreach (string kind in playlists_kinds) {
                        string playlist_id = @"$uid:$kind";
                        var playlist_info = (YaMAPI.Playlist) storager.load_object (typeof (YaMAPI.Playlist), playlist_id);
                        playlists_info.add (playlist_info);
                    }
                }

                Idle.add (try_load_from_cache.callback);
            });

            yield;

            if (playlists_info.size > 0) {
                set_values (playlists_info, null);
                return true;
            }
            return false;
        }
    }
}