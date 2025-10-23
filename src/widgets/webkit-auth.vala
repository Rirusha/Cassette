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

public sealed class Cassette.WebkitAuthDialog : Adw.Dialog {

    WebView webview = new WebView ();

    Gtk.Stack loading_stack = new Gtk.Stack ();

    public File cookies_file { get; construct; }

    public signal void success ();

    public bool loading {
        get {
            return loading_stack.visible_child_name == "loading";
        }
        set {
            loading_stack.visible_child_name = value ? "loading" : "main";
        }
    }

    public WebkitAuthDialog (File cookies_file) {
        Object (cookies_file: cookies_file);
    }

    construct {
        content_width = 600;
        content_height = 800;

        loading_stack.add_named (new Adw.Spinner (), "loading");
        loading_stack.add_named (webview, "main");

        var toolbarview = new Adw.ToolbarView ();
        child = toolbarview;

        toolbarview.content = loading_stack;

        var headerbar = new Adw.HeaderBar ();
        toolbarview.add_top_bar (headerbar);

        var refresh_button = new Gtk.Button.from_icon_name ("view-refresh-symbolic");
        refresh_button.clicked.connect (on_refresh);
        bind_property ("loading", refresh_button, "sensitive");
        headerbar.pack_start (refresh_button);

        loading = true;

        webview.load_changed.connect ((event) => {
            if (("https://music.yandex." in webview.uri) && event != LoadEvent.STARTED) {
                close ();
                success ();
            } else {
                warning ("Redirected to %s", webview.uri);
            }

            if (event == LoadEvent.FINISHED && loading) {
                loading = false;
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

    void on_refresh () {
        loading = true;

        webview.reload ();
    }
}
