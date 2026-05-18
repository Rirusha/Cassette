[CCode (cname = "CassetteNowPlayingCmd", has_target = false)]
public delegate void MacOsNowPlayingCmd ();

[CCode (cname = "CassetteNowPlayingSeekCmd", has_target = false)]
public delegate void MacOsNowPlayingSeekCmd (double position_sec);

[CCode (cname = "cassette_now_playing_init", cheader_filename = "macos-now-playing.h")]
public extern void cassette_now_playing_init (
    MacOsNowPlayingCmd     on_play,
    MacOsNowPlayingCmd     on_pause,
    MacOsNowPlayingCmd     on_play_pause,
    MacOsNowPlayingCmd     on_next,
    MacOsNowPlayingCmd     on_prev,
    MacOsNowPlayingSeekCmd on_seek
);

[CCode (cname = "cassette_now_playing_update", cheader_filename = "macos-now-playing.h")]
public extern void cassette_now_playing_update (
    string  title,
    string  artist,
    string  album,
    double  duration_sec,
    double  elapsed_sec,
    bool    is_playing,
    string? artwork_url
);

[CCode (cname = "cassette_now_playing_update_state", cheader_filename = "macos-now-playing.h")]
public extern void cassette_now_playing_update_state (double elapsed_sec, bool is_playing);

[CCode (cname = "cassette_now_playing_clear", cheader_filename = "macos-now-playing.h")]
public extern void cassette_now_playing_clear ();
