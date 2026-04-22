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

public sealed class Cassette.GridView : View {

    public Gtk.ListItemFactory? factory {
        get {
            return _grid_view.factory;
        }
        set {
            _grid_view.factory = value;
        }
    }

    public bool single_click_activate {
        get {
            return _grid_view.single_click_activate;
        }
        set {
            _grid_view.single_click_activate = value;
        }
    }

    public Gtk.ListTabBehavior tab_behavior {
        get {
            return _grid_view.tab_behavior;
        }
        set {
            _grid_view.tab_behavior = value;
        }
    }

    public bool enable_rubberband {
        get {
            return _grid_view.enable_rubberband;
        }
        set {
            _grid_view.enable_rubberband = value;
        }
    }

    public uint max_columns {
        get {
            return _grid_view.max_columns;
        }
        set {
            _grid_view.max_columns = value;
        }
    }

    public uint min_columns {
        get {
            return _grid_view.min_columns;
        }
        set {
            _grid_view.min_columns = value;
        }
    }

    public override Gtk.SelectionModel? model {
        get {
            return _grid_view.model;
        }
        set {
            if (_grid_view.model != null) {
                _grid_view.model.items_changed.disconnect (on_items_changed);
            }

            _grid_view.model = value;

            if (_grid_view.model != null) {
                _grid_view.model.items_changed.connect_after (on_items_changed);
            }
            on_items_changed ();
        }
    }

    Gtk.GridView _grid_view = new Gtk.GridView (null, null) {
        overflow = VISIBLE
    };

    protected override Gtk.Scrollable view_widget {
        get {
            return _grid_view;
        }
    }

    public new signal void activate (uint position);

    construct {
        _grid_view.activate.connect (on_list_view_activate);
        on_items_changed ();
    }

    public void scroll_to (uint pos, Gtk.ListScrollFlags flags, owned Gtk.ScrollInfo? scroll) {
        _grid_view.scroll_to (pos, flags, scroll);
    }

    void on_list_view_activate (uint position) {
        activate (position);
    }

    void on_items_changed () {
        on_model_items_changed (model);
    }
}
