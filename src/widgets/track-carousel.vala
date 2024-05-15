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


[GtkTemplate (ui = "/io/github/Rirusha/Cassette/ui/track-carousel.ui")]
public class Cassette.TrackCarousel : Adw.Bin, Gtk.Orientable {

    [GtkChild]
    unowned Adw.Carousel carousel;

    public bool interactive {
        get {
            return carousel.interactive;
        }
        set {
            carousel.interactive = value;
        }
    }

    public uint spacing {
        get {
            return carousel.spacing;
        }
        set {
            carousel.spacing = value;
        }
    }

    public int panels_width { get; construct set; default = -1; }

    public bool can_swipe_left {
        get {
            return player.mode.get_prev_index () != -1;
        }
    }

    public bool can_swipe_right {
        get {
            return player.mode.get_next_index (false) != -1;
        }
    }

    Gtk.Orientation _orientation = Gtk.Orientation.HORIZONTAL;
    public Gtk.Orientation orientation {
        get {
            return _orientation;
        }
        set {
            _orientation = value;

            track_info_panel_left.set_orientation (value);
            track_info_panel_center.set_orientation (value);
            track_info_panel_right.set_orientation (value);
        }
    }

    TrackInfoPanel track_info_panel_left {
        get {
            return (TrackInfoPanel) carousel.get_nth_page (0);
        }
    }

    TrackInfoPanel track_info_panel_center {
        get {
            return (TrackInfoPanel) carousel.get_nth_page (1);
        }
    }

    TrackInfoPanel track_info_panel_right {
        get {
            return (TrackInfoPanel) carousel.get_nth_page (2);
        }
    }

    uint check_situation_timeout = 0;
    bool is_scrolling_now = false;

    public TrackCarousel (
        Gtk.Orientation orientation
    ) {
        Object (
            orientation: orientation
        );
    }

    construct {
        carousel.append (new TrackInfoPanel (orientation) {
            width_request = panels_width
        });
        carousel.append (new TrackInfoPanel (orientation) {
            width_request = panels_width
        });
        carousel.append (new TrackInfoPanel (orientation) {
            width_request = panels_width
        });

        player.mode_inited.connect (on_player_mode_inited);

        carousel.page_changed.connect (on_carousel_page_changed);

        player.next_track_loaded.connect ((track_info) => {
            update_track_info_panel_right ();
        });

        player.next_track_loaded.connect (check_situation);

        player.notify["shuffle-mode"].connect (check_situation);
        player.notify["repeat-mode"].connect (check_situation);

        if (interactive) {
            var gs = new Gtk.GestureClick ();
            gs.pressed.connect (() => {
                is_scrolling_now = true;
            });
            carousel.add_controller (gs);

            player.bind_property (
                "current-track-loading",
                this,
                "interactive",
                BindingFlags.DEFAULT | BindingFlags.INVERT_BOOLEAN
            );
        }

        player.ready_play_next.connect ((repeat) => {
            is_scrolling_now = false;
            carousel.scroll_to (track_info_panel_right, true);
        });

        player.ready_play_prev.connect ((repeat) => {
            is_scrolling_now = false;
            carousel.scroll_to (track_info_panel_left, true);
        });

        start_check_situation ();
        map.connect (check_situation);
    }

    void start_check_situation () {
        if (check_situation_timeout != 0) {
            end_check_situation ();
        }

        check_situation_timeout = Timeout.add_seconds (3, () => {
            check_situation ();

            return true;
        }, Priority.LOW);
        check_situation ();
    }

    void end_check_situation () {
        if (check_situation_timeout == 0) {
            return;
        }

        Source.remove (check_situation_timeout);
        check_situation_timeout = 0;
    }

    /**
     * Check num of track panels, current position, track infos 
     */
    void check_situation () {
        if (!get_mapped () || is_scrolling_now || player.current_track_loading) {
            return;
        }

        carousel.page_changed.disconnect (on_carousel_page_changed);

        is_scrolling_now = true;

        if (carousel.position == 0.0) {
            carousel.remove (track_info_panel_right);
            carousel.insert (new TrackInfoPanel (orientation) {
                width_request = panels_width
            }, 0);

        } else if (carousel.position == 2.0) {
            carousel.remove (track_info_panel_left);
            carousel.insert (new TrackInfoPanel (orientation) {
                width_request = panels_width
            }, -1);
            carousel.scroll_to (track_info_panel_center, false);
        }

        update_track_info_panel_center ();
        update_track_info_panel_right ();
        update_track_info_panel_left ();

        Idle.add_once (() => {
            carousel.page_changed.connect (on_carousel_page_changed);
            is_scrolling_now = false;
        });
    }

    void update_track_info_panel_left () {
        var prev_track_info = player.mode.get_prev_track_info ();

        if (prev_track_info != track_info_panel_left.track_info) {
            track_info_panel_left.track_info = prev_track_info;
        }
    }

    void update_track_info_panel_center () {
        var current_track = player.mode.get_current_track_info ();

        if (current_track != track_info_panel_center.track_info) {
            track_info_panel_center.track_info = player.mode.get_current_track_info ();
        }
    }

    void update_track_info_panel_right () {
        var next_track_info = player.mode.get_next_track_info (false);

        if (next_track_info != track_info_panel_right.track_info) {
            track_info_panel_right.track_info = next_track_info;
        }
    }

    void on_player_mode_inited () {
        check_situation ();
    }

    void on_carousel_page_changed (uint position) {
        if (is_scrolling_now) {
            if (position == 2) {
                if (can_swipe_right) {
                    player.next ();

                } else {
                    carousel.scroll_to (track_info_panel_center, true);
                    return;
                }
            } else if (position == 0) {
                if (can_swipe_left) {
                    player.prev ();

                } else {
                    carousel.scroll_to (track_info_panel_center, true);
                    return;
                }
            }
        } else {
            check_situation ();
        }

        is_scrolling_now = false;
    }
}
