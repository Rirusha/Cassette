/* sidebar.vala
 *
 * Copyright 2023-2024 Rirusha
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
        unowned Adw.OverlaySplitView root_flap;
        [GtkChild]
        public unowned Gtk.ScrolledWindow sidebar_content;

        TrackList?_track_list = null;
        public TrackList? track_list {
            get {
                return _track_list;
            }
            set {
                sidebar_content.child = value;
                _track_list = value;
            }
        }

        TrackDetailed? _track_detailed = null;
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

        bool _is_shown;
        public bool is_shown {
            get {
                return _is_shown;
            }
            set {
                _is_shown = value;

                if (!_is_shown) {
                    clear ();
                }
            }
        }
        public bool collapsed { get; set; }

        public SideBar () {
            Object ();
        }

        construct {
            sidebar_content.notify["child"].connect (() => {
                if (sidebar_content.child != null) {
                    is_shown = true;
                }
            });

            this.bind_property ("is-shown", root_flap, "show-sidebar", GLib.BindingFlags.BIDIRECTIONAL);
            this.bind_property ("collapsed", root_flap, "collapsed", GLib.BindingFlags.BIDIRECTIONAL);

            player.queue_changed.connect (update_queue);
        }

        public void close () {
            is_shown = false;
        }

        public void show_track_info (YaMAPI.Track track_info) {
            clear ();

            if (track_info.available) {
                track_detailed = new TrackDetailed (track_info);
            }
        }

        public void show_queue () {
            clear ();

            if (player.player_type == Player.PlayerModeType.TRACK_LIST) {
                track_list = new TrackList (sidebar_content.vadjustment) {
                    margin_top = 12,
                    margin_bottom = 12,
                    margin_start = 12,
                    margin_end = 12
                };
                update_queue (player.get_queue ());
            }
        }

        void update_queue (YaMAPI.Queue queue) {
            if (track_list != null) {
                track_list.set_tracks_as_queue (queue.tracks);
                Idle.add (() => {
                    track_list.move_to (queue.current_index, queue.tracks.size);
                    return Source.REMOVE;
                });

                track_list.title.visible = true;
                switch (queue.context.type_) {
                    case "playlist":
                        track_list.list_type_label.label = _("PLAYLIST");
                        track_list.list_name_label.label = queue.context.description;
                        break;
                    case "my_music":
                        track_list.list_type_label.label = "PLAYLIST";
                        track_list.list_name_label.label = _("Liked");
                        break;
                    case "album":
                        track_list.list_type_label.label = _("ALBUM");
                        track_list.list_name_label.label = queue.context.description;
                        break;
                    case "search":
                        track_list.list_type_label.label = _("SEARCH RESULTS");
                        track_list.list_name_label.label = "\"%s\"".printf (queue.context.description);
                        break;
                    default:
                        track_list.list_type_label.label = "";
                        track_list.list_name_label.label = _("Track list");
                        break;
                }
            }
        }

        void clear () {
            if (track_list != null) {
                track_list.clear_all ();
                track_list = null;
            }
            if (track_detailed != null) {
                track_detailed = null;
            }
        }
    }
}
