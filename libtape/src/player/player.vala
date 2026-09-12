/*
 * Copyright (C) 2024-2026 Vladimir Romanov <rirusha@altlinux.org>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Gee;

public sealed class Tape.Player : Object {

    PlayerState _state = PlayerState.NONE;
    public PlayerState state {
        get {
            return _state;
        }
        private set {
            _state = value;

            switch (_state) {
                case PlayerState.NONE:
                    gst_player.stop ();
                    break;

                case PlayerState.PLAYING:
                    gst_player.play ();
                    break;

                case PlayerState.PAUSED:
                    gst_player.pause ();
                    break;
            }
        }
    }

    public RepeatMode repeat_mode { get; set; default = RepeatMode.OFF; }

    ShuffleMode _shuffle_mode = ShuffleMode.OFF;
    public ShuffleMode shuffle_mode {
        get {
            return _shuffle_mode;
        }
        set {
            _shuffle_mode = value;

            var shufflable_mode = mode as PlayerShufflable;

            if (shufflable_mode != null) {
                switch (_shuffle_mode) {
                    case ShuffleMode.ON:
                        shufflable_mode.shuffle ();
                        break;

                    case ShuffleMode.OFF:
                        shufflable_mode.unshuffle ();
                        break;
                }

                update_player ();

                if (root.settings.can_cache) {
                    cache_next_track ();
                }
            }
        }
    }

    /**
     * You can get position via:
     * - position
     * - position_sec
     * - position_us
     */
    public signal void position_changed (int64 position);

    public double total_played_seconds { get; set; default = 0.0; }

    /**
     * Current position in milliseconds.
     */
    public int64 position {
        get {
            //  int64 cur;
            //  playbin.query_position (Gst.Format.TIME, out cur);
            //  return cur / Gst.MSECOND;
            return 0;
        }
    }

    /**
     * Current position in seconds.
     */
    public double position_sec {
        get {
            //  int64 cur;
            //  playbin.query_position (Gst.Format.TIME, out cur);
            //  return ((double) cur) / Gst.SECOND;
            return 0;
        }
    }

    /**
     * Current position in microseconds.
     */
    public int64 position_us {
        get {
            //  int64 cur;
            //  playbin.query_position (Gst.Format.TIME, out cur);
            //  return cur / Gst.USECOND;
            return 0;
        }
    }

    public signal void queue_changed (
        Serialize.Array<YaMAPI.Track> queue,
        string context_type,
        string? context_id,
        int current_index,
        string? context_description
    );

    public bool can_go_force_prev {
        get {
            return mode.get_prev_index () != -1 && !current_track_loading;
        }
    }

    public double volume { get; set; }

    public bool mute { get; set; }

    public bool can_go_prev { get; private set; default = true; }

    public bool can_go_next { get; private set; default = true; }

    public bool can_play { get; private set; default = true; }

    public bool can_pause { get; private set; default = true; }

    public bool can_seek { get; private set; default = true; }

    /**
     * Is current track loading.
     */
    public bool current_track_loading { get; private set; default = false; }

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
     * Triggered when player stopped.
     */
    public signal void stopped ();

    /**
     * Feedback.
     * Triggered when track stopped.
     */
    public signal void track_stopped ();

    /**
     * Next track loaded and ready to play.
     * For situations where there was a switch to
     * the next track so that the interface could react correctly.
     */
    public signal void ready_play_next ();

    /**
     * Previous track loaded and ready to play.
     * For situations where there was a switch to
     * the previous track so that the interface could react correctly.
     */
    public signal void ready_play_prev ();

    /**
     * Triggers when previous track in queue finish loading.
     * For next track show posibility.
     */
    public signal void next_track_loaded (YaMAPI.Track? next_track);

    /**
     * Current track started loaded.
     * Inteface should block for interaction.
     */
    public signal void current_track_start_loading ();

    /**
     * Current track started loaded.
     * Inteface can be released from block.
     */
    public signal void current_track_finish_loading (YaMAPI.Track track_info);

    public signal void playback_callback (double position_sec);

    public signal void mode_inited ();

    public PlayerMode mode { get; private set; }

    const double PLAY_CALLBACK_STEP = 1.0;

    string play_id { get; set; default = ""; }

    internal GstPlayer gst_player = new GstPlayer ();

    construct {
        mode = new PlayerEmpty (this);


        //  bus.add_signal_watch ();
        //  bus.message["eos"].connect ((bus, message) => {
        //      next_natural.begin ();
        //  });

        //  root.settings.bind_property ("repeat-mode", this, "repeat-mode");
        //  root.settings.bind_property ("shuffle-mode", this, "shuffle-mode");

        //  current_track_start_loading.connect (() => {
        //      current_track_loading = true;
        //  });
        //  current_track_finish_loading.connect (() => {
        //      current_track_loading = false;
        //  });

        //  bind_property ("volume", playbin, "volume", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);
        //  root.settings.bind_property ("volume", this, "volume");

        //  bind_property ("mute", playbin, "mute", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);
        //  root.settings.bind_property ("mute", this, "mute");

        //  next_track_loaded.connect (() => {
        //      update_player ();
        //  });

        //  mode_inited.connect (update_player);

        //  Timeout.add ((int) (PLAY_CALLBACK_STEP * 1000.0), () => {
        //      send_callback ();

        //      total_played_seconds += PLAY_CALLBACK_STEP;

        //      return Source.CONTINUE;
        //  });
    }

    public void play_file (File file) throws PlayerError {
        gst_player.set_file (file);
        gst_player.play ();
    }
















    void send_callback () {
        if (position_sec > 0.0 && state == PlayerState.PLAYING) {
            playback_callback (position_sec);
        }
    }

    void update_player () {
        var cgn = mode.get_next_index (true) != -1 && !current_track_loading;
        var cgp = mode.get_prev_index () != -1 || position_sec > 3.0 && !current_track_loading;

        // Trigger notify::can-go-next and notify::can-go-prev only on changed
        if (cgn != can_go_next) {
            can_go_next = cgn;
        }

        if (cgp != can_go_prev) {
            can_go_prev = cgp;
        }

        send_callback ();
    }

    void reset_play () {
        play_id = Uuid.string_random ();
        total_played_seconds = 0.0;

        update_player ();
    }

    void init (string[]? args) {
        Gst.init (ref args);
    }

    public void seek (int64 ms) {
        if (ms < 0) {
            ms = 0;
        }

        update_player ();
        //  playbin.seek_simple (Gst.Format.TIME, Gst.SeekFlags.FLUSH | Gst.SeekFlags.KEY_UNIT, ms * Gst.MSECOND);
    }

    public async void start_flow (
        string station_id,
        Serialize.Array<YaMAPI.Track> queue = new Serialize.Array<YaMAPI.Track> ()
    ) throws CantUseError {
        stop ();

        if (repeat_mode == RepeatMode.QUEUE) {
            repeat_mode = RepeatMode.OFF;
        }

        var flow_queue = new Serialize.Array<YaMAPI.Track> ();

        foreach (var track_info in queue) {
            if (!track_info.is_ugc) {
                flow_queue.add (track_info);
            }
        }

        var flow = new PlayerFlow (
            this,
            station_id,
            flow_queue
            );

        mode = flow;

        current_track_start_loading ();

        if (yield flow.init_async ()) {
            current_track_finish_loading (mode.get_current_track_info ());

            mode_inited ();

            start_current_track.begin ();
        }
    }

    public void start_track_list (Serialize.Array<YaMAPI.Track> queue,
                                  string context_type,
                                  string? context_id,
                                  int current_index,
                                  string? context_description) {
        stop ();

        mode = new PlayerTrackList (
            this,
            queue,
            context_type,
            context_id,
            current_index,
            context_description
            );

        mode_inited ();

        start_current_track.begin ();
    }

    public void clear_mode () {
        stop ();

        mode = new PlayerEmpty (this);

        mode_inited ();
    }

    public void play_pause () {
        switch (state) {
            case PlayerState.PLAYING :
                pause ();
                break;

            case PlayerState.PAUSED :
                play ();
                break;

            default:
                start_current_track.begin ();
                break;
        }
    }

    public void play () {
        state = PlayerState.PLAYING;

        var current_track = mode.get_current_track_info ();

        if (current_track != null) {
            played (current_track);
        }
    }

    public void pause () {
        state = PlayerState.PAUSED;

        var current_track = mode.get_current_track_info ();

        if (current_track != null) {
            paused (current_track);
        }
    }

    void track_stop (bool natural) {
        //  playbin.set_property ("uri", Value (Type.STRING));

        state = PlayerState.NONE;

        var current_track = mode.get_current_track_info ();

        mode.send_play_async.begin (
            play_id,
            natural ? ms2sec (mode.get_current_track_info ().duration_ms) : position_sec,
            total_played_seconds
            );

        if (mode is PlayerFlow) {
            ((PlayerFlow) mode).send_feedback.begin (
                natural ? YaMAPI.Rotor.FeedbackType.TRACK_FINISHED : YaMAPI.Rotor.FeedbackType.SKIP,
                current_track.id,
                total_played_seconds
                );
        }

        reset_play ();

        track_stopped ();
    }

    public void stop () {
        track_stop (false);

        stopped ();
    }

    async void next_natural () throws CantUseError {
        if (mode.current_index == mode.get_next_index (true)) {
            seek (0);
            return;
        }

        track_stop (true);

        yield mode.next (true);

        if (mode.current_index != -1) {
            start_current_track.begin (() => {
                ready_play_next ();
            });
        }
    }

    public async void next () throws CantUseError {
        track_stop (false);

        yield mode.next (false);

        if (mode.current_index != -1) {
            start_current_track.begin (() => {
                ready_play_next ();
            });
        }
    }

    public void prev (bool ignore_progress = false) {
        if (position_sec > 3.0 && !ignore_progress) {
            seek (0);
            return;
        }

        track_stop (false);

        mode.prev ();

        start_current_track.begin (() => {
            ready_play_prev ();
        });
    }

    public void change_track (YaMAPI.Track track_info) {
        /**
            Находит трек в очереди и воспроизводит его
         */
        track_stop (false);

        mode.change_track (track_info);

        start_current_track.begin (() => {
            ready_play_next ();
        });
    }

    public async void start_current_track () throws CantUseError {
        var current_track = mode.get_current_track_info ();

        if (current_track == null) {
            return;
        }

        current_track_start_loading ();

        mode.send_play_async.begin (play_id);
        if (mode is PlayerFlow) {
            ((PlayerFlow) mode).send_feedback.begin (
                YaMAPI.Rotor.FeedbackType.TRACK_STARTED,
                current_track.id
                );
        }

        //  string? track_uri = yield Cachier.get_track_uri (current_track.id);

        //  if (track_uri == null) {
        //      playbin.set_property ("uri", Value (Type.STRING));
        //  } else {
        //      playbin.set_property ("uri", track_uri);

        //      play ();
        //      //  root.cachier.storager.clear_temp_track ();
        //  }

        current_track_finish_loading (current_track);

        if (root.settings.can_cache) {
            cache_next_track ();
        }

        if (mode.get_next_index (false) == -1) {
            if (mode is PlayerFlow) {
                yield ((PlayerFlow) mode).prepare_next_track ();
            }
        }

        update_player ();
    }

    void cache_next_track () {
        var next_track = mode.get_next_track_info (false);

        //  if (next_track != mode.get_current_track_info () && next_track != null) {
        //      Cachier.save_track.begin (next_track);
        //  }
    }

    public void add_track (YaMAPI.Track track_info,
                           bool is_next) {
        if (mode is PlayerEmpty) {
            var track_list = new Serialize.Array<YaMAPI.Track> ();
            track_list.add (track_info);

            add_many (track_list);
            return;
        }

        var sh_mode = mode as PlayerShufflable;

        if (sh_mode == null) {
            return;
        }

        if (is_next) {
            sh_mode.add_track_next (track_info);
        } else {
            sh_mode.add_track_end (track_info);
        }

        if (root.settings.can_cache) {
            cache_next_track ();
        }
    }

    public void add_many (Serialize.Array<YaMAPI.Track> track_list) {
        if (mode is PlayerEmpty) {
            start_track_list (
                track_list,
                "various",
                null,
                0,
                null
                );
            return;
        }

        var sh_mode = mode as PlayerShufflable;

        if (sh_mode == null) {
            return;
        }

        sh_mode.add_many_end (track_list);

        if (root.settings.can_cache) {
            cache_next_track ();
        }
    }

    public void remove_track_by_pos (int position) {
        var sh_mode = mode as PlayerShufflable;

        if (sh_mode == null) {
            return;
        }

        sh_mode.remove_track_by_pos (position);

        if (sh_mode.queue.size != 0 && root.settings.can_cache) {
            cache_next_track ();
        }
    }

    public void remove_track (YaMAPI.Track track_info) {
        var sh_mode = mode as PlayerShufflable;

        if (sh_mode == null) {
            return;
        }

        sh_mode.remove_track (track_info);

        if (sh_mode.queue.size != 0 && root.settings.can_cache) {
            cache_next_track ();
        }
    }

    public void rotor_feedback (string feedback_type,
                                string track_id) {
        if (mode is PlayerFlow && mode.get_current_track_info ().id == track_id) {
            ((PlayerFlow) mode).send_feedback.begin (
                feedback_type,
                track_id,
                total_played_seconds
                );
        }
    }
}
