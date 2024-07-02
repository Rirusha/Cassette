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


using Gee;

public enum Cassette.Client.Player.State {
    NONE,
    PLAYING,
    PAUSED
}

public enum Cassette.Client.Player.RepeatMode {
    OFF,
    ONE,
    QUEUE
}

public enum Cassette.Client.Player.ShuffleMode {
    OFF,
    ON
}

public class Cassette.Client.Player.Player : Object {

    State _state = State.NONE;
    public State state {
        get {
            return _state;
        }
        private set {
            _state = value;

            switch (_state) {
                case State.NONE:
                    playbin.set_state (Gst.State.NULL);
                    break;
                case State.PLAYING:
                    playbin.set_state (Gst.State.PLAYING);
                    break;
                case State.PAUSED:
                    playbin.set_state (Gst.State.PAUSED);
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

            var shufflable_mode = mode as Shufflable;

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

                if (settings.get_boolean ("can-cache")) {
                    cache_next_track ();
                }
            }
        }
    }

    public double playback_pos_sec {
        get {
            int64 cur;
            playbin.query_position (Gst.Format.TIME, out cur);
            return (double) cur / Gst.SECOND;
        }
    }

    public double total_played_seconds { get; set; default = 0.0;}

    public int64 playback_pos_ms {
        get {
            int64 cur;
            playbin.query_position (Gst.Format.TIME, out cur);
            return cur / Gst.MSECOND;
        }
    }

