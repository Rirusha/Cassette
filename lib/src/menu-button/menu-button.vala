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

public sealed class Cassette.MenuButton : Gtk.ToggleButton {

    public enum Mode {
        POPOVER,
        SHEET;
    }

    Menu _menu_model;
    public Menu menu_model {
        get {
            return _menu_model;
        }
        set {
            _menu_model = value;

            if (popover_menu_model == null) {
                popover.menu_model = _menu_model;
            }
            if (sheet_menu_model == null) {
                sheet.menu_model = _menu_model;
            }
        }
    }

    Menu _popover_menu_model;
    public Menu popover_menu_model {
        get {
            return _popover_menu_model;
        }
        set {
            _popover_menu_model = value;

            if (_popover_menu_model == null) {
                if (menu_model != null) {
                    popover_menu_model = menu_model;
                }
            } else {
                popover.menu_model = _popover_menu_model;
            }
        }
    }

    Menu _sheet_menu_model;
    public Menu sheet_menu_model {
        get {
            return _sheet_menu_model;
        }
        set {
            _sheet_menu_model = value;

            if (_sheet_menu_model == null) {
                if (menu_model != null) {
                    sheet_menu_model = menu_model;
                }
            } else {
                sheet.menu_model = _sheet_menu_model;
            }
        }
    }

    Mode _mode = POPOVER;
    Mode mode {
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
                    if (active) {
                        sheet.close ();
                    }
                    break;
                case SHEET:
                    if (active) {
                        popover.popdown ();
                    }
                    break;
            }
        }
    }

    public string sheet_title { get; set; }

    Gtk.PopoverMenu popover;
    SheetMenu sheet;

    Gdk.Surface wsurface;

    ~MenuButton () {
        popover.unparent ();
    }

    construct {
        popover = new Gtk.PopoverMenu.from_model (null);
        popover.set_parent (this);
        popover.closed.connect (on_close);

        sheet = new SheetMenu.from_model (this, null);
        bind_property ("sheet-title", sheet, "title", BindingFlags.SYNC_CREATE);
        sheet.closed.connect (on_close);

        toggled.connect (on_toggled);
    }

    public bool add_child (Gtk.Widget child, string id, Mode mode) {
        switch (mode) {
            case POPOVER:
                return popover.add_child (child, id);
            case SHEET:
                return sheet.add_child (child, id);
        }
        return false;
    }

    public bool remove_child (Gtk.Widget child, Mode mode) {
        switch (mode) {
            case POPOVER:
                return popover.remove_child (child);
            case SHEET:
                return sheet.remove_child (child);
        }
        return false;
    }

    void on_close () {
        active = false;
    }

    void on_toggled () {
        if (active) {
            show_menu ();
        } else {
            hide_menu ();
        }
    }

    public void show_menu () {
        switch (mode) {
            case POPOVER:
                popover.popup ();
                break;
            case SHEET:
                sheet.present (this);
                break;
        }
    }

    public void hide_menu () {
        switch (mode) {
            case POPOVER:
                popover.popdown ();
                break;
            case SHEET:
                sheet.close ();
                break;
        }
    }

    protected override void size_allocate (int width, int height, int baseline) {
        base.size_allocate (width, height, baseline);

        popover.present ();
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
        mode = width <= 450 || height <= 360 ? Mode.SHEET : Mode.POPOVER;
    }
}
