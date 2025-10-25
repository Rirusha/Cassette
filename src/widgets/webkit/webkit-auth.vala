/*
 * Copyright (C) 2025 Vladimir Romanov <rirusha@altlinux.org>
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
 * along with this program. If not, see
 * <https://www.gnu.org/licenses/gpl-3.0-standalone.html>.
 * 
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using WebKit;

[GtkTemplate (ui = "/space/rirusha/Cassette/ui/webkit/webkit-auth.ui")]
public sealed class Cassette.WebkitAuthDialog : Adw.Dialog {

    [GtkChild]
    unowned Adw.Bin webview_bin;
    [GtkChild]
    unowned Loadable loadable;

    WebView webview = new WebView ();

    public File cookies_file { get; construct; }

    public signal void success ();

    public WebkitAuthDialog (File cookies_file) {
        Object (cookies_file: cookies_file);
    }

    construct {
        webview_bin.child = webview;

        webview.load_changed.connect ((event) => {
            if (("https://music.yandex." in webview.uri) && event != LoadEvent.STARTED) {
                close ();
                success ();
            } else {
                debug ("Redirected to %s", webview.uri);
            }

            if (event == LoadEvent.FINISHED && loadable.is_loading) {
                loadable.is_loading = false;
            }
        });

        var network_session = webview.get_network_session ();
        var cookie_manager = network_session.get_cookie_manager ();

        cookie_manager.set_persistent_storage (cookies_file.peek_path (), CookiePersistentStorage.SQLITE);

        webview.load_uri (
            "https://oauth.yandex.ru/authorize?response_type=token&client_id=23cabbbdc6cd418abb4b39c32c41195d" // vala-lint=line-length
        );

        if (Config.IS_DEVEL) {
            add_css_class ("devel");
        }
    }

    [GtkCallback]
    void on_refresh () {
        loadable.is_loading = true;

        webview.reload ();
    }
}
