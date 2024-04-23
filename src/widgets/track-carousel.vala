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


public class Cassette.TrackCarousel : Adw.Bin {

    Adw.Carousel carousel = new Adw.Carousel ();

    public bool interactive { get; set; default = false; }

    public int spacing { get; set; default = 0; }

    public Gtk.Orientation orientation { get; construct; default = Gtk.Orientation.HORIZONTAL; }

    TrackInfoPanel info_panel_prev {
        get {
            return (TrackInfoPanel) carousel.get_nth_page (0);
        }
    }

    TrackInfoPanel info_panel_center {
        get {
            return (TrackInfoPanel) carousel.get_nth_page (1);
        }
    }

    TrackInfoPanel info_panel_next {
        get {
            return (TrackInfoPanel) carousel.get_nth_page (2);
        }
    }

    bool centerized = false;
    bool enabled = false;

    public TrackCarousel (
        Gtk.Orientation orientation
    ) {
        Object (
            orientation: orientation
        );
    }

    construct {
        child = carousel;

        bind_property ("interactive", carousel, "interactive", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);
        bind_property ("spacing", carousel, "spacing", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);

        carousel.append (new TrackInfoPanel (orientation));
        carousel.append (new TrackInfoPanel (orientation));
        carousel.append (new TrackInfoPanel (orientation));

        player.mode_inited.connect (on_player_mode_inited);

        carousel.page_changed.connect (on_carousel_page_changed);

        player.next_track_loaded.connect ((track_info) => {
            info_panel_next.track_info = track_info;
        });

        player.ready_play_next.connect ((repeat) => {
            var track_info = player.mode.get_current_track_info ();

            if (track_info != info_panel_center.track_info) {
                info_panel_next.track_info = player.mode.get_current_track_info ();
                carousel.scroll_to (info_panel_next, true);
            }
        });

        player.ready_play_prev.connect (() => {
            var track_info = player.mode.get_current_track_info ();

            if (track_info != info_panel_center.track_info) {
                info_panel_prev.track_info = player.mode.get_current_track_info ();
                carousel.scroll_to (info_panel_prev, true);
            }
        });

        map.connect (() => {
            enabled = true;

            on_player_mode_inited ();
        });

        unmap.connect (() => {
            enabled = false;
        });
    }

    void on_carousel_page_changed (uint index) {
        if (!enabled) {
            return;
        }

        if (index == 1) {
            centerized = true;
        }

        if (!centerized) {
            carousel.scroll_to (info_panel_center, false);
            return;
        }

        carousel.page_changed.disconnect (on_carousel_page_changed);

        if (index == 2) {
            //  if (info_panel_next.track_info != player.mode.get_current_track_info ()) {
            //      player.next ();
            //  }

            carousel.remove (info_panel_prev);
            carousel.append (new TrackInfoPanel (orientation));

            info_panel_next.track_info = player.mode.get_next_track_info (false);

            carousel.scroll_to (info_panel_center, false);

        } else if (index == 0) {
            //  if (info_panel_prev.track_info != player.mode.get_current_track_info ()) {
            //      player.prev (true);
            //  }

            carousel.remove (info_panel_next);
            carousel.prepend (new TrackInfoPanel (orientation));

            info_panel_prev.track_info = player.mode.get_prev_track_info ();

            carousel.scroll_to (info_panel_center, false);
        }

        carousel.page_changed.connect (on_carousel_page_changed);

        update_prev_and_next_track ();
    }

    void on_player_mode_inited () {
        var current_track_info = player.mode.get_current_track_info ();

        if (info_panel_center.track_info == null) {
            info_panel_center.track_info = current_track_info;
        }

        info_panel_next.track_info = current_track_info;
        carousel.scroll_to (info_panel_next, true);
    }

    void update_prev_and_next_track () {
        info_panel_prev.track_info = player.mode.get_prev_track_info ();
        info_panel_next.track_info = player.mode.get_next_track_info (false);
    }
}
