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
    [GtkChild]
    unowned Gtk.StringList string_list;

    public Window (CassetteDemo.Application app) {
        Object (application: app);
    }

    construct {
        on_visible_child_chandes ();

        if (Config.NIGHTLY) {
            add_css_class ("devel");
        }

        var grp = new SimpleActionGroup ();
        var test_action = new SimpleAction ("test-action", VariantType.STRING);
        test_action.activate.connect (on_test_action_activate);
        grp.add_action (test_action);
        insert_action_group ("test", grp);
    }

    [GtkCallback]
    void remove_first_row () {
        if (string_list.get_n_items () > 0) {
            string_list.remove (0);
        }
    }

    [GtkCallback]
    void add_row () {
        string_list.append (Uuid.string_random () + Uuid.string_random () + Uuid.string_random ());
    }

    void on_test_action_activate (Variant? parameter) {
        message (parameter.get_string ());
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
