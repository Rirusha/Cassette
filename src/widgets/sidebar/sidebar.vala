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

    public SidebarChildBin sidebar_child {
        get {
            return (SidebarChildBin) toolbar_view.content;
        }
        set {
            toolbar_view.content = value;

            if (value != null) {
                value.bind_property ("title", window_title, "title", BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE);
                value.bind_property ("subtitle", window_title, "subtitle", BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE);
            }

            child_id = value != null ? value.child_id : "";
            is_shown = value != null;
        }
    }

    public bool is_shown { get; set; }

    public bool collapsed { get; set; }

    public void close () {
        sidebar_child = null;
    }

    public void show_track_info (YaMAPI.Track track_info) {
        sidebar_child = null;

        if (track_info.available) {
            sidebar_child = new TrackInfo (track_info);
        }
    }

    public void show_queue () {
        sidebar_child = null;

        if (player.mode is Player.TrackList) {
            sidebar_child = new PlayerQueue ();
        }
    }
}
















//  using Gee;

//  namespace Cassette {
//      [GtkTemplate (ui = "/io/github/Rirusha/Cassette/ui/sidebar.ui")]
//      public class SideBar2 : ShrinkableBin {

//          [GtkChild]
//          unowned Adw.OverlaySplitView root_flap;
//          [GtkChild]
//          unowned PrimaryMenuButton menu_button;
//          [GtkChild]
//          unowned CacheIndicator cache_indicator;
//          [GtkChild]
//          public unowned Gtk.ScrolledWindow sidebar_content;

//          TrackList?_track_list = null;
//          public TrackList? track_list {
//              get {
//                  return _track_list;
//              }
//              set {
//                  sidebar_content.child = value;
//                  _track_list = value;
//              }
//          }

//          TrackInfo? _track_detailed = null;
//          public TrackInfo? track_detailed {
//              get {
//                  return _track_detailed;
//              }
//              set {
//                  sidebar_content.child = value;
//                  _track_detailed = value;
//              }
//          }

//          public Gtk.Widget content {
//              get {
//                  return root_flap.content;
//              }
//              set {
//                  root_flap.content = value;
//              }
//          }

//          bool _is_shown;
//          public bool is_shown {
//              get {
//                  return _is_shown;
//              }
//              set {
//                  _is_shown = value;

//                  if (!_is_shown) {
//                      clear ();
//                  }
//              }
//          }

//          public bool collapsed { get; set; }

//          public SideBar () {
//              Object ();
//          }

//          construct {
//              sidebar_content.notify["child"].connect (() => {
//                  if (sidebar_content.child != null) {
//                      is_shown = true;
//                  }
//              });

//              notify["is-shrinked"].connect (() => {
//                  root_flap.collapsed = is_shrinked;
//              });

//              this.bind_property ("is-shown", root_flap, "show-sidebar", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);

//              player.queue_changed.connect (update_queue);
//          }

//          public void close () {
//              is_shown = false;
//          }

//          public void show_track_info (YaMAPI.Track track_info) {
//              clear ();

//              if (track_info.available) {
//                  track_detailed = new TrackInfo (track_info);
//              }
//          }

//          public void show_queue () {
//              clear ();

//              if (player.mode is Player.TrackList) {
//                  track_list = new TrackList (sidebar_content.vadjustment) {
//                      margin_top = 12,
//                      margin_bottom = 12,
//                      margin_start = 12,
//                      margin_end = 12
//                  };
//                  update_queue (
//                      player.mode.queue,
//                      player.mode.context_type,
//                      player.mode.context_id,
//                      player.mode.current_index,
//                      player.mode.context_description
//                  );
//              }
//          }

//          void update_queue (
//              ArrayList<YaMAPI.Track> queue,
//              string context_type,
//              string? context_id,
//              int current_index,
//              string? context_description
//          ) {
//              if (track_list != null) {
//                  track_list.set_tracks_as_queue (queue);
//                  // TODO: Replace with .scroll_to
//                  Idle.add (() => {
//                      track_list.move_to (current_index, queue.size);
//                      return Source.REMOVE;
//                  });

//                  track_list.title.visible = true;
//                  switch (context_type) {
//                      case "playlist":
//                          track_list.list_type_label.label = _("PLAYLIST");
//                          track_list.list_name_label.label = context_description;
//                          break;
//                      case "album":
//                          track_list.list_type_label.label = _("ALBUM");
//                          track_list.list_name_label.label = context_description;
//                          break;
//                      case "search":
//                          track_list.list_type_label.label = _("SEARCH RESULTS");
//                          track_list.list_name_label.label = "\"%s\"".printf (context_description);
//                          break;
//                      default:
//                          track_list.list_type_label.label = "";
//                          track_list.list_name_label.label = _("Track list");
//                          break;
//                  }
//              }
//          }

//          void clear () {
//              if (track_list != null) {
//                  track_list.clear_all ();
//                  track_list = null;
//              }
//              if (track_detailed != null) {
//                  track_detailed = null;
//              }
//          }
//      }
//  }
