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

    /**
     * Abstract class of player mode.
     * Player can work with flow (radio), track list, local track list.
     * Every mode autoconnect to ``Player.queue_changed`` and
     * ``Player.nead_changed`` signals.
     */
    public abstract class PlayerMode: Object {

        /**
         * Queue changed.
         * Triggers when track added/removed
         *
         * @param queue         queue with tracks
         * @param content_type  type of played context. E.g. "radio"
         * @param context_id    id ofplayed context. E.g. "666824:3" for
         *                      "playlist" context type
         */
        public signal void queue_changed (
            ArrayList<YaMAPI.Track> queue,
            string context_type,
            string context_id,
            int current_index,
            string context_description
        );

        /**
         * Tracks near current changed.
         * Trigger when current/prev/next tracks changed.
         *
         * @param current_track_info    current track info
         */
        public signal void near_changed (
            YaMAPI.Track current_track_info
        );

        /**
         * Parent player object.
         */
        public Player player { get; construct; }

        /**
         * Queue with tracks.
         */
        public ArrayList<YaMAPI.Track> queue { get; construct; }

        public int current_index { get; construct set; default = -1; }

        /**
         * Type of played context. E.g. "radio"
         */
        public string context_type { get; construct set; }

        /**
         * id ofplayed context. E.g. "666824:3" for "playlist" context type
         */
        public string? context_id { get; construct set; }

        /**
         * What playing now
         */
        public string? context_description { get; construct set; }

        construct {
            queue_changed.connect (() => {
                player.queue_changed (
                    queue,
                    context_type,
                    context_id,
                    current_index,
                    context_description
                );
            });

            near_changed.connect (() => {
                player.near_changed (
                    get_current_track_info ()
                );
            });

            Logger.debug ("Created track list player");
            Logger.debug ("Queue size: %d".printf (queue.size));
            Logger.debug ("Context type: %s".printf (context_type));
            Logger.debug ("Context id: %s".printf (context_id));
            Logger.debug ("Current index: %d".printf (current_index));
            Logger.debug ("Context descriprion: %s".printf (context_description));
        }

        /**
         * Asynchronous getting previous track info.
         *
         * @return  track information object
         */
        public abstract async YaMAPI.Track? get_prev_track_info_async ();

        /**
         * Getting current track info.
         *
         * @return  track information object
         */
        public abstract YaMAPI.Track? get_current_track_info ();

        /**
         * Asynchronous getting next track info.
         *
         * @return  track information object
         */
        public abstract async YaMAPI.Track? get_next_track_info_async ();

        /**
         * Form Play object foe play feedback.
         *
         * @return  ``Cassette.Client.YaMAPI.Play`` object
         */
        public abstract YaMAPI.Play form_play_obj ();

        /**
         * Change current track to next in queue or flow.
         *
         * @param consider_repeat_mode  if ``true``, ignore repeat mode and go to next
         *                              else consider repeat
         */
        public abstract void next (bool consider_repeat_mode);

        /**
         * Change current track to previous in queue.
         */
        public abstract void prev ();

        /**
         * Try to find track and play it.
         *
         * @param track_info    track information
         *
         * @return              ``true`` if track found and ``false`` otherwise
         */
        public bool change_track (YaMAPI.Track track_info) {
            for (int i = 0; i < queue.size; i++) {
                if (queue[i].id == track_info.id) {
                    current_index = i;
                    near_changed (track_info);

                    return true;
                }
            }

            return false;
        }
    }

    public class Player : Object {

        PlayerState _player_state = PlayerState.NONE;
        /**
         * Player state.
         */
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
        /**
         * Player repeat mode.
         */
        public RepeatMode repeat_mode {
            get {
                return _repeat_mode;
            }
            set {
                _repeat_mode = value;

                if (player_type == PlayerModeType.NONE) {
                    return;
                }

                near_changed (get_current_track_info ());
            }
        }

        ShuffleMode _shuffle_mode = ShuffleMode.OFF;
        /**
         * Player shuffle mode.
         */
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

                near_changed (get_current_track_info ());
            }
        }

        public double playback_pos_sec {
            get {
                int64 cur;
                playbin.query_position (Gst.Format.TIME, out cur);
                return (double) cur / Gst.SECOND;
            }
        }

        public double total_playback_sec { get; set; default = 0.0;}

        public int64 playback_pos_ms {
            get {
                int64 cur;
                playbin.query_position (Gst.Format.TIME, out cur);
                return cur / Gst.MSECOND;
            }
        }

        /**
         * Queue changed.
         * Triggers when track added/removed
         */
        public signal void queue_changed (
            ArrayList<YaMAPI.Track> queue,
            string context_type,
            string context_id,
            int current_index,
            string context_description
        );

        /**
         * Tracks near current changed.
         * Trigger when current/prev/next tracks changed.
         */
        public signal void near_changed (
            YaMAPI.Track current_track_info
        );

        /**
         * Player volume.
         */
        public double volume { get; set; }

        /**
         * Is player mute or not.
         */
        public bool mute { get; set; }

        /**
         * Can player go prev.
         */
        public bool can_go_prev { get; private set; default = true; }

        /**
         * Can player be seeked.
         */
        public bool can_seek { get; private set; }

        /**
         * Is current track loading.
         */
        public bool track_loading { get; private set; }

        /**
         * Feedback.
         * Triggered when track paused.
         *
         * @param track_info    track that been paused
         */
        public signal void paused (YaMAPI.Track track_info);

        /**
         * Feedback.
         * Triggered when track start playing.
         *
         * @param track_info    track that start playing
         */
        public signal void played (YaMAPI.Track track_info);

        /**
         * Feedback.
         * Triggered when track stopped.
         */
        public signal void stopped ();

        /**
         * Next track ready to show.
         */
        public signal void next_done ();

        /**
         * Previous track ready to show.
         */
        public signal void prev_done ();

        /**
         * Callback of playback.
         */
        public signal void playback_callback (double playback_pos_sec);

        /**
         * Track loading started.
         */
        public signal void current_track_start_loading ();

        /**
         * Track loading finished.
         */
        public signal void current_track_finish_loading ();

        /**
         * Player mode changed.
         */
        public signal void mode_changed (PlayerModeType new_player_type);

        PlayerModeType _player_type = PlayerModeType.NONE;
        /**
         * Type of current player mode.
         */
        public PlayerModeType player_type {
            get {
                return _player_type;
            }
            set {
                _player_type = value;

                mode_changed (_player_type);
            }
        }

        PlayerMode? _player_mode = null;
        /**
         * Current player mode.
         * Has interface - player_type.
         */
        public PlayerMode? player_mode {
            get {
                return _player_mode;
            }
            set {
                _player_mode = value;

                if (_player_mode is PlayerTrackList) {
                    player_type = PlayerModeType.TRACK_LIST;

                } else if (_player_mode is PlayerFlow) {
                    player_type = PlayerModeType.FLOW;

                } else if (_player_mode == null) {
                    player_type = PlayerModeType.NONE;

                } else {
                    assert_not_reached ();
                }
            }
        }

        const double PLAY_CALLBACK_STEP = 0.1;

        string play_id { get; set; }

        Gst.Element playbin;

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
                track_loading = true;
            });
            current_track_finish_loading.connect (() => {
                track_loading = false;
            });

            bind_property ("volume", playbin, "volume", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);
            settings.bind ("volume", this, "volume", SettingsBindFlags.DEFAULT);

            bind_property ("mute", playbin, "mute", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);
            settings.bind ("mute", this, "mute", SettingsBindFlags.DEFAULT);

            playback_callback.connect (() => {
                total_playback_sec += PLAY_CALLBACK_STEP;
            });

            Timeout.add ((int) (PLAY_CALLBACK_STEP * 1000.0), () => {
                if (playback_pos_sec > 0.0 && player_state == PlayerState.PLAYING) {
                    playback_callback (playback_pos_sec);
                }

                if (player_mode?.current_index != 0 || repeat_mode != RepeatMode.OFF || playback_pos_sec > 3.0) {
                    can_go_prev = true;
                } else {
                    can_go_prev = false;
                }

                return Source.CONTINUE;
            });
        }

        void reset_play () {
            play_id = Uuid.string_random ();
            total_playback_sec = 0.0;
        }

        void init (string[]? args) {
            Gst.init (ref args);
        }

        public void seek (int64 ms) {
            playbin.seek_simple (Gst.Format.TIME, Gst.SeekFlags.FLUSH | Gst.SeekFlags.KEY_UNIT, ms * Gst.MSECOND);
        }

        public async YaMAPI.Track? get_prev_track_info_async () {
            if (player_mode != null) {
                return yield player_mode.get_prev_track_info_async ();
            } else {
                return null;
            }
        }

        public YaMAPI.Track? get_current_track_info () {
            return player_mode?.get_current_track_info ();
        }

        public async YaMAPI.Track? get_next_track_info_async () {
            if (player_mode != null) {
                return yield player_mode.get_next_track_info_async ();
            } else {
                return null;
            }
        }

        public void start_flow (
            string station_id,
            ArrayList<YaMAPI.Track>? queue = null
        ) {
            stop ();

            player_mode = new PlayerFlow (
                this,
                station_id,
                queue
            );
        }

        void set_track_list_queue (
            ArrayList<YaMAPI.Track> queue,
            string context_type,
            string? context_id,
            int current_index = 0,
            string? context_description = ""
        ) {
            stop ();

            player_mode = new PlayerTrackList (
                this,
                queue,
                context_type,
                context_id,
                current_index,
                context_description
            );
        }

        public void start_track_list (
            ArrayList<YaMAPI.Track> queue,
            string context_type,
            string? context_id,
            int current_index,
            string? context_description
        ) {
            set_track_list_queue (
                queue,
                context_type,
                context_id,
                current_index,
                context_description
            );

            start_current_track.begin ();
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

            var current_track = get_current_track_info ();

            if (current_track != null) {
                played (current_track);
            }
        }

        public void pause () {
            player_state = PlayerState.PAUSED;

            var current_track = get_current_track_info ();

            if (current_track != null) {
                paused (current_track);
            }
        }

        public void stop () {
            playbin.set_property ("uri", Value (Type.STRING));

            pause ();

            var current_track = get_current_track_info ();

            if (current_track != null) {
                if (current_track.track_type != YaMAPI.TrackType.LOCAL) {
                    send_play_current_async.begin (playback_pos_sec, total_playback_sec);
                }
            }

            player_state = PlayerState.NONE;
            reset_play ();

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
            /**
                Находит трек в очереди и воспроизводит его
            */
            stop ();

            player_mode.change_track (track_info);

            start_current_track.begin (() => {
                next_done ();
            });
        }

        public async void start_current_track () {
            var current_track = get_current_track_info ();

            if (current_track == null) {
                return;
            }

            current_track_start_loading ();

            if (current_track.track_type != YaMAPI.TrackType.LOCAL) {
                send_play_current_async.begin ();

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

        async void send_play_current_async (
            double end_position_seconds = 0.0,
            double total_played_seconds = 0.0
        ) {
            assert (player_mode != null);

            var play_obj = player_mode.form_play_obj ();

            play_obj.play_id = play_id;
            play_obj.end_position_seconds = end_position_seconds;
            play_obj.total_played_seconds = total_played_seconds;

            Logger.debug ("Track id %s: end: %f; total: %f, dur: %f".printf (
                play_obj.track_id,
                play_obj.end_position_seconds,
                play_obj.total_played_seconds,
                play_obj.track_length_seconds
            ));

            threader.add_single (() => {
                yam_talker.send_play ({play_obj});

                Idle.add (send_play_current_async.callback);
            });

            yield;
        }

        async void prepare_next_track () {
            var next_track = yield get_next_track_info_async ();

            if (next_track != get_current_track_info () && next_track != null) {
                Cachier.save_track.begin (next_track);
            }
        }

        public void add_track (YaMAPI.Track track_info, bool is_next) {
            assert (player_type == PlayerModeType.TRACK_LIST);

            var player_tl = (PlayerTrackList) player_mode;
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

            var player_tl = (PlayerTrackList) player_mode;
            player_tl.add_many_end (track_list);

            if (settings.get_boolean ("can-cache")) {
                prepare_next_track.begin ();
            }
        }

        public void remove_track_by_pos (int position) {
            assert (player_type == PlayerModeType.TRACK_LIST);

            var player_tl = (PlayerTrackList) player_mode;
            player_tl.remove_track_by_pos (position);

            if (player_tl.queue.size != 0 && settings.get_boolean ("can-cache")) {
                prepare_next_track.begin ();
            }
        }

        public void remove_track (YaMAPI.Track track_info) {
            assert (player_type == PlayerModeType.TRACK_LIST);

            var player_tl = (PlayerTrackList) player_mode;
            player_tl.remove_track (track_info);

            if (player_tl.queue.size != 0 && settings.get_boolean ("can-cache")) {
                prepare_next_track.begin ();
            }
        }

        public void remove_all_tracks () {
            assert (player_type == PlayerModeType.TRACK_LIST);

            var player_tl = (PlayerTrackList) player_mode;
            player_tl.remove_all_tracks ();
        }
    }
}
