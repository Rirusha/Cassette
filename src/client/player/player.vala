/* player.vala
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

using Gee;

namespace CassetteClient.Player {

    public enum PlayerState {
        NONE,
        PLAYING,
        PAUSED
    }

    public enum RepeatMode {
        OFF,
        REPEAT_ONE,
        REPEAT_ALL
    }

    public enum ShuffleMode {
        OFF,
        ON
    }

    //  Интерфейс режима плеера
    public interface IPlayerMod: Object {
        public abstract YaMAPI.Track? current_track { owned get; }
        public abstract YaMAPI.Track next_track { owned get; }
        public abstract YaMAPI.Track prev_track { owned get; }
        public abstract void next ();
        public abstract void prev ();
    }

    public class Player : Object {

        const double PLAY_STEP = 0.05;

        public signal void queue_changed ();
        public signal void track_state_changed (string track_id);

        PlayerState _player_state = PlayerState.NONE;
        public PlayerState player_state {
            get {
                return _player_state;
            } 
            set {
                _player_state = value;

                switch (_player_state) {
                    case PlayerState.NONE:
                        pipeline.set_state (Gst.State.NULL);
                        break;
                    case PlayerState.PLAYING:
                        pipeline.set_state (Gst.State.PLAYING);
                        break;
                    case PlayerState.PAUSED:
                        pipeline.set_state (Gst.State.PAUSED);
                        break;
                }
            }
        }
        RepeatMode _repeat_mode = RepeatMode.OFF;
        public RepeatMode repeat_mode {
            get {
                return _repeat_mode;
            }
            set {
                _repeat_mode = value;
                if (player_mod == null) {
                    return;
                }
                assert (player_mod is PlayerTL);
            }
        }
        ShuffleMode _shuffle_mode = ShuffleMode.OFF;
        public ShuffleMode shuffle_mode {
            get {
                return _shuffle_mode;
            }
            set {
                _shuffle_mode = value;
                if (player_mod == null) {
                    return;
                }
                assert (player_mod is PlayerTL);

                var player_tl = player_mod as PlayerTL;
                switch (_shuffle_mode) {
                    case ShuffleMode.ON:
                        player_tl.shuffle ();
                        break;
                    case ShuffleMode.OFF:
                        player_tl.unshuffle ();
                        break;
                }

                if (storager.settings.get_boolean ("can-cache")) {
                    prepare_next_track.begin ();
                }
            }
        }
        public double volume {
            set {
                _volume.set_property ("volume", value);
            }
        }
        public double play_position_sec {
            get {
                int64 cur;
                pipeline.query_position (Gst.Format.TIME, out cur);
                return (double) cur / Gst.SECOND;
            }
        }
        public int64 play_position_ms {
            get {
                int64 cur;
                pipeline.query_position (Gst.Format.TIME, out cur);
                return cur / Gst.MSECOND;
            }
        }


        public YaMAPI.Track? current_track {
            owned get {
                if (player_mod != null) {
                    return player_mod.current_track;
                } else {
                    return null;
                }
            }
        }

        public bool is_slider_moving    { get; set; default = false; }
        public Gtk.Scale play_slider    { get; set; }
        public bool is_loading          { get; private set; default = false; }
        public IPlayerMod? player_mod   { get; private set; default = null; }

        Gst.Pipeline pipeline;
        Gst.Element source;
        Gst.Element _volume;

        public Player () {
            Object ();
        }

        construct {
            init (null);

            pipeline = new Gst.Pipeline (null);
            var bus = pipeline.get_bus ();

            source = Gst.ElementFactory.make("uridecodebin", null);
            var audioconvert = Gst.ElementFactory.make("audioconvert", null);
            var audioresample = Gst.ElementFactory.make("audioresample", null);
            var sink = Gst.ElementFactory.make("autoaudiosink", null);
            _volume = Gst.ElementFactory.make("volume", null);

            pipeline.add_many (source, audioconvert, audioresample, sink, _volume);

            source.pad_added.connect((src, pad) => {
                var sinkpad = audioconvert.get_static_pad("sink");
                pad.link(sinkpad);
            });

            audioresample.link(_volume);
            _volume.link(sink);
            audioconvert.link (audioresample);
            audioresample.link (sink);

            bus.add_signal_watch ();
            bus.message["eos"].connect ((bus, message) => {
                next ();
            });

            storager.settings.bind ("repeat-mode", this, "repeat-mode", SettingsBindFlags.DEFAULT);
            storager.settings.bind ("shuffle-mode", this, "shuffle-mode", SettingsBindFlags.DEFAULT);

            Timeout.add ((int) (PLAY_STEP * 1000), () => {
                if (is_slider_moving == false) {
                    play_slider.set_value (play_position_sec);
                }
                return true;
            });
        }

        void init (string[]? args) {
            Gst.init (ref args);
        }

        public void seek (int64 ms) {
            pipeline.seek_simple (Gst.Format.TIME, Gst.SeekFlags.FLUSH | Gst.SeekFlags.KEY_UNIT, ms * Gst.MSECOND);
        }

        public void start_flow () {
            player_mod = new PlayerFL ();
        }

        public void start_queue (YaMAPI.Queue queue) {
            stop ();

            var playertl = new PlayerTL (this);
            player_mod = playertl;
            playertl.queue = queue;

            start_current_track.begin ();
        }

        public void start_queue_init (YaMAPI.Queue queue) {
            stop ();

            var playertl = new PlayerTL (this);
            player_mod = playertl;
            playertl.queue = queue;

            start_current_track.begin (() => {
                stop ();
            });
        }

        public void play_pause () {
            switch (player_state) {
                case PlayerState.PLAYING:
                    pause ();
                    break;
                case PlayerState.PAUSED:
                    play ();
                    break;
                default:
                    start_current_track.begin ();
                    break;
            }
        }

        public void play () {
            player_state = PlayerState.PLAYING;

            if (current_track != null) {
                track_state_changed (current_track.id);
            }
        }

        public void pause () {
            player_state = PlayerState.PAUSED;

            if (current_track != null) {
                track_state_changed (current_track.id);
            }
        }

        public void stop () {
            source.set_property ("uri", Value (Type.STRING));

            pause ();

            if (current_track != null) {
                send_play_audio.begin (play_position_sec);
            }

            player_state = PlayerState.NONE;
            play_slider.set_value (0.0);
        }

        public void next () {
            stop ();

            player_mod.next ();
            start_current_track.begin ();
        }

        public void prev () {
            if (play_position_sec > 3.0) {
                seek (0);
            } else {
                stop ();

                player_mod.prev ();
                start_current_track.begin ();
            }
        }

        public void change_track (YaMAPI.Track track_info) {
            stop ();

            var playertl = player_mod as PlayerTL;
            if (playertl != null) {
                playertl.change_track (track_info);

                start_current_track.begin ();
            }
        }

        public async void start_current_track () {
            if (current_track == null) {
                return;
            }

            is_loading = true;

            send_play_audio.begin (0.0);

            string? track_uri = yield get_track_uri (current_track.id);
            if (track_uri == null) {
                source.set_property ("uri", Value (Type.STRING));
            } else {
                source.set_property ("uri", track_uri);

                play ();
                storager.clear_temp_track ();
            }

            is_loading = false;

            if (storager.settings.get_boolean ("can-cache")) {
                prepare_next_track.begin ();
            }
        }

        async void send_play_audio (double play_position_sec) {
            threader.add_single (() => {
                var playertl = player_mod as PlayerTL;
                if (playertl != null) {
                    string? playlist_id = playertl.queue.context.type_ == "playlist" ? playertl.queue.context.id : null;
                    yam_talker.play_audio (current_track, playlist_id, play_position_sec);
                } else {
                    yam_talker.play_audio (current_track, null, play_position_sec);
                }

                Idle.add (send_play_audio.callback);
            });

            yield;
        }

        async void prepare_next_track () {
            YaMAPI.Track next_track = null;

            threader.add_audio (() => {
                next_track = player_mod.next_track;

                Idle.add (prepare_next_track.callback);
            });

            yield;

            if (next_track != current_track) {
                save_track.begin (next_track);
            }
        }

        public void add_track (YaMAPI.Track track_info, bool is_next) {
            var player_tl = player_mod as PlayerTL;
            if (player_tl != null) {
                if (is_next) {
                    player_tl.add_track_next (track_info);
                } else {
                    player_tl.add_track_end (track_info);
                }

                if (storager.settings.get_boolean ("can-cache")) {
                    prepare_next_track.begin ();
                }
            }
        }

        public void add_many (ArrayList<YaMAPI.Track> track_list) {
            var player_tl = player_mod as PlayerTL;
            if (player_tl != null) {
                player_tl.add_many_end (track_list);

                if (storager.settings.get_boolean ("can-cache")) {
                    prepare_next_track.begin ();
                }
            }
        }

        public void remove_track (uint position) {
            var player_tl = player_mod as PlayerTL;
            if (player_tl != null) {
                player_tl.remove_track (position);

                if (player_tl.queue.tracks.size != 0 && storager.settings.get_boolean ("can-cache")) {
                    prepare_next_track.begin ();
                }
            }
        }

        public void remove_all_tracks () {
            var player_tl = player_mod as PlayerTL;
            if (player_tl != null) {
                player_tl.remove_all_tracks ();
            }
        }
    }
}