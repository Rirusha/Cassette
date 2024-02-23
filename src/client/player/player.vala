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
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */

using Gee;

namespace Cassette.Client.Player {

    public enum PlayerModeType {
        NONE,
        TRACK_LIST,
        FLOW
    }

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
    public abstract class PlayerMode: Object {
        public signal void near_changed ();

        public abstract async YaMAPI.Track? get_prev_track ();
        public abstract YaMAPI.Track? get_current_track ();
        public abstract async YaMAPI.Track? get_next_track ();

        // Учитывать повтор для след. трека нужно только если он листается сам по истечении прошлого трека
        public abstract void next (bool consider_repeat_mode);
        public abstract void prev ();
    }

    public class Player : Object {

        // Количество секунд, которое проходит между колбеками проигранного времени
        const double PLAY_STEP = 0.2;

        PlayerState _player_state = PlayerState.NONE;
        public PlayerState player_state {
            get {
                return _player_state;
            }
            set {
                _player_state = value;

                switch (_player_state) {
                    case PlayerState.NONE:
                        playbin.set_state (Gst.State.NULL);
                        break;
                    case PlayerState.PLAYING:
                        playbin.set_state (Gst.State.PLAYING);
                        break;
                    case PlayerState.PAUSED:
                        playbin.set_state (Gst.State.PAUSED);
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

                if (player_type == PlayerModeType.NONE) {
                    return;
                }

                near_changed (get_current_track ());
            }
        }

        ShuffleMode _shuffle_mode = ShuffleMode.OFF;
        public ShuffleMode shuffle_mode {
            get {
                return _shuffle_mode;
            }
            set {
                _shuffle_mode = value;

                if (player_type == PlayerModeType.NONE) {
                    return;
                }

                var player_tl = player_mode as PlayerTrackList;
                switch (_shuffle_mode) {
                    case ShuffleMode.ON:
                        player_tl.shuffle ();
                        break;

                    case ShuffleMode.OFF:
                        player_tl.unshuffle ();
                        break;
                }

                if (settings.get_boolean ("can-cache")) {
                    prepare_next_track.begin ();
                }

                near_changed (get_current_track ());
            }
        }

        public double volume { get; set; }
        public bool mute { get; set; }

        public double playback_pos_sec {
            get {
                int64 cur;
                playbin.query_position (Gst.Format.TIME, out cur);
                return (double) cur / Gst.SECOND;
            }
        }

        public int64 playback_pos_ms {
            get {
                int64 cur;
                playbin.query_position (Gst.Format.TIME, out cur);
                return cur / Gst.MSECOND;
            }
        }

        public PlayerModeType player_type { get; private set; }

        public signal void near_changed (YaMAPI.Track? new_current_track_info);

        public signal void queue_changed (YaMAPI.Queue queue);

        public signal void paused (YaMAPI.Track track_info);
        public signal void played (YaMAPI.Track track_info);
        public signal void stopped ();

        public signal void next_done ();
        public signal void prev_done ();

        public signal void mode_inited (PlayerModeType player_type);

        // playback_callback поднимается, если время воспроизведения > 0
        public signal void playback_callback (double playback_pos_sec);

        public bool is_loading { get; private set; }

        // Начало загрузки текущего трека
        public signal void current_track_start_loading ();
        // Окончание загрузки текущего трека
        public signal void current_track_finish_loading ();

        PlayerMode? _player_mode = null;
        PlayerMode? player_mode {
            get {
                return _player_mode;
            }
            set {
                _player_mode = value;

                if (_player_mode != null) {
                    player_mode.near_changed.connect (() => {
                        near_changed (_player_mode.get_current_track ());
                    });

                    if (_player_mode is PlayerTrackList) {
                        player_type = PlayerModeType.TRACK_LIST;

                        ((PlayerTrackList) _player_mode).queue_changed.connect ((queue) => {
                            queue_changed (queue);
                        });

                    } else if (_player_mode is PlayerFlow) {
                        player_type = PlayerModeType.FLOW;

                    } else {
                        assert_not_reached ();
                    }
                } else {
                    player_type = PlayerModeType.NONE;
                }
            }
        }

        Gst.Element playbin;

        //  Gst.Pipeline pipeline;
        //  Gst.Element source;
        //  Gst.Element _volume_el;

        public Player () {
            Object ();
        }

        construct {
            init (null);

            playbin = Gst.ElementFactory.make ("playbin", null);
            var bus = playbin.get_bus ();

            bus.add_signal_watch ();
            bus.message["eos"].connect ((bus, message) => {
                next_repeat ();
            });

            settings.bind ("repeat-mode", this, "repeat-mode", SettingsBindFlags.DEFAULT);
            settings.bind ("shuffle-mode", this, "shuffle-mode", SettingsBindFlags.DEFAULT);

            current_track_start_loading.connect (() => {
                is_loading = true;
            });
            current_track_finish_loading.connect (() => {
                is_loading = false;
            });

            bind_property ("volume", playbin, "volume", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);
            settings.bind ("volume", this, "volume", SettingsBindFlags.DEFAULT);

            bind_property ("mute", playbin, "mute", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);
            settings.bind ("mute", this, "mute", SettingsBindFlags.DEFAULT);

            Timeout.add ((int) (PLAY_STEP * 1000), () => {
                if (playback_pos_sec > 0.0) {
                    playback_callback (playback_pos_sec);
                }

                return Source.CONTINUE;
            });
        }

        void init (string[]? args) {
            Gst.init (ref args);
        }

        public void seek (int64 ms) {
            playbin.seek_simple (Gst.Format.TIME, Gst.SeekFlags.FLUSH | Gst.SeekFlags.KEY_UNIT, ms * Gst.MSECOND);
        }

        public async YaMAPI.Track? get_prev_track () {
            if (player_type != PlayerModeType.NONE) {
                return yield player_mode.get_prev_track ();
            } else {
                return null;
            }
        }

        public YaMAPI.Track? get_current_track () {
            if (player_type != PlayerModeType.NONE) {
                return player_mode.get_current_track ();
            } else {
                return null;
            }
        }

        public async YaMAPI.Track? get_next_track () {
            if (player_type != PlayerModeType.NONE) {
                return yield player_mode.get_next_track ();
            } else {
                return null;
            }
        }

        public void start_flow (YaMAPI.Queue queue) {
            stop ();

            player_mode = new PlayerFlow (this, queue);

            mode_inited (PlayerModeType.FLOW);
        }

        void set_queue (YaMAPI.Queue queue) {
            stop ();

            var playertl = new PlayerTrackList (this);
            player_mode = playertl;
            playertl.queue = queue;

            mode_inited (PlayerModeType.TRACK_LIST);
        }

        public void start_queue (YaMAPI.Queue queue) {
            set_queue (queue);

            start_current_track.begin ();
        }

        // Запустить очередь, но без старта трека
        public void start_queue_init (YaMAPI.Queue queue) {
            set_queue (queue);

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

            var current_track = get_current_track ();

            if (current_track != null) {
                played (current_track);
            }
        }

        public void pause () {
            player_state = PlayerState.PAUSED;

            var current_track = get_current_track ();

            if (current_track != null) {
                paused (current_track);
            }
        }

        public void stop () {
            playbin.set_property ("uri", Value (Type.STRING));

            pause ();

            var current_track = get_current_track ();

            if (current_track != null) {
                if (current_track.track_type != YaMAPI.TrackType.LOCAL) {
                    send_play_audio.begin ((current_track as YaMAPI.Track), playback_pos_sec);
                }
            }

            player_state = PlayerState.NONE;
            stopped ();
        }

        void next_repeat () {
            stop ();

            player_mode.next (true);
            start_current_track.begin (() => {
                next_done ();
            });
        }

        public void next () {
            stop ();

            player_mode.next (false);
            start_current_track.begin (() => {
                next_done ();
            });
        }

        public void prev () {
            if (playback_pos_sec > 3.0) {
                seek (0);
            } else {
                stop ();

                player_mode.prev ();
                start_current_track.begin (() => {
                    prev_done ();
                });
            }
        }

        public void change_track (YaMAPI.Track track_info) {
            /*
                Находит трек в очереди и воспроизводит его
            */
            stop ();

            assert (player_type == PlayerModeType.TRACK_LIST);

            var playertl = player_mode as PlayerTrackList;
            playertl.change_track (track_info);

            start_current_track.begin (() => {
                next_done ();
            });
        }

        public async void start_current_track () {
            var current_track = get_current_track ();

            if (current_track == null) {
                return;
            }

            current_track_start_loading ();

            if (current_track.track_type != YaMAPI.TrackType.LOCAL) {
                send_play_audio.begin (((YaMAPI.Track) current_track), 0.0);

                string? track_uri = yield Cachier.get_track_uri (current_track.id);
                if (track_uri == null) {
                    playbin.set_property ("uri", Value (Type.STRING));
                } else {
                    playbin.set_property ("uri", track_uri);

                    play ();
                    storager.clear_temp_track ();
                }

            } else {
                // У локальных треков id - их uri
                playbin.set_property ("uri", current_track.id);

                play ();
            }

            current_track_finish_loading ();

            if (settings.get_boolean ("can-cache")) {
                prepare_next_track.begin ();
            }
        }

        async void send_play_audio (YaMAPI.Track track_info, double play_position_sec) {
            threader.add_single (() => {
                var playertl = player_mode as PlayerTrackList;
                if (playertl != null) {
                    string? playlist_id = playertl.queue.context.type_ == "playlist" ? playertl.queue.context.id : null;
                    yam_talker.play_audio (track_info, playlist_id, play_position_sec);
                } else {
                    yam_talker.play_audio (track_info, null, play_position_sec);
                }

                Idle.add (send_play_audio.callback);
            });

            yield;
        }

        async void prepare_next_track () {
            var next_track = (yield player_mode.get_next_track ()) as YaMAPI.Track;

            if (next_track != get_current_track () && next_track != null) {
                Cachier.save_track.begin (next_track);
            }
        }

        public void add_track (YaMAPI.Track track_info, bool is_next) {
            assert (player_type == PlayerModeType.TRACK_LIST);

            var player_tl = player_mode as PlayerTrackList;
            if (is_next) {
                player_tl.add_track_next (track_info);
            } else {
                player_tl.add_track_end (track_info);
            }

            if (settings.get_boolean ("can-cache")) {
                prepare_next_track.begin ();
            }
        }

        public void add_many (ArrayList<YaMAPI.Track> track_list) {
            assert (player_type == PlayerModeType.TRACK_LIST);

            var player_tl = player_mode as PlayerTrackList;
            if (player_tl != null) {
                player_tl.add_many_end (track_list);

                if (settings.get_boolean ("can-cache")) {
                    prepare_next_track.begin ();
                }
            }
        }

        public void remove_track_by_pos (uint position) {
            assert (player_type == PlayerModeType.TRACK_LIST);

            var player_tl = player_mode as PlayerTrackList;
            player_tl.remove_track_by_pos (position);

            if (player_tl.queue.tracks.size != 0 && settings.get_boolean ("can-cache")) {
                prepare_next_track.begin ();
            }
        }

        public void remove_track (YaMAPI.Track track_info) {
            assert (player_type == PlayerModeType.TRACK_LIST);

            var player_tl = player_mode as PlayerTrackList;
            if (player_tl != null) {
                player_tl.remove_track (track_info);

                if (player_tl.queue.tracks.size != 0 && settings.get_boolean ("can-cache")) {
                    prepare_next_track.begin ();
                }
            }
        }

        public void remove_all_tracks () {
            assert (player_type == PlayerModeType.TRACK_LIST);

            var player_tl = player_mode as PlayerTrackList;
            if (player_tl != null) {
                player_tl.remove_all_tracks ();
            }
        }

        public YaMAPI.Queue get_queue () {
            assert (player_type == PlayerModeType.TRACK_LIST);

            var player_tl = player_mode as PlayerTrackList;
            return player_tl.queue;
        }
    }
}
