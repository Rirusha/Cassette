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


public class Cassette.PrimaryMenuButton : CustomMenuButton {

    construct {
        primary = true;
        title_label = _("Primary menu");
        icon_name = "open-menu-symbolic";
    }

    protected override MenuItem[] get_popover_menu_items () {
        return {
            {_("Disliked tracks"), "win.show-disliked-tracks", 0},
            {_("Parse URL from clipboard"), "app.parse-url", 0},
            {_("Preferences"), "win.preferences", 1},
            {_("Keyboard Shortcuts"), "win.show-help-overlay", 1},
            {_("About Cassette"), "win.about", 1}
        };
    }

    protected override MenuItem[] get_dialog_menu_items () {
        return get_popover_menu_items ();
    }
}
