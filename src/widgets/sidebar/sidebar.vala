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

using Cassette.Client;
using Gee;

[GtkTemplate (ui = "/io/github/Rirusha/Cassette/ui/sidebar.ui")]
public class Cassette.Sidebar : ShrinkableBin {

    [GtkChild]
    unowned Adw.OverlaySplitView overlay_split_view;
    [GtkChild]
    unowned Adw.ToolbarView toolbar_view;
    [GtkChild]
    unowned Adw.WindowTitle window_title;
    [GtkChild]
    unowned PrimaryMenuButton menu_button;
    [GtkChild]
    unowned CacheIndicator cache_indicator;

    public string child_id { get; set; }

    public Gtk.Widget content {
        get {
            return overlay_split_view.content;
        }
        set {
            overlay_split_view.content = value;
        }
    }

    public SidebarChildBin? sidebar_child {
        get {
            return (SidebarChildBin?) toolbar_view.content;
        }
        set {
            toolbar_view.content = value;

            if (value != null) {
                value.bind_property ("title", window_title, "title", BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE);
                value.bind_property ("subtitle", window_title, "subtitle", BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE);
            }

            child_id = value != null ? value.child_id : "";
            is_shown = value != null;

            child_changed (value);
        }
    }

    public bool is_shown { get; set; }

    public bool collapsed { get; set; }

    public signal void child_changed (SidebarChildBin? new_child);

    construct {
        bind_property ("is-shrinked", this, "collapsed", BindingFlags.DEFAULT);
    }

    public void close () {
        sidebar_child = null;
    }

    public void show_track_info (YaMAPI.Track track_info) {
        sidebar_child = null;

        if (track_info.available) {
            sidebar_child = new TrackInfo (track_info);
        }
    }

    public void show_wave_settings () {
        sidebar_child = null;

        if (player.mode is Player.Flow && player.mode.context_id == "user:onyourwave") {
            sidebar_child = new WaveSettings ();
        }
    }

    public void show_queue () {
        sidebar_child = null;

        if (player.mode is Player.TrackList) {
            sidebar_child = new PlayerQueue ();
        }
    }
}
