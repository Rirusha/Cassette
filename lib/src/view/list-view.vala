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

public sealed class Cassette.ListView : View {

    public Gtk.ListItemFactory? factory {
        get {
            return _list_view.factory;
        }
        set {
            _list_view.factory = value;
        }
    }

    public Gtk.ListItemFactory? header_factory {
        get {
            return _list_view.header_factory;
        }
        set {
            _list_view.header_factory = value;
        }
    }

    public bool show_separator {
        get {
            return _list_view.show_separators;
        }
        set {
            _list_view.show_separators = value;
        }
    }

    public bool enable_rubberband {
        get {
            return _list_view.enable_rubberband;
        }
        set {
            _list_view.enable_rubberband = value;
        }
    }

    public bool single_click_activate {
        get {
            return _list_view.single_click_activate;
        }
        set {
            _list_view.single_click_activate = value;
        }
    }

    public Gtk.ListTabBehavior tab_behavior {
        get {
            return _list_view.tab_behavior;
        }
        set {
            _list_view.tab_behavior = value;
        }
    }

    public override Gtk.SelectionModel? model {
        get {
            return _list_view.model;
        }
        set {
            if (_list_view.model != null) {
                _list_view.model.items_changed.disconnect (on_items_changed);
            }

            _list_view.model = value;

            if (_list_view.model != null) {
                _list_view.model.items_changed.connect_after (on_items_changed);
            }
            on_items_changed ();
        }
    }

    Gtk.ListView _list_view = new Gtk.ListView (null, null) {
        overflow = VISIBLE
    };

    protected override Gtk.Scrollable view_widget {
        get {
            return _list_view;
        }
    }

    public new signal void activate (uint position);

    construct {
        _list_view.activate.connect (on_list_view_activate);
        on_items_changed ();
    }

    public void scroll_to (uint pos, Gtk.ListScrollFlags flags, owned Gtk.ScrollInfo? scroll) {
        _list_view.scroll_to (pos, flags, scroll);
    }

    void on_list_view_activate (uint position) {
        activate (position);
    }

    void on_items_changed () {
        on_model_items_changed (model);
    }
}
