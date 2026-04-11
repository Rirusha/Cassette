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

[GtkTemplate (ui = "/space/rirusha/Cassette/Lib/ui/combo-row.ui")]
public sealed class Cassette.ComboRow : Adw.ComboRow {

    [GtkChild]
    unowned Adw.Dialog sheet_dialog;
    [GtkChild]
    unowned Gtk.ListView sheet_list;
    [GtkChild]
    unowned Gtk.SignalListItemFactory default_factory;
    [GtkChild]
    unowned Gtk.SearchEntry search_entry;

    Gtk.FilterListModel? _filter_model;
    Gtk.NoSelection? _sheet_list_selection;

    PresentationMode _mode = POPOVER;
    PresentationMode mode {
        get {
            return _mode;
        }
        set {
            if (_mode == value) {
                return;
            }

            _mode = value;
            switch (_mode) {
                case POPOVER:
                    if (sheet_dialog.root != null) {
                        sheet_dialog.close ();
                    }
                    break;
                default:
                    break;
            }
        }
    }

    public new ListModel? model {
        get {
            return base.model;
        }
        set {
            base.model = value;

            if (model == null) {

            } else {
                _filter_model = new Gtk.FilterListModel (value, null);
                update_filter ();

                _sheet_list_selection = new Gtk.NoSelection (_filter_model);
                sheet_list.model = _sheet_list_selection;
                update_list_factories ();
            }
        }
    }

    bool _factory_set = false;
    public new Gtk.ListItemFactory factory {
        get {
            return base.factory;
        }
        set {
            _factory_set = true;
            base.factory = value;
        }
    }

    Gtk.ListItemFactory? _sheet_factory;
    public Gtk.ListItemFactory? sheet_factory {
        get {
            return _sheet_factory;
        }
        set {
            _sheet_factory = value;
            update_list_factories ();
        }
    }

    Gdk.Surface wsurface;

    construct {
        update_list_factories ();
    }

    public override void activate () {
        if (mode == POPOVER) {
            base.activate ();
        } else {
            sheet_dialog.present (this);
        }
    }

    [GtkCallback]
    void update_filter () {
        if (_filter_model == null) {
            return;
        }

        Gtk.Filter filter;
        if (expression != null) {
            filter = new Gtk.StringFilter (expression);
            ((Gtk.StringFilter) filter).match_mode = search_match_mode;
        } else {
            filter = new Gtk.EveryFilter ();
        }
        _filter_model.filter = filter;
    }

    protected override void realize () {
        base.realize ();

        if (wsurface != null) {
            wsurface.notify["width"].disconnect (root_size_changed);
            wsurface.notify["height"].disconnect (root_size_changed);
        }

        wsurface = root.get_surface ();

        wsurface.notify["width"].connect (root_size_changed);
        wsurface.notify["height"].connect (root_size_changed);
        update_mode (wsurface.width, wsurface.height);
    }

    void root_size_changed (Object object, ParamSpec param) {
        var surf = ((Gdk.Surface) object);
        update_mode (surf.get_width (), surf.get_height ());
    }

    inline void update_mode (int width, int height) {
        mode = width <= 450 || height <= 360 ? PresentationMode.SHEET : PresentationMode.POPOVER;
    }

    [GtkCallback]
    void on_sheet_list_activate (uint position) {
        selected = position;
        sheet_dialog.close ();
    }

    [GtkCallback]
    void update_list_factories () {
        if (_factory_set) {
            sheet_list.factory = sheet_factory ?? factory ?? default_factory;
        } else {
            sheet_list.factory = sheet_factory ?? default_factory;
        }
        sheet_list.header_factory = header_factory;
    }

    [GtkCallback]
    void search_changed_cb () {
        var filter = _filter_model.filter;
        if (filter is Gtk.StringFilter) {
            ((Gtk.StringFilter) filter).search = search_entry.text;
        }
    }

    [GtkCallback]
    void search_stop_cb () {
        var filter = _filter_model.filter;
        if (filter is Gtk.StringFilter) {
            if (((Gtk.StringFilter) filter).search != null) {
                ((Gtk.StringFilter) filter).search = null;
            } else {
                sheet_dialog.close ();
            }
        }
    }

    [GtkCallback]
    void on_default_factory_setup (Gtk.SignalListItemFactory factory, Object? obj) {
        var list_item = (Gtk.ListItem) obj;
        var row = new DefaultRowContent ();
        list_item.child = row;
    }

    [GtkCallback]
    void on_default_factory_bind (Gtk.SignalListItemFactory factory, Object? obj) {
        var list_item = (Gtk.ListItem) obj;
        var row = (DefaultRowContent) list_item.child;
        var item = list_item.item;

        string? repr = get_item_representation (item);
        if (repr != null) {
            row.string = repr;
        } else {
            warning ("Either factory or expression must be set");
            return;
        }

        notify["selected-item"].connect (() => {
            row.selected = item == selected_item;
        });
        row.selected = item == selected_item;
    }

    string? get_item_representation (GLib.Object item) {
        if (expression != null) {
            GLib.Value val = GLib.Value (typeof (string));
            if (expression.evaluate (item, ref val)) {
                return val.get_string ();
            }
        }
        if (item is Gtk.StringObject) {
            return ((Gtk.StringObject) item).string;
        }
        return null;
    }
}
