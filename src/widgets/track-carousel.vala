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
    [GtkChild]
    unowned TrackInfoPanel track_info_panel_left;
    [GtkChild]
    unowned TrackInfoPanel track_info_panel_center;
    [GtkChild]
    unowned TrackInfoPanel track_info_panel_right;

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

    uint check_situation_timeout = 0;
    bool moving = false;

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

        //  track_info_panel_left.notify["track-info"].connect (() => {
        //      track_info_panel_left.visible = track_info_panel_left.track_info != null;
        //  });
        //  track_info_panel_right.notify["track-info"].connect (() => {
        //      track_info_panel_right.visible = track_info_panel_right.track_info != null;
        //  });

        player.mode_inited.connect (on_player_mode_inited);

        carousel.page_changed.connect (on_carousel_page_changed);

        carousel.notify["position"].connect (() => {
            moving = true;
        });

        //  player.next_track_loaded.connect ((track_info) => {
        //      info_panel_next.track_info = track_info;
        //  });

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

        start_check_situation ();
    }

    void start_check_situation () {
        if (check_situation_timeout != 0) {
            end_check_situation ();
        }

        check_situation_timeout = Timeout.add_seconds (1, () => {
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
        if (!get_mapped () || moving) {
            return;
        }

        update_track_info_panel_center ();
        update_track_info_panel_right ();
        update_track_info_panel_left ();

        if (carousel.position != 1.0) {
            carousel.scroll_to (carousel.get_nth_page (1), false);
        }
    }

    void update_track_info_panel_left () {
        track_info_panel_left.track_info = player.mode.get_prev_track_info ();
    }

    void update_track_info_panel_center () {
        var current_track = player.mode.get_current_track_info ();

        if (track_info_panel_center.track_info != current_track) {
            track_info_panel_center.track_info = player.mode.get_current_track_info ();
        }
    }

    void update_track_info_panel_right () {
        track_info_panel_right.track_info = player.mode.get_next_track_info (false);
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

    void on_carousel_page_changed () {
        moving = false;
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
