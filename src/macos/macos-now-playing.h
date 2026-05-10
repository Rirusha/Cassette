#pragma once
#include <glib.h>

typedef void (*CassetteNowPlayingCmd)(void);
typedef void (*CassetteNowPlayingSeekCmd)(double position_sec);

void cassette_now_playing_init(
    CassetteNowPlayingCmd    on_play,
    CassetteNowPlayingCmd    on_pause,
    CassetteNowPlayingCmd    on_play_pause,
    CassetteNowPlayingCmd    on_next,
    CassetteNowPlayingCmd    on_prev,
    CassetteNowPlayingSeekCmd on_seek
);

void cassette_now_playing_update(
    const char *title,
    const char *artist,
    const char *album,
    double      duration_sec,
    double      elapsed_sec,
    gboolean    is_playing,
    const char *artwork_url
);

void cassette_now_playing_update_state(double elapsed_sec, gboolean is_playing);

void cassette_now_playing_clear(void);
