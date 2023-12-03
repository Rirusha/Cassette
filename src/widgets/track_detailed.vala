/* track_detailed.vala
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
using Gee;


namespace Cassette {
    [GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/track_detailed.ui")]
    public class TrackDetailed : Adw.Bin {
        [GtkChild]
        private unowned Gtk.Label track_name_label;
        [GtkChild]
        private unowned Gtk.Label track_version_label;
        [GtkChild]
        private unowned Adw.Bin album_socket;
        [GtkChild]
        private unowned Gtk.FlowBox artists_box;
        [GtkChild]
        private unowned Gtk.Label ugc_mark;
        [GtkChild]
        private unowned LyricsPanel lyrics_panel;
        [GtkChild]
        private unowned Gtk.Label writers_label;
        [GtkChild]
        private unowned Gtk.Label major_label;
        [GtkChild]
        private unowned Gtk.Spinner spin;
        [GtkChild]
        private unowned Gtk.Stack loading_stack;
        [GtkChild]
        private unowned Gtk.Box add_box;
        [GtkChild]
        private unowned Gtk.Box lyrics_box;
        [GtkChild]
        private unowned Gtk.Box similar_box;
        [GtkChild]
        private unowned PlayButtonTrack play_button;
        [GtkChild]
        private unowned SaveStack save_stack;
        [GtkChild]
        private unowned LikeButton like_button;
        [GtkChild]
        private unowned DislikeButton dislike_button;
        [GtkChild]
        private unowned Gtk.Box album_box;
        [GtkChild]
        private unowned Gtk.Box artists_main_box;

        public YaMAPI.Track track_info { get; construct set; }

        public TrackDetailed (YaMAPI.Track track_info) {
            Object (track_info: track_info);
        }

        construct {
            add_box.bind_property ("visible", spin, "spinning", GLib.BindingFlags.INVERT_BOOLEAN);

            track_name_label.label = track_info.title;
            if (track_info.version != null) {
                track_version_label.label = track_info.version;
            } else {
                track_version_label.visible = false;
            }

            play_button.clicked_not_playing.connect (play_pause);

            var actions = new SimpleActionGroup ();

            if (track_info.ugc == false) {
                SimpleAction share_action = new SimpleAction ("share", null);
                share_action.activate.connect (() => {
                    track_share (track_info);
                });
                actions.add_action (share_action);
            }

            SimpleAction add_next_action = new SimpleAction ("add-next", null);
            add_next_action.activate.connect (() => {
                player.add_track (track_info, true);
            });
            actions.add_action (add_next_action);

            SimpleAction add_end_action = new SimpleAction ("add-end", null);
            add_end_action.activate.connect (() => {
                player.add_track (track_info, false);
            });
            actions.add_action (add_end_action);

            SimpleAction add_to_playlist_action = new SimpleAction ("add-to-playlist", null);
            add_to_playlist_action.activate.connect (() => {
                var win = new PlaylistChooseWindow (track_info) {
                    transient_for = Cassette.application.main_window,
                };
                win.present ();
            });
            actions.add_action (add_to_playlist_action);

            insert_action_group ("track", actions);

            LabelButton sbutton;
            if (track_info.ugc) {
                ugc_mark.visible = true;
                dislike_button.visible = false;

                if (track_info.meta_data.album != null) {
                    album_socket.child = new LabelButton (track_info.meta_data.album, false);
                } else {
                    album_box.visible = false;
                }

                if (track_info.get_artists_names () != "") {
                    artists_box.append (new LabelButton (track_info.get_artists_names (), false));
                } else {
                    artists_main_box.visible = false;
                }

            } else {
                dislike_button.visible = true;
                sbutton = new LabelButton (track_info.albums[0].title, true);
                album_socket.child = sbutton;
                sbutton.button.clicked.connect (() => {
                    message ("Show album page");
                    //  applicationance.main_window.current_view.add_view (...)
                });
                block_widget (sbutton, BlockReason.NOT_IMPLEMENTED);

                foreach (var artist in track_info.artists) {
                    sbutton = new LabelButton (artist.name, true);
                    artists_box.append (sbutton);
                    sbutton.button.clicked.connect (() => {
                        message ("Show artist page");
                        //  applicationance.main_window.current_view.add_view (...)
                    });
                    block_widget (sbutton, BlockReason.NOT_IMPLEMENTED);
                }
            }

            lyrics_panel.track_id = track_info.id;

            play_button.init_content (track_info.id);
            dislike_button.init_content (track_info.id);
            like_button.init_content (track_info.id);
            save_stack.init_content (track_info.id);

            load_content.begin ();
        }

        async void load_content () {
            YaMAPI.SimilarTracks? similar_tracks = null;
            YaMAPI.Lyrics? lyrics = null;

            threader.add (() => {
                similar_tracks = yam_talker.get_track_similar (track_info.id);

                if (track_info.lyrics_info != null) {
                    if (track_info.lyrics_info.has_available_sync_lyrics) {
                        lyrics = yam_talker.get_lyrics (track_info.id, true);
                    } else if (track_info.lyrics_info.has_available_text_lyrics) {
                        lyrics = yam_talker.get_lyrics (track_info.id, false);
                    }
                }

                Idle.add (load_content.callback);
            });

            yield;

            set_values (similar_tracks, lyrics);
        }

        void set_values (YaMAPI.SimilarTracks? similar_tracks, YaMAPI.Lyrics? lyrics) {
            if (lyrics != null) {
                if (lyrics.is_sync) {
                    lyrics_panel.set_sync_lyrics_lines (lyrics.text.to_array ());
                } else {
                    lyrics_panel.set_text_lyrics_lines (lyrics.text.to_array ());
                }
                writers_label.label = lyrics.get_writers_names ();
                major_label.label = lyrics.major.pretty_name;
            } else {
                lyrics_box.visible = false;
            }
            
            if (similar_tracks != null) {
                if (similar_tracks.similar_tracks.size != 0) {
                    var track_list = new TrackList.simple ();
                    similar_box.append (track_list);
                    track_list.set_tracks_default (similar_tracks.similar_tracks, similar_tracks);
                } else {
                    similar_box.visible = false;
                }
            } else {
                similar_box.visible = false;
            }

            loading_stack.visible_child_name = "loaded";
        }

        private void play_pause () {
            var track_list = new Gee.ArrayList<YaMAPI.Track> ();
            track_list.add (track_info);

            var queue = new YaMAPI.Queue () {
                context = new YaMAPI.Context.various (),
                tracks = track_list,
                current_index = 0
            };

            player.start_queue (queue);
        }
    }
}