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

    public bool interactive { get; set; default = false; }

    public int spacing { get; set; default = 0; }

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
        bind_property ("interactive", carousel, "interactive", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);
        bind_property ("spacing", carousel, "spacing", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);

        player.mode_inited.connect (on_player_mode_inited);

        carousel.page_changed.connect (on_carousel_page_changed);

        if (interactive) {
            carousel.notify["position"].connect (() => {
                is_scrolling_now = true;
            });
        }

        player.next_track_loaded.connect ((track_info) => {
            check_situation ();
        });

        player.ready_play_next.connect (() => {
            check_situation ();
        });

        player.ready_play_prev.connect (() => {
            check_situation ();
        });

        //  player.ready_play_next.connect ((repeat) => {
        //      var track_info = player.mode.get_current_track_info ();

        //      if (track_info != info_panel_center.track_info) {
        //          info_panel_next.track_info = player.mode.get_current_track_info ();
        //          carousel.scroll_to (info_panel_next, true);
        //      }
        //  });

        //  player.ready_play_prev.connect (() => {
        //      var track_info = player.mode.get_current_track_info ();

        //      if (track_info != info_panel_center.track_info) {
        //          info_panel_prev.track_info = player.mode.get_current_track_info ();
        //          carousel.scroll_to (info_panel_prev, true);
        //      }
        //  });

        map.connect (start_check_situation);
        unmap.connect (end_check_situation);
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
        if (!get_mapped () || is_scrolling_now) {
            return;
        }

        carousel.page_changed.disconnect (on_carousel_page_changed);

        is_scrolling_now = true;

        if (carousel.position == 0.0) {
            carousel.remove (track_info_panel_right);
            carousel.insert (new TrackInfoPanel (orientation), 0);

        } else if (carousel.position == 2.0) {
            carousel.remove (track_info_panel_left);
            carousel.insert (new TrackInfoPanel (orientation), -1);
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

        //  var current_track_info = player.mode.get_current_track_info ();

        //  if (info_panel_center.track_info == null) {
        //      info_panel_center.track_info = current_track_info;
        //  }

        //  info_panel_next.track_info = current_track_info;
        //  carousel.scroll_to (info_panel_next, true);
    }

    void on_carousel_page_changed (uint position) {
        if (position == 2) {
            player.next ();

        } else if (position == 0) {
            player.prev (true);
        }

        if (!is_scrolling_now) {
            check_situation ();
        }

        is_scrolling_now = false;
    }























    //  void on_carousel_page_changed (uint index) {
    //      if (!enabled) {
    //          return;
    //      }

    //      if (index == 1) {
    //          centerized = true;
    //      }

    //      if (!centerized) {
    //          carousel.scroll_to (info_panel_center, false);
    //          return;
    //      }

    //      carousel.page_changed.disconnect (on_carousel_page_changed);

    //      if (index == 2) {
    //          //  if (info_panel_next.track_info != player.mode.get_current_track_info ()) {
    //          //      player.next ();
    //          //  }

    //          carousel.remove (info_panel_prev);
    //          carousel.append (new TrackInfoPanel (orientation));

    //          info_panel_next.track_info = player.mode.get_next_track_info (false);

    //          carousel.scroll_to (info_panel_center, false);

    //      } else if (index == 0) {
    //          //  if (info_panel_prev.track_info != player.mode.get_current_track_info ()) {
    //          //      player.prev (true);
    //          //  }

    //          carousel.remove (info_panel_next);
    //          carousel.prepend (new TrackInfoPanel (orientation));

    //          info_panel_prev.track_info = player.mode.get_prev_track_info ();

    //          carousel.scroll_to (info_panel_center, false);
    //      }

    //      carousel.page_changed.connect (on_carousel_page_changed);

    //      update_prev_and_next_track ();
    //  }

    //  void on_player_mode_inited () {
    //      var current_track_info = player.mode.get_current_track_info ();

    //      if (info_panel_center.track_info == null) {
    //          info_panel_center.track_info = current_track_info;
    //      }

    //      info_panel_next.track_info = current_track_info;
    //      carousel.scroll_to (info_panel_next, true);
    //  }

    //  void update_prev_and_next_track () {
    //      info_panel_prev.track_info = player.mode.get_prev_track_info ();
    //      info_panel_next.track_info = player.mode.get_next_track_info (false);
    //  }
}
