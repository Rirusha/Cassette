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
    [GtkTemplate (ui = "/space/rirusha/Cassette/ui/playlist-micro.ui")]
    public class PlaylistMicro : Adw.Bin {
        [GtkChild]
        unowned CoverImage cover_image;
        [GtkChild]
        unowned Gtk.Label playlist_title;
        //  [GtkChild]
        //  unowned Gtk.Label likes_count_label;
        [GtkChild]
        unowned Gtk.Button self;
        //  [GtkChild]
        //  unowned LikeButton like_button;
        //  [GtkChild]
        //  unowned PlayButtonContext play_button;
        //  [GtkChild]
        //  unowned Gtk.Button add_to_queue_button;
        [GtkChild]
        unowned SaveStack save_stack;
        //  [GtkChild]
        //  unowned Gtk.Box buttons_box;
        //  [GtkChild]
        //  unowned Gtk.Stack like_button_stack;

        public BaseView playlists_view { get; set; }
        public YaMAPI.Playlist? short_playlist_info { get; construct; default = null; }

        public PlaylistMicro (BaseView playlists_view, YaMAPI.Playlist? playlist_info) {
            Object (playlists_view: playlists_view, short_playlist_info: playlist_info);
        }

        public PlaylistMicro.empty () {
            Object ();
        }

        construct {
            if (short_playlist_info != null) {

                //  if (short_playlist_info.owner != null) {
                //      if (short_playlist_info.owner.uid != yam_talker.me.oid) {
                //          like_button.notify["likes-count"].connect (() => {
                //              if (like_button.likes_count > 0) {
                //                  likes_count_label.visible = true;
                //                  likes_count_label.label = ngettext ("%s like", "%s likes", like_button.likes_count).printf (
                //                      prettify_num (like_button.likes_count)
                //                  );
                //              } else {
                //                  likes_count_label.visible = false;
                //              }
                //          });
                //      }
                //  }

                self.clicked.connect (() => {
                    playlists_view.root_view.add_view (new PlaylistView (
                        short_playlist_info.uid,
                        short_playlist_info.kind
                    ));
                });

                if (short_playlist_info.uid == yam_talker.me.oid) {
                    yam_talker.playlist_start_delete.connect ((kind) => {
                        if (short_playlist_info.kind == kind) {
                            sensitive = false;
                        }
                    });

                    yam_talker.playlist_stop_delete.connect ((kind) => {
                        if (short_playlist_info.kind == kind) {
                            sensitive = true;
                        }
                    });
                }

                yam_talker.playlist_changed.connect ((new_playlist) => {
                    if (new_playlist.oid == short_playlist_info.oid) {
                        short_playlist_info.cover = new_playlist.cover;
                        short_playlist_info.title = new_playlist.title;

                        set_values ();
                    }
                });

                var motion_controller = new Gtk.EventControllerMotion ();
                add_controller (motion_controller);

                //  motion_controller.enter.connect ((mc, x, y) => {
                //      buttons_box.visible = true;
                //  });
                //  motion_controller.leave.connect ((mc) => {
                //      if (!play_button.is_current_playing) {
                //          buttons_box.visible = false;
                //      }
                //  });

                //  play_button.notify["is-playing"].connect (() => {
                //      if (play_button.is_current_playing) {
                //          buttons_box.visible = true;
                //      } else {
                //          buttons_box.visible = false;
                //      }
                //  });

                //  add_to_queue_button.clicked.connect (() => {
                //      add_to_queue.begin ();
                //  });

                //  play_button.clicked_not_playing.connect (() => {
                //      play.begin ();
                //  });

                set_values ();

            } else {
                sensitive = false;
            }
        }

        void set_values () {
            //  if (short_playlist_info.kind == "3") {
            //      like_button_stack.visible_child_name = "not-show";
            //  } else {
            //      like_button.likes_count = short_playlist_info.likes_count;
            //      like_button.init_content (short_playlist_info.oid);

            //      // Понять, где брать инфу о количестве лайков своих плейлистов (не загружая все плейлисты)
            //      if (short_playlist_info.uid == yam_talker.me.oid) {
            //          like_button_stack.visible_child_name = "not-show";
            //      }
            //  }

            //  like_button.likes_count = short_playlist_info.likes_count;

            if (short_playlist_info.owner != null) {
                if (short_playlist_info.owner.uid != yam_talker.me.oid) {
                    self.tooltip_text = _("Owner: %s").printf (short_playlist_info.owner.get_user_name ());
                }
            }

            if (short_playlist_info.uid == null) {
                var me = yam_talker.me;
                if (me.oid != null) {
                    short_playlist_info.uid = me.oid;
                }
            }
            if (short_playlist_info.uid != null) {
                save_stack.init_content (short_playlist_info.oid);
            }

            playlist_title.label = short_playlist_info.title;

            //  if (short_playlist_info.track_count == 0) {
            //      play_button.sensitive = false;
            //      add_to_queue_button.sensitive = false;
            //  }

            //  play_button.init_content (short_playlist_info.oid);

            cover_image.init_content (short_playlist_info);
            cover_image.load_image.begin ();
    }

        //  async void play () {
        //      YaMAPI.Playlist? playlist_info = null;

        //      threader.add (() => {
        //          playlist_info = get_playlist_info ();

        //          Idle.add (play.callback);
        //      });

        //      yield;

        //      if (playlist_info == null) {
        //          return;
        //      }

        //      var track_list = playlist_info.get_filtered_track_list (
        //          Cassette.settings.get_boolean ("explicit-visible"),
        //          Cassette.settings.get_boolean ("child-visible")
        //      );

        //      player.start_track_list (
        //          track_list,
        //          get_context_type (playlist_info),
        //          playlist_info.oid,
        //          player.shuffle_mode == Player.ShuffleMode.ON ? Random.int_range (0, track_list.size) : 0,
        //          get_context_description (playlist_info)
        //      );
        //  }

        //  public YaMAPI.Playlist? get_playlist_info () {
        //      var playlist_info = (YaMAPI.Playlist) storager.load_object (
        //          typeof (YaMAPI.Playlist),
        //          this.short_playlist_info.oid
        //      );
        //      int soup_code = -1;

        //      if (playlist_info == null) {
        //          try {
        //              playlist_info = yam_talker.get_playlist_info (short_playlist_info.uid, short_playlist_info.kind);
        //          } catch (BadStatusCodeError e) {
        //              soup_code = e.code;
        //          }
        //      }

        //      if (playlist_info == null) {
        //          sensitive = false;
        //      }

        //      if (soup_code != -1) {
        //          playlists_view.root_view.show_error (playlists_view, soup_code);
        //      }

        //      return playlist_info;
        //  }

        //  async void add_to_queue () {
        //      YaMAPI.Playlist? playlist_info = null;

        //      threader.add (() => {
        //          playlist_info = get_playlist_info ();

        //          Idle.add (add_to_queue.callback);
        //      });

        //      yield;

        //      if (playlist_info == null) {
        //          return;
        //      }

        //      var track_list = playlist_info.get_filtered_track_list (
        //          Cassette.settings.get_boolean ("explicit-visible"),
        //          Cassette.settings.get_boolean ("child-visible")
        //      );

        //      player.add_many (track_list);
        //  }
    }
}
