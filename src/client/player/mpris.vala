/* mpris.vala
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


namespace CassetteClient.Mpris {
    [DBus (name = "org.mpris.MediaPlayer2")]
    public class Mpris : Object {
        public bool can_quit { get; set; default = true; }
        public bool can_raise { get; set; default = true; }
        public string desktop_entry { get; set; default = "cassette"; }
        public string identity { get; set; default = "Cassette"; }

        public signal void quit_triggered ();
        public signal void raise_triggered ();

        public void quit (BusName sender) throws Error {
            quit_triggered ();
        }

        public void raise (BusName sender) throws Error {
            raise_triggered ();
        }
    }


    [DBus (name = "org.mpris.MediaPlayer2.Player")]
    public class MprisPlayer : Object {

        DBusConnection con;

        public bool can_control {
            get {
                return true;
            }
        }

        public bool can_go_next { get; private set; default = true; }
        public bool can_go_previous { get; private set; default = true; }
        public bool can_play { get; private set; default = true; }

        public bool can_pause {
            get {
                return true;
            }
        }

        public bool can_seek {
            get {
                return !player.is_loading;
            }
        }

        public string playback_status {
            get {
                switch (player.player_state) {
                    case Player.PlayerState.PLAYING:
                        return "Playing";
                    case Player.PlayerState.PAUSED:
                        return "Paused";
                    case Player.PlayerState.NONE:
                        return "Stopped";
                    default:
                        assert_not_reached ();
                }
            }
        }

        public int64 position {
            get {
                return player.playback_pos_ms;
            }
        }
        public double volume { get; set; }

        public signal void seeked (int64 position);

        public HashTable<string, Variant>? metadata {
            owned get {
                return _get_metadata ();
            }
        }

        public MprisPlayer (DBusConnection con) {
            this.con = con;

            player.current_track_start_loading.connect (() => {
                can_go_next = false;
                can_go_previous = false;
                can_play = false;
            });

            player.current_track_finish_loading.connect (() => {
                can_go_next = true;
                can_go_previous = player.player_type == Player.PlayerModeType.TRACK_LIST;
                can_play = true;
            });

            bind_property ("volume", player, "volume", BindingFlags.BIDIRECTIONAL);

            player.playback_callback.connect ((position) => {
                seeked ((int64) position);
            });

            player.notify["player-state"].connect (() => {
                send_property_change ("PlaybackStatus", this.playback_status);
                send_property_change ("Metadata", _get_metadata ());
            });
        }

        HashTable<string,Variant> _get_metadata () {
            HashTable<string,Variant> metadata = new HashTable<string, Variant> (null, null);

            var current_track = player.get_current_track ();
            if (current_track == null) {
                metadata.insert ("mpris:trackid", new ObjectPath ("/com/github/Rirusha/Cassette/Track/0"));
            } else {
                ObjectPath obj_path;
                if ("-" in current_track.id) {
                    obj_path = new ObjectPath (@"/com/github/Rirusha/Cassette/Track/$(current_track.id.hash ())");
                } else {
                    obj_path = new ObjectPath (@"/com/github/Rirusha/Cassette/Track/$(current_track.id)");
                }

                string[] artists = new string [current_track.artists.size];
                for (int i = 0; i < artists.length; i++) {
                    artists[i] = current_track.artists[i].name;
                }

                var cover_items = current_track.get_cover_items_by_size (ArtSize.TRACK);

                string cover_uri = "";
                if (cover_items.size != 0) {
                    cover_uri = cover_items[0];
                }

                metadata.insert ("mpris:trackid", obj_path);
                metadata.insert ("mpris:length", current_track.duration_ms);
                metadata.insert ("mpris:artUrl", cover_uri);
                metadata.insert ("xesam:title", current_track.title);
                metadata.insert ("xesam:album",
                    current_track.albums.size != 0 ? current_track.albums[0].title : "Unknown Album"
                );
                metadata.insert ("xesam:albumArtist", artists);
                metadata.insert ("xesam:artist", artists);
            }

            return metadata;
        }

        // Спасибо https://github.com/bcedu/MuseIC
        bool send_property_change (string property, Variant variant) {
            var builder = new VariantBuilder (VariantType.ARRAY);
            var invalidated_builder = new VariantBuilder (new VariantType ("as"));
            builder.add ("{sv}", property, variant);

            try {
                con.emit_signal (
                    null,
                    "/org/mpris/MediaPlayer2",
                    "org.freedesktop.DBus.Properties",
                    "PropertiesChanged",
                    new Variant ("(sa{sv}as)",
                    "org.mpris.MediaPlayer2.Player",
                    builder,
                    invalidated_builder)
                );
            }
            catch (Error e) {
                Logger.warning (@"Could not send MPRIS property change: $(e.message)");
            }
            return false;
        }

        public void next (BusName sender) throws Error {
            if (!player.is_loading) {
                player.next ();
            }
        }

        public void previous (BusName sender) throws Error {
            if (!player.is_loading) {
                player.prev ();
            }
        }

        public void play (BusName sender) throws Error {
            player.play ();
        }

        public void pause (BusName sender) throws Error {
            player.pause ();
        }

        public void play_pause (BusName sender) throws Error {
            player.play_pause ();
        }

        public void stop (BusName sender) throws Error {
            player.stop ();
        }

        public void seek (int64 position, BusName sender) throws Error {
            player.seek (position);
        }
    }

    public static Mpris mpris;
    public static MprisPlayer mpris_player;

    public static void init () {
        mpris = new Mpris ();

        Bus.own_name (
            BusType.SESSION,
            "org.mpris.MediaPlayer2.cassette",
            BusNameOwnerFlags.ALLOW_REPLACEMENT,
            on_bus_aquired
        );
    }

    static void on_bus_aquired (DBusConnection con, string name) {
        try {
            con.register_object ("/org/mpris/MediaPlayer2", mpris);
            var mpris_player = new MprisPlayer (con);
            con.register_object ("/org/mpris/MediaPlayer2", mpris_player);
        } catch (IOError e) {
            message (e.message);
        }
    }
}
