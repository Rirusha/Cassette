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


using Cassette.Client;

namespace Cassette {

    public class BeginDialog : Adw.Dialog {
        public BeginView begin_view { get; default = new BeginView (true); }

        construct {
            child = begin_view;

            presentation_mode = Adw.DialogPresentationMode.FLOATING;
            content_width = 600;
            content_height = 960;

            begin_view.online_complete.connect (force_close);
            begin_view.local_choosed.connect (force_close);

            can_close = false;
            close_attempt.connect (application.quit);
        }
    }
}