    public signal void queue_changed (
        ArrayList<YaMAPI.Track> queue,
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

    public signal void playback_callback (double playback_pos_sec);

    public signal void mode_inited ();

    public Mode mode { get; private set; }

    const double PLAY_CALLBACK_STEP = 1.0;

    string play_id { get; set; default = ""; }

    Gst.Element playbin;

    construct {
        init (null);

        mode = new Empty (this);

        playbin = Gst.ElementFactory.make ("playbin", null);
        var bus = playbin.get_bus ();

        bus.add_signal_watch ();
        bus.message["eos"].connect ((bus, message) => {
            next_natural ();
        });

        settings.bind ("repeat-mode", this, "repeat-mode", SettingsBindFlags.DEFAULT);
        settings.bind ("shuffle-mode", this, "shuffle-mode", SettingsBindFlags.DEFAULT);

        current_track_start_loading.connect (() => {
            current_track_loading = true;
        });
        current_track_finish_loading.connect (() => {
            current_track_loading = false;
        });

        bind_property ("volume", playbin, "volume", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);
        settings.bind ("volume", this, "volume", SettingsBindFlags.DEFAULT);

        bind_property ("mute", playbin, "mute", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);
        settings.bind ("mute", this, "mute", SettingsBindFlags.DEFAULT);

        next_track_loaded.connect (() => {
            update_player ();
        });

        mode_inited.connect (update_player);

        Timeout.add ((int) (PLAY_CALLBACK_STEP * 1000.0), () => {
            send_callback ();

            total_played_seconds += PLAY_CALLBACK_STEP;

            return Source.CONTINUE;
        });
    }

    void send_callback () {
        if (playback_pos_sec > 0.0 && state == State.PLAYING) {
            playback_callback (playback_pos_sec);
        }
    }

    void update_player () {
        var cgn = mode.get_next_index (true) != -1 && !current_track_loading;
        var cgp = mode.get_prev_index () != -1 || playback_pos_sec > 3.0 && !current_track_loading;

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
        playbin.seek_simple (Gst.Format.TIME, Gst.SeekFlags.FLUSH | Gst.SeekFlags.KEY_UNIT, ms * Gst.MSECOND);
    }

    public void start_flow (
        string station_id,
        ArrayList<YaMAPI.Track> queue = new ArrayList<YaMAPI.Track> ()
    ) {
        stop ();

        if (repeat_mode == RepeatMode.QUEUE) {
            repeat_mode = RepeatMode.OFF;
        }

        var flow_queue = new ArrayList<YaMAPI.Track> ();

        foreach (var track_info in queue) {
            if (!track_info.is_ugc) {
                flow_queue.add (track_info);
            }
        }

        var flow = new Flow (
            this,
            station_id,
            flow_queue
        );

        mode = flow;

        current_track_start_loading ();

        flow.init_async.begin ((obj, res) => {
            if (flow.init_async.end (res)) {
                current_track_finish_loading (mode.get_current_track_info ());

                mode_inited ();

                start_current_track.begin ();
            }
        });
    }

    public void start_track_list (
        ArrayList<YaMAPI.Track> queue,
        string context_type,
        string? context_id,
        int current_index,
        string? context_description
    ) {
        stop ();

        mode = new TrackList (
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

        mode = new Empty (this);

        mode_inited ();
    }

    public void play_pause () {
        switch (state) {
            case State.PLAYING:
                pause ();
                break;
            case State.PAUSED:
                play ();
                break;
            default:
                start_current_track.begin ();
                break;
        }
    }

    public void play () {
        state = State.PLAYING;

        var current_track = mode.get_current_track_info ();

        if (current_track != null) {
            played (current_track);
        }
    }

    public void pause () {
        state = State.PAUSED;

        var current_track = mode.get_current_track_info ();

        if (current_track != null) {
            paused (current_track);
        }
    }

    void track_stop (bool natural) {
        playbin.set_property ("uri", Value (Type.STRING));

        state = State.NONE;

        var current_track = mode.get_current_track_info ();

        mode.send_play_async.begin (
            play_id,
            natural ? ms2sec (mode.get_current_track_info ().duration_ms) : playback_pos_sec,
            total_played_seconds
        );

        if (mode is Flow) {
            ((Flow) mode).send_feedback.begin (
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

    void next_natural () {
        if (mode.current_index == mode.get_next_index (true)) {
            seek (0);
            return;
        }

        track_stop (true);

        mode.next (true);

        if (mode.current_index != -1) {
            start_current_track.begin (() => {
                ready_play_next ();
            });
        }
    }

    public void next () {
        track_stop (false);

        mode.next (false);

        if (mode.current_index != -1) {
            start_current_track.begin (() => {
                ready_play_next ();
            });
        }
    }

    public void prev (bool ignore_progress = false) {
        if (playback_pos_sec > 3.0 && !ignore_progress) {
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

    public async void start_current_track () {
        var current_track = mode.get_current_track_info ();

        if (current_track == null) {
            return;
        }

        current_track_start_loading ();

        mode.send_play_async.begin (play_id);
        if (mode is Flow) {
            ((Flow) mode).send_feedback.begin (
                YaMAPI.Rotor.FeedbackType.TRACK_STARTED,
                current_track.id
            );
        }

        string? track_uri = yield Cachier.get_track_uri (current_track.id);

        if (track_uri == null) {
            playbin.set_property ("uri", Value (Type.STRING));
        } else {
            playbin.set_property ("uri", track_uri);

            play ();
            storager.clear_temp_track ();
        }

        current_track_finish_loading (current_track);

        if (settings.get_boolean ("can-cache")) {
            cache_next_track ();
        }

        if (mode.get_next_index (false) == -1) {
            (mode as Flow)?.prepare_next_track ();
        }

        update_player ();
    }

    void cache_next_track () {
        var next_track = mode.get_next_track_info (false);

        if (next_track != mode.get_current_track_info () && next_track != null) {
            Cachier.save_track.begin (next_track);
        }
    }

    public void add_track (YaMAPI.Track track_info, bool is_next) {
        if (mode is Empty) {
            var track_list = new ArrayList<YaMAPI.Track> ();
            track_list.add (track_info);

            add_many (track_list);
            return;
        }

        var sh_mode = mode as Shufflable;

        if (sh_mode == null) {
            return;
        }

        if (is_next) {
            sh_mode.add_track_next (track_info);
        } else {
            sh_mode.add_track_end (track_info);
        }

        if (settings.get_boolean ("can-cache")) {
            cache_next_track ();
        }
    }

    public void add_many (ArrayList<YaMAPI.Track> track_list) {
        if (mode is Empty) {
            start_track_list (
                track_list,
                "various",
                null,
                0,
                null
            );
            return;
        }

        var sh_mode = mode as Shufflable;

        if (sh_mode == null) {
            return;
        }

        sh_mode.add_many_end (track_list);

        if (settings.get_boolean ("can-cache")) {
            cache_next_track ();
        }
    }

    public void remove_track_by_pos (int position) {
        var sh_mode = mode as Shufflable;

        if (sh_mode == null) {
            return;
        }

        sh_mode.remove_track_by_pos (position);

        if (sh_mode.queue.size != 0 && settings.get_boolean ("can-cache")) {
            cache_next_track ();
        }
    }

    public void remove_track (YaMAPI.Track track_info) {
        var sh_mode = mode as Shufflable;

        if (sh_mode == null) {
            return;
        }

        sh_mode.remove_track (track_info);

        if (sh_mode.queue.size != 0 && settings.get_boolean ("can-cache")) {
            cache_next_track ();
        }
    }

    public void rotor_feedback (string feedback_type, string track_id) {
        if (mode is Flow && mode.get_current_track_info ().id == track_id) {
            ((Flow) mode).send_feedback.begin (
                feedback_type,
                track_id,
                total_played_seconds
            );
        }
    }
}
