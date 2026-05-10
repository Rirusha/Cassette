#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <glib.h>
#import "macos-now-playing.h"

static CassetteNowPlayingCmd     g_on_play;
static CassetteNowPlayingCmd     g_on_pause;
static CassetteNowPlayingCmd     g_on_play_pause;
static CassetteNowPlayingCmd     g_on_next;
static CassetteNowPlayingCmd     g_on_prev;
static CassetteNowPlayingSeekCmd g_on_seek;

// Generation counter: incremented each time a new track/update starts or clear() is called.
// Each async block captures the generation at the time it was enqueued — if the counter has
// advanced by the time the block runs, the block is stale and must not touch global state.
static uint64_t g_gen = 0;

// ── idle helpers ─────────────────────────────────────────────────────────────

static gboolean idle_cmd(gpointer data)
{
    CassetteNowPlayingCmd fn = (CassetteNowPlayingCmd)(uintptr_t)data;
    if (fn) fn();
    return G_SOURCE_REMOVE;
}

static void schedule_cmd(CassetteNowPlayingCmd fn)
{
    if (!fn) return;
    g_idle_add(idle_cmd, (gpointer)(uintptr_t)fn);
}

typedef struct { CassetteNowPlayingSeekCmd fn; double pos; } SeekData;

static gboolean idle_seek(gpointer data)
{
    SeekData *d = (SeekData *)data;
    if (d->fn) d->fn(d->pos);
    g_free(d);
    return G_SOURCE_REMOVE;
}

static void schedule_seek(double pos)
{
    if (!g_on_seek) return;
    SeekData *d = g_new(SeekData, 1);
    d->fn  = g_on_seek;
    d->pos = pos;
    g_idle_add(idle_seek, d);
}

// ── public API ────────────────────────────────────────────────────────────────

void cassette_now_playing_init(
    CassetteNowPlayingCmd     on_play,
    CassetteNowPlayingCmd     on_pause,
    CassetteNowPlayingCmd     on_play_pause,
    CassetteNowPlayingCmd     on_next,
    CassetteNowPlayingCmd     on_prev,
    CassetteNowPlayingSeekCmd on_seek)
{
    g_on_play       = on_play;
    g_on_pause      = on_pause;
    g_on_play_pause = on_play_pause;
    g_on_next       = on_next;
    g_on_prev       = on_prev;
    g_on_seek       = on_seek;

    dispatch_async(dispatch_get_main_queue(), ^{
        MPRemoteCommandCenter *cc = [MPRemoteCommandCenter sharedCommandCenter];

        [cc.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent __unused *e) {
            schedule_cmd(g_on_play);
            return MPRemoteCommandHandlerStatusSuccess;
        }];
        [cc.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent __unused *e) {
            schedule_cmd(g_on_pause);
            return MPRemoteCommandHandlerStatusSuccess;
        }];
        [cc.togglePlayPauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent __unused *e) {
            schedule_cmd(g_on_play_pause);
            return MPRemoteCommandHandlerStatusSuccess;
        }];
        [cc.nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent __unused *e) {
            schedule_cmd(g_on_next);
            return MPRemoteCommandHandlerStatusSuccess;
        }];
        [cc.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent __unused *e) {
            schedule_cmd(g_on_prev);
            return MPRemoteCommandHandlerStatusSuccess;
        }];

        [cc.changePlaybackPositionCommand setEnabled:YES];
        [cc.changePlaybackPositionCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *e) {
            MPChangePlaybackPositionCommandEvent *ev = (MPChangePlaybackPositionCommandEvent *)e;
            schedule_seek(ev.positionTime);
            return MPRemoteCommandHandlerStatusSuccess;
        }];
    });
}

void cassette_now_playing_update(
    const char *title,
    const char *artist,
    const char *album,
    double      duration_sec,
    double      elapsed_sec,
    gboolean    is_playing,
    const char *artwork_url)
{
    // Capture everything as value types before dispatching.
    NSString *nsTitle   = title       ? [NSString stringWithUTF8String:title]       : @"";
    NSString *nsArtist  = artist      ? [NSString stringWithUTF8String:artist]      : @"";
    NSString *nsAlbum   = album       ? [NSString stringWithUTF8String:album]       : @"";
    NSString *nsArtUrl  = artwork_url ? [NSString stringWithUTF8String:artwork_url] : nil;
    BOOL      playing   = is_playing;
    uint64_t  myGen     = ++g_gen;  // advance generation; block owns this slot

    dispatch_async(dispatch_get_main_queue(), ^{
        // If a newer update or clear() arrived, this block is stale — discard.
        if (myGen != g_gen) return;

        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        info[MPMediaItemPropertyTitle]                    = nsTitle;
        info[MPMediaItemPropertyArtist]                   = nsArtist;
        info[MPMediaItemPropertyAlbumTitle]               = nsAlbum;
        info[MPMediaItemPropertyPlaybackDuration]         = @(duration_sec);
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = @(elapsed_sec);
        info[MPNowPlayingInfoPropertyPlaybackRate]        = playing ? @(1.0) : @(0.0);
        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = info;

        // Fetch artwork asynchronously; deliver only if still the same generation.
        if (!nsArtUrl) return;
        NSURL *url = [NSURL URLWithString:nsArtUrl];
        if (!url) return;

        NSURLSessionDataTask *task =
            [[NSURLSession sharedSession]
                dataTaskWithURL:url
                completionHandler:^(NSData *data, NSURLResponse __unused *r, NSError *err) {
                    if (!data || err) return;
                    NSImage *img = [[NSImage alloc] initWithData:data];
                    if (!img) return;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // Only update artwork if this generation is still active.
                        if (myGen != g_gen) return;
                        NSDictionary *cur = [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo;
                        if (!cur) return;
                        NSMutableDictionary *updated = [cur mutableCopy];
                        MPMediaItemArtwork *art = [[MPMediaItemArtwork alloc]
                            initWithBoundsSize:img.size
                            requestHandler:^NSImage *(CGSize __unused s) { return img; }];
                        updated[MPMediaItemPropertyArtwork] = art;
                        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = updated;
                    });
                }];
        [task resume];
    });
}

void cassette_now_playing_update_state(double elapsed_sec, gboolean is_playing)
{
    BOOL playing = is_playing;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *cur = [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo;
        if (!cur) return;
        NSMutableDictionary *updated = [cur mutableCopy];
        updated[MPNowPlayingInfoPropertyElapsedPlaybackTime] = @(elapsed_sec);
        updated[MPNowPlayingInfoPropertyPlaybackRate]        = playing ? @(1.0) : @(0.0);
        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = updated;
    });
}

void cassette_now_playing_clear(void)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        g_gen++;  // invalidate all pending update blocks
        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nil;
    });
}
