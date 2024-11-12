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

[GtkTemplate (ui = "/space/rirusha/Cassette/ui/track-info.ui")]
public class Cassette.TrackInfo : SidebarChildBin {

    [GtkChild]
    unowned LyricsPanel lyrics_panel;
    [GtkChild]
    unowned Gtk.Label writers_label;
    [GtkChild]
    unowned Gtk.Label major_label;
    [GtkChild]
    unowned Gtk.Stack loading_stack;
    [GtkChild]
    unowned LoadingSpinner loading_spinner;
    [GtkChild]
    unowned Gtk.Box lyrics_box;
    [GtkChild]
    unowned Gtk.Box similar_box;
    [GtkChild]
    unowned Gtk.Button play_button;
    [GtkChild]
    unowned PlayMarkTrack play_mark_track;
    [GtkChild]
    unowned SaveStack save_stack;
    [GtkChild]
    unowned LikeButton like_button;
    [GtkChild]
    unowned DislikeButton dislike_button;
    [GtkChild]
    unowned TrackInfoPanel info_panel;
    [GtkChild]
    unowned TrackOptionsButton track_options_button;

    public YaMAPI.Track track_info { get; construct set; }

    public TrackInfo (YaMAPI.Track track_info) {
        Object (track_info: track_info);
    }

    construct {
        info_panel.track_info = track_info;
        track_options_button.track_info = track_info;

        play_button.clicked.connect (play_mark_track.trigger);
        play_mark_track.triggered_not_playing.connect (play_pause);

        LabelButton sbutton;
        if (track_info.is_ugc) {
            title = _("Your music track");
            dislike_button.visible = false;

            //  if (track_info.meta_data.album != null) {
            //      album_socket.child = new LabelButton (track_info.meta_data.album, false);
            //  } else {
            //      album_box.visible = false;
            //  }

            //  if (track_info.get_artists_names () != "") {
            //      artists_box.append (new LabelButton (track_info.get_artists_names (), false));
            //  } else {
            //      artists_main_box.visible = false;
            //  }

        } else {
            title = _("Music track");
            dislike_button.visible = true;
            //  sbutton = new LabelButton (track_info.albums[0].title, true);
            //  album_socket.child = sbutton;
            //  sbutton.button.clicked.connect (() => {
            //      message ("Show album page");
            //      //  applicationance.main_window.current_view.add_view (...)
            //  });
            //  block_widget (sbutton, BlockReason.NOT_IMPLEMENTED);

            //  foreach (var artist in track_info.artists) {
            //      sbutton = new LabelButton (artist.name, true);
            //      artists_box.append (sbutton);
            //      sbutton.button.clicked.connect (() => {
            //          message ("Show artist page");
            //          //  applicationance.main_window.current_view.add_view (...)
            //      });
            //      block_widget (sbutton, BlockReason.NOT_IMPLEMENTED);
            //  }
        }

        child_id = track_info.id;
        subtitle = track_info.title_with_version;

        lyrics_panel.track_id = track_info.id;

        play_mark_track.init_content (track_info.id);
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
                track_list.set_tracks_base (similar_tracks.similar_tracks, similar_tracks);
            } else {
                similar_box.visible = false;
            }
        } else {
            similar_box.visible = false;
        }

        loading_stack.visible_child_name = "loaded";
    }

    void play_pause () {
        var track_list = new Gee.ArrayList<YaMAPI.Track> ();
        track_list.add (track_info);

        player.start_track_list (
            track_list,
            "various",
            null,
            0,
            null
        );
    }
}
