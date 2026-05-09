#import <AppKit/AppKit.h>
#import <WebKit/WebKit.h>
#import <objc/runtime.h>
#import "macos-webkit-auth.h"

static const NSString *AUTH_REDIRECT_HOST = @"music.yandex.";

// Key for objc_setAssociatedObject — keeps delegate alive as long as the window lives
static const char kDelegateKey = 0;

typedef struct {
    char                 *token;
    CassetteTokenCallback callback;
    gpointer              userdata;
    GDestroyNotify        userdata_free;
    void                 *window;       // CFRetain'd NSWindow*
} IdleCallbackData;

static gboolean idle_fire_callback (gpointer user_data)
{
    IdleCallbackData *d = (IdleCallbackData *) user_data;

    // Call into GLib/GTK — we're inside the GLib event loop here
    d->callback (d->token, d->userdata);

    if (d->token) free (d->token);

    if (d->userdata_free && d->userdata)
        d->userdata_free (d->userdata);

    // Transfer window ownership to strong local, free d, then dismiss on AppKit side
    NSWindow * __strong win = CFBridgingRelease (d->window);

    g_free (d);

    dispatch_async (dispatch_get_main_queue (), ^{
        // Removing the association releases the delegate (ARC)
        objc_setAssociatedObject (win, &kDelegateKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [win orderOut:nil];
    });

    return G_SOURCE_REMOVE;
}

@interface CassetteAuthWindowDelegate : NSObject <WKNavigationDelegate, NSWindowDelegate>
@property (nonatomic, assign) CassetteTokenCallback callback;
@property (nonatomic, assign) gpointer userdata;
@property (nonatomic, assign) GDestroyNotify userdata_free;
@property (nonatomic, unsafe_unretained) NSWindow *window;
@property (nonatomic, assign) BOOL fired;
@end

@implementation CassetteAuthWindowDelegate

- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationAction:(WKNavigationAction *)action
    decisionHandler:(void (^)(WKNavigationActionPolicy))handler
{
    NSURL *url = action.request.URL;
    NSString *urlString = url.absoluteString;

    if ([urlString containsString:(NSString *)AUTH_REDIRECT_HOST] && url.fragment.length > 0) {
        NSString *token = [self extractToken:url.fragment];
        if (token && !self.fired) {
            self.fired = YES;
            [self scheduleCallback:token.UTF8String];
            handler(WKNavigationActionPolicyCancel);
            return;
        }
    }

    handler(WKNavigationActionPolicyAllow);
}

- (NSString *)extractToken:(NSString *)fragment
{
    NSURLComponents *components = [NSURLComponents new];
    components.query = fragment;
    for (NSURLQueryItem *item in components.queryItems) {
        if ([item.name isEqualToString:@"access_token"])
            return item.value;
    }
    return nil;
}

- (void)scheduleCallback:(const char *)token
{
    IdleCallbackData *d = g_new0 (IdleCallbackData, 1);
    d->token         = token ? strdup (token) : NULL;
    d->callback      = self.callback;
    d->userdata      = self.userdata;
    d->userdata_free = self.userdata_free;
    d->window        = (void *) CFBridgingRetain (self.window);

    g_idle_add (idle_fire_callback, d);
}

- (void)windowWillClose:(NSNotification *)notification
{
    if (!self.fired) {
        self.fired = YES;
        [self scheduleCallback:NULL];
    }
}

@end

void cassette_macos_auth_start(const char          *auth_url,
                                CassetteTokenCallback callback,
                                gpointer              userdata,
                                GDestroyNotify        userdata_free)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSRect frame = NSMakeRect(0, 0, 900, 680);
        NSWindow *window = [[NSWindow alloc]
            initWithContentRect:frame
            styleMask:NSWindowStyleMaskTitled
                       | NSWindowStyleMaskClosable
                       | NSWindowStyleMaskResizable
            backing:NSBackingStoreBuffered
            defer:NO];
        [window setTitle:@"Cassette — Sign in to Yandex"];
        [window center];

        WKWebViewConfiguration *config = [WKWebViewConfiguration new];
        WKWebView *webView = [[WKWebView alloc] initWithFrame:frame configuration:config];

        CassetteAuthWindowDelegate *delegate = [CassetteAuthWindowDelegate new];
        delegate.callback      = callback;
        delegate.userdata      = userdata;
        delegate.userdata_free = userdata_free;
        delegate.window        = window;
        delegate.fired         = NO;

        webView.navigationDelegate = delegate;
        window.delegate = delegate;

        // Window retains the delegate via associated object — no global array needed
        objc_setAssociatedObject(window, &kDelegateKey, delegate,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        NSURLRequest *request = [NSURLRequest requestWithURL:
            [NSURL URLWithString:[NSString stringWithUTF8String:auth_url]]];
        [webView loadRequest:request];

        [window setContentView:webView];
        [window makeKeyAndOrderFront:nil];
        [NSApp activateIgnoringOtherApps:YES];
    });
}
