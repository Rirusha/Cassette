/* sidebar.vala
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
    [GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/sidebar.ui")]
    public class SideBar : Adw.Bin {
        [GtkChild]
        private unowned Adw.OverlaySplitView root_flap;
        [GtkChild]
        public unowned Gtk.ScrolledWindow sidebar_content;
        [GtkChild]
        private unowned Gtk.Button close_button;
        [GtkChild]
        private unowned Gtk.Button clean_button;

        private TrackList?_track_list = null;
        public TrackList? track_list {
            get {
                return _track_list;
            }
            set {
                sidebar_content.child = value;
                _track_list = value;
            }
        }

        private TrackDetailed? _track_detailed = null;
        public TrackDetailed? track_detailed {
            get {
                return _track_detailed;
            }
            set {
                sidebar_content.child = value;
                _track_detailed = value;
            }
        }

        public Gtk.Widget content {
            get {
                return root_flap.content;
            }
            set {
                root_flap.content = value;
            }
        }

        public bool is_shown { get; set; }
        public bool collapsed { get; set; }

        public SideBar () {
            Object ();
        }

        construct {
            close_button.clicked.connect (close);
            clean_button.clicked.connect (player.remove_all_tracks);

            sidebar_content.notify["child"].connect (() => {
                root_flap.show_sidebar = true;
            });

            this.bind_property ("is-shown", root_flap, "show-sidebar", GLib.BindingFlags.BIDIRECTIONAL);
            this.bind_property ("collapsed", root_flap, "collapsed", GLib.BindingFlags.DEFAULT);

            player.queue_changed.connect (update_queue);
        }

        public void close () {
            clear ();
            root_flap.show_sidebar = false;
        }

        public void show_track_info (YaMAPI.Track track_info) {
            if (track_info.available) {
                clear ();
                track_detailed = new TrackDetailed (track_info);
            }
        }

        public void show_queue () {             
            clear ();
            clean_button.visible = true;
            var playertl = player.player_mod as Player.PlayerTL;
            if (playertl != null) {
                track_list = new TrackList (sidebar_content.vadjustment) {
                    margin_top = 12,
                    margin_bottom = 12,
                    margin_start = 12,
                    margin_end = 12
                };
                update_queue ();
            }
        }

        private void update_queue () {
            if (track_list != null) {
                var playertl = player.player_mod as Player.PlayerTL;

                track_list.set_tracks_as_queue (playertl.queue.tracks);
                Idle.add (() => {
                    track_list.move_to (playertl.queue.current_index, playertl.queue.tracks.size);
                    return Source.REMOVE;
                });

                track_list.title.visible = true;
                switch (playertl.queue.context.type_) {
                    case "playlist":
                        track_list.list_type_label.label = _("PLAYLIST");
                        track_list.list_name_label.label = playertl.queue.context.description;
                        break;
                    case "my_music":
                        track_list.list_type_label.label = "PLAYLIST";
                        track_list.list_name_label.label = _("Liked");
                        break;
                    case "album":
                        track_list.list_type_label.label = _("ALBUM");
                        track_list.list_name_label.label = playertl.queue.context.description;
                        break;
                    case "search":
                        track_list.list_type_label.label = _("SEARCH RESULTS");
                        track_list.list_name_label.label = "\"%s\"".printf (playertl.queue.context.description);
                        break;
                    default:
                        track_list.list_type_label.label = "";
                        track_list.list_name_label.label = _("Track list");
                        break;
                }
            }
        }

        private void clear () {
            if (track_list != null) {
                track_list.clear_all ();
                track_list = null;
            }
            if (track_detailed != null) {
                track_detailed = null;
            }
            clean_button.visible = false;
        }
    }
}