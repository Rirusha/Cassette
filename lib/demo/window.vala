/*
 * Copyright (C) 2026 Vladimir Romanov <rirusha@altlinux.org>
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

[GtkTemplate (ui = "/space/rirusha/CassetteDemo/ui/window.ui")]
public sealed class CassetteDemo.Window : Adw.ApplicationWindow {

    [GtkChild]
    unowned Adw.NavigationSplitView split_view;
    [GtkChild]
    unowned Adw.NavigationPage content_nav_page;
    [GtkChild]
    unowned Adw.ViewStack stack;

    public Window (CassetteDemo.Application app) {
        Object (application: app);
    }

    construct {
        on_visible_child_chandes ();

        if (Config.IS_DEVEL) {
            add_css_class ("devel");
        }
    }

    [GtkCallback]
    void on_visible_child_chandes () {
        content_nav_page.title = stack.get_page (stack.visible_child).title ?? "";
    }

    [GtkCallback]
    void on_viewswitchersidebar_activated () {
        split_view.show_content = true;
    }
}
