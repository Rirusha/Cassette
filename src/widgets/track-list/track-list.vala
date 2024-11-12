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
    public enum SortType {
        NAME,
        ARTISTS,
        ALBUM,
        DURATION
    }

    public enum SortDirection {
        ASCENDING,
        DESCENDING
    }

    protected class TrackRowW : Gtk.FlowBoxChild {

        public YaMAPI.Track track_info { get; construct; }
        public HasTrackList yam_object { get; construct; }

        public TrackRowW (YaMAPI.Track track_info, HasTrackList yam_object) {
            Object (track_info: track_info, yam_object: yam_object);
        }

        construct {
            can_focus = false;
            vexpand = false;

            child = new TrackPlaceholder ();
        }

        public virtual void load_content () {
            child = new TrackDefault (track_info, yam_object);
        }

        public virtual void unload_content () {
            child = new TrackPlaceholder ();
        }
    }

    protected class TrackRowBase : TrackRowW {

        public TrackRowBase (YaMAPI.Track track_info, HasTrackList yam_object) {
            Object (track_info: track_info, yam_object: yam_object);
        }

        public override void load_content () {
            child = new TrackBase (track_info, yam_object);
        }
    }

    protected class TrackRowDis : TrackRowW {

        public TrackRowDis (YaMAPI.Track track_info, HasTrackList yam_object) {
            Object (track_info: track_info, yam_object: yam_object);
        }

        public override void load_content () {
            child = new TrackDefault.with_dislike_button (track_info, yam_object);
        }
    }

    protected class TrackQueueRow : TrackPositionRow {

        public TrackQueueRow (YaMAPI.Track track_info, int position) {
            Object (track_info: track_info, position: position);
        }

        //  construct {
        //      var drag_src = new Gtk.DragSource ();
        //      drag_src.actions = Gdk.DragAction.MOVE;

        //      drag_src.prepare.connect ((source, x, y) => {
        //          message ("prepare");

        //          return new Gdk.ContentProvider.for_value (position);
        //      });
        //      drag_src.drag_begin.connect ((source, drag) => {
        //          message ("begin");

        //          source.set_icon (new Gtk.Image.from_icon_name ("folder-music-symbolic").paintable, 0, 0);
        //      });
        //      drag_src.drag_end.connect ((drag) => {
        //          message ("end");
        //      });

        //      add_controller (drag_src);
        //  }

        public override void load_content () {
            child = new TrackQueue (track_info, position);
        }
    }

    protected class TrackPositionRow : TrackRowW {

        public int position { get; set; }

        public TrackPositionRow (YaMAPI.Track track_info, int position) {
            Object (track_info: track_info, position: position);
        }

        public override void load_content () {
            //  bin.child = new TrackPosition (track_info);
        }
    }

    [GtkTemplate (ui = "/space/rirusha/Cassette/ui/track-list.ui")]
    public class TrackList : Adw.Bin {

        [GtkChild]
        unowned Gtk.Box search_box;
        [GtkChild]
        unowned Gtk.SearchEntry search_entry;
        [GtkChild]
        unowned Gtk.Button sort_direction_button;
        [GtkChild]
        unowned Gtk.Button remove_sort_button;
        [GtkChild]
        public unowned Gtk.FlowBox track_box;
        [GtkChild]
        unowned Adw.StatusPage status_page;

        public int length {
            get {
                return filtered_rows.size;
            }
        }

        ArrayList<TrackRowW> original_track_rows = new ArrayList<TrackRowW> ();
        ArrayList<TrackRowW> sorted_rows = new ArrayList<TrackRowW> ();
        ArrayList<TrackRowW> filtered_rows = new ArrayList<TrackRowW> ();
        HashSet<int> loaded_rows = new HashSet<int> ();

        private YaMAPI.TrackType track_type = YaMAPI.TrackType.MUSIC;

        public SortType? sort_type = null;
        SortDirection sort_direction = SortDirection.ASCENDING;

        public Gtk.Adjustment adjustment { get; construct set; }

        bool is_queue = false;

        public TrackList (Gtk.Adjustment adjustment) {
            Object (adjustment: adjustment);
        }

        public TrackList.simple () {
            Object ();
            search_box.visible = false;
        }

        construct {
            track_box.bind_property ("visible", status_page, "visible", GLib.BindingFlags.INVERT_BOOLEAN);

            if (adjustment != null) {
                adjustment.changed.connect (load_chunk);
                adjustment.value_changed.connect (load_chunk);

                map.connect (load_chunk);
                unmap.connect (unload_all);

                search_entry.search_changed.connect (() => {
                    filter ();
                    loaded_rows.clear ();
                });

                Cassette.settings.changed.connect ((key) => {
                    if (key == "explicit-visible" || key == "child-visible" || key == "available-visible") {
                        search_entry.search_changed ();
                    }
                });

                var actions = new SimpleActionGroup ();

                var sort_name_action = new SimpleAction ("sort-name", null);
                sort_name_action.activate.connect (() => {
                    sort_type = SortType.NAME;
                    sort ();
                });
                actions.add_action (sort_name_action);

                var sort_artists_action = new SimpleAction ("sort-artists", null);
                sort_artists_action.activate.connect (() => {
                    sort_type = SortType.ARTISTS;
                    sort ();
                });
                actions.add_action (sort_artists_action);

                var sort_album_action = new SimpleAction ("sort-album", null);
                sort_album_action.activate.connect (() => {
                    sort_type = SortType.ALBUM;
                    sort ();
                });
                actions.add_action (sort_album_action);

                var sort_duration_action = new SimpleAction ("sort-duration", null);
                sort_duration_action.activate.connect (() => {
                    sort_type = SortType.DURATION;
                    sort ();
                });
                actions.add_action (sort_duration_action);

                insert_action_group ("tracklist", actions);

                sort_direction_button.clicked.connect (() => {
                    switch (sort_direction) {
                        case SortDirection.ASCENDING:
                            sort_direction = SortDirection.DESCENDING;
                            sort_direction_button.icon_name = "view-sort-descending-symbolic";
                            break;
                        case SortDirection.DESCENDING:
                            sort_direction = SortDirection.ASCENDING;
                            sort_direction_button.icon_name = "view-sort-ascending-symbolic";
                            break;
                    }
                    sort ();
                });

                remove_sort_button.clicked.connect (() => {
                    sort_type = null;
                    sort ();
                });
            }

            track_box.child_activated.connect ((row) => {
                ((TrackRow) ((TrackRowW) row).child).trigger ();
                //  application.main_window.window_sidebar.show_track_info (((TrackRow) row).track_info);
            });
        }

        public void move_to (int position, int max) {
            if (adjustment.upper > 0) {
                adjustment.set_value (adjustment.upper / max * position - adjustment.upper / max * 4.5);
            }
            load_chunk ();
        }

        void filter () {
            filtered_rows.clear ();
            foreach (var track_row in sorted_rows) {
                if (search_entry.text == "") {
                    bool show_explicit = Cassette.settings.get_boolean ("explicit-visible");
                    bool show_child = Cassette.settings.get_boolean ("child-visible");
                    bool is_available = Cassette.settings.get_boolean ("available-visible");
                    bool track_can_show = track_row.track_info.track_type == track_type &&
                        (track_row.track_info.available || is_available) &&
                        (!track_row.track_info.is_explicit || show_explicit) &&
                        (!track_row.track_info.is_suitable_for_children || show_child);
                    if (track_can_show || track_row is TrackQueueRow) {
                        filtered_rows.add (track_row);
                        track_row.visible = true;
                    } else {
                        track_row.visible = false;
                    }
                } else if (
                    (search_entry.text.down () in track_row.track_info.title.down ()) ||
                    (search_entry.text.down () in track_row.track_info.get_artists_names ().down ())
                ) {
                    filtered_rows.add (track_row);
                    track_row.visible = true;
                } else {
                    track_row.visible = false;
                }
            }
            if (filtered_rows.size == 0) {
                track_box.visible = false;
            } else {
                track_box.visible = true;
            }
        }

        public void sort () {
            remove_all ();
            if (sort_type == null) {
                sorted_rows_reset ();
                if (is_queue) {
                    sort_direction_button.visible = false;
                }
                remove_sort_button.visible = false;
            } else {
                switch (sort_type) {
                    case SortType.NAME:
                        switch (sort_direction) {
                            case SortDirection.ASCENDING:
                                sorted_rows.sort ((row_1, row_2) => {
                                    if (row_1.track_info.title.down () > row_2.track_info.title.down ()) {
                                        return 1;
                                    } else if (row_1.track_info.title.down () < row_2.track_info.title.down ()) {
                                        return -1;
                                    }
                                    return 0;
                                });
                                break;
                            case SortDirection.DESCENDING:
                                sorted_rows.sort ((row_1, row_2) => {
                                    if (row_1.track_info.title.down () > row_2.track_info.title.down ()) {
                                        return -1;
                                    } else if (row_1.track_info.title.down () < row_2.track_info.title.down ()) {
                                        return 1;
                                    }
                                    return 0;
                                });
                                break;
                        }
                        break;
                    case SortType.ARTISTS:
                        switch (sort_direction) {
                            case SortDirection.ASCENDING:
                                sorted_rows.sort ((row_1, row_2) => {
                                    if (row_1.track_info.artists.size == 0) {
                                        return -1;
                                    }
                                    if (row_2.track_info.artists.size == 0) {
                                        return 1;
                                    }
                                    if (row_1.track_info.get_artists_names () > row_2.track_info.get_artists_names ()) {
                                        return 1;
                                    } else if (row_1.track_info.get_artists_names () < row_2.track_info.get_artists_names ()) {
                                        return -1;
                                    }
                                    return 0;
                                });
                                break;
                            case SortDirection.DESCENDING:
                                sorted_rows.sort ((row_1, row_2) => {
                                    if (row_1.track_info.artists.size == 0) {
                                        return 1;
                                    }
                                    if (row_2.track_info.artists.size == 0) {
                                        return -1;
                                    }
                                    if (row_1.track_info.get_artists_names () > row_2.track_info.get_artists_names ()) {
                                        return -1;
                                    } else if (row_1.track_info.get_artists_names () < row_2.track_info.get_artists_names ()) {
                                        return 1;
                                    }
                                    return 0;
                                });
                                break;
                        }
                        break;
                    case SortType.ALBUM:
                        switch (sort_direction) {
                            case SortDirection.ASCENDING:
                                sorted_rows.sort ((row_1, row_2) => {
                                    if (row_1.track_info.albums.size == 0) {
                                        return -1;
                                    }
                                    if (row_2.track_info.albums.size == 0) {
                                        return 1;
                                    }
                                    if (row_1.track_info.albums[0].title > row_2.track_info.albums[0].title) {
                                        return 1;
                                    } else if (row_1.track_info.albums[0].title < row_2.track_info.albums[0].title) {
                                        return -1;
                                    }
                                    return 0;
                                });
                                break;
                            case SortDirection.DESCENDING:
                                sorted_rows.sort ((row_1, row_2) => {
                                    if (row_1.track_info.albums.size == 0) {
                                        return 1;
                                    }
                                    if (row_2.track_info.albums.size == 0) {
                                        return -1;
                                    }
                                    if (row_1.track_info.albums[0].title > row_2.track_info.albums[0].title) {
                                        return -1;
                                    } else if (row_1.track_info.albums[0].title < row_2.track_info.albums[0].title) {
                                        return 1;
                                    }
                                    return 0;
                                });
                                break;
                        }
                        break;
                    case SortType.DURATION:
                        switch (sort_direction) {
                            case SortDirection.ASCENDING:
                                sorted_rows.sort ((row_1, row_2) => {
                                    if (row_1.track_info.duration_ms > row_2.track_info.duration_ms) {
                                        return 1;
                                    } else if (row_1.track_info.duration_ms < row_2.track_info.duration_ms) {
                                        return -1;
                                    }
                                    return 0;
                                });
                                break;
                            case SortDirection.DESCENDING:
                                sorted_rows.sort ((row_1, row_2) => {
                                    if (row_1.track_info.duration_ms > row_2.track_info.duration_ms) {
                                        return -1;
                                    } else if (row_1.track_info.duration_ms < row_2.track_info.duration_ms) {
                                        return 1;
                                    }
                                    return 0;
                                });
                                break;
                        }
                        break;
                }
                if (is_queue) {
                    sort_direction_button.visible = true;
                }
                remove_sort_button.visible = true;
            }
            foreach (var track_row in sorted_rows) {
                track_box.append (track_row);
            }

            filter ();
            loaded_rows.clear ();
            load_chunk ();
        }

        void remove_all () {
            while (track_box.get_last_child () != null) {
                track_box.remove (track_box.get_last_child ());
            }
        }

        void load_chunk () {
            if (length == 0) {
                return;
            }

            int index;
            if (adjustment.upper > 0) {
                index = (int) (adjustment.value / (adjustment.upper / length));
            } else {
                index = 0;
            }

            int track_number = application.main_window.get_height () / 80;

            int start = 0;
            if (index - 3 > 0) {
                start = index - 3;
            }
            int end = length;
            if (index + track_number + 3 < length) {
                end = index + track_number + 3;
            }

            var new_loaded_rows = range_set (start, end);

            foreach (int row_id in difference (new_loaded_rows, loaded_rows)) {
                filtered_rows[row_id].load_content ();
            }

            foreach (int row_id in difference (loaded_rows, new_loaded_rows)) {
                filtered_rows[row_id].unload_content ();
            }

            loaded_rows = new_loaded_rows;
        }

        public void unload_all () {
            foreach (int row_id in loaded_rows) {
                filtered_rows[row_id].unload_content ();
            }
            loaded_rows.clear ();
        }

        //  Для простого списка треков
        public void load_all () {
            foreach (var track_row in original_track_rows) {
                track_row.load_content ();
            }
        }

        // Возвращает true, если списки треков равны, включая порядок.
        public bool compare_tracks (ArrayList<YaMAPI.Track> track_list) {
            if (track_list.size != original_track_rows.size) {
                return false;
            }
            for (int i = 0; i < track_list.size; i++) {
                if (track_list[i].id != original_track_rows[i].track_info.id) {
                    return false;
                }
            }
            return true;
        }

        void preset_actions () {
            remove_all ();
            clear_all ();
        }

        void postset_actions () {
            sorted_rows_reset ();
            filter ();

            if (adjustment == null) {
                load_all ();
            }
        }

        void add_row (TrackRowW track_row) {
            original_track_rows.add (track_row);
            track_box.append (track_row);
        }

        public void set_tracks_default (ArrayList<YaMAPI.Track> track_list, YaMAPI.Playlist yam_object) {
            preset_actions ();
            foreach (var track_info in track_list) {
                add_row (new TrackRowW (track_info, yam_object));
            }
            postset_actions ();
        }

        public void set_tracks_base (ArrayList<YaMAPI.Track> track_list, HasTrackList yam_object) {
            preset_actions ();
            foreach (var track_info in track_list) {
                add_row (new TrackRowBase (track_info, yam_object));
            }
            postset_actions ();
        }

        public void set_tracks_disliked (ArrayList<YaMAPI.Track> track_list, HasTrackList yam_object) {
            preset_actions ();
            foreach (var track_info in track_list) {
                add_row (new TrackRowDis (track_info, yam_object));
            }
            postset_actions ();
        }

        public void set_tracks_as_queue (ArrayList<YaMAPI.Track> track_list) {
            preset_actions ();

            is_queue = true;
            sort_direction_button.visible = false;

            for (int i = 0; i < track_list.size; i++ ) {
                add_row (new TrackQueueRow (track_list[i], i));
            }

            postset_actions ();
        }

        public void set_tracks_with_positions (ArrayList<YaMAPI.Track> track_list) {
            preset_actions ();

            for (int i = 0; i < track_list.size; i++ ) {
                add_row (new TrackPositionRow (track_list[i], i));
            }

            postset_actions ();
        }

        public void clear_all () {
            original_track_rows.clear ();
            sorted_rows.clear ();
            filtered_rows.clear ();
            loaded_rows.clear ();
        }

        void sorted_rows_reset () {
            sorted_rows.clear ();

            if (sort_direction == SortDirection.ASCENDING || is_queue) {
                sorted_rows.add_all (original_track_rows);
            } else {
                for (int i = original_track_rows.size - 1; i >= 0; i--) {
                    sorted_rows.add (original_track_rows[i]);
                }
            }
        }
    }
}
