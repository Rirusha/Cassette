/* Copyright 2023-2024 Vladimir Vaskov
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Cassette.PrimaryMenuButton : CustomMenuButton {

    construct {
        primary = true;
        icon_name = "open-menu-symbolic";
    }

    protected override string get_title_label () {
        return _("Primary menu");
    }

    protected override MenuItem[] get_popover_menu_items () {
        return {
            {_("Disliked tracks"), "win.show-disliked-tracks", 0},
            {_("Parse URL from clipboard"), "app.parse-url", 1},
            {_("Preferences"), "win.preferences", 2},
            {_("Keyboard Shortcuts"), "win.show-help-overlay", 2},
            {_("About Cassette"), "win.about", 2}
        };
    }

    protected override MenuItem[] get_dialog_menu_items () {
        return get_popover_menu_items ();
    }
}
