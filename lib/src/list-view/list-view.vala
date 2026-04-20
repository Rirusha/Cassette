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

public sealed class Cassette.ListView : Gtk.Widget, Gtk.Scrollable {

    public Gtk.SelectionModel? model {
        get {
            return _list_view.model;
        }
        set {
            _list_view.model = value;
        }
    }

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

    public int clamp_maximum_size {
        get {
            return _clamp.maximum_size;
        }
        set {
            _clamp.maximum_size = value;
        }
    }

    public int clamp_start_end_margin {
        get {
            return _clamp.margin_start;
        }
        set {
            _clamp.margin_start = value;
            _clamp.margin_end = value;
        }
    }

    public Gtk.Adjustment hadjustment { get; set construct; }

    public Gtk.ScrollablePolicy hscroll_policy { get; set; }

    Gtk.Adjustment _vadjustment;
    public Gtk.Adjustment vadjustment {
        get {
            return _vadjustment;
        }
        set construct {
            if (_vadjustment != null) {
                _vadjustment.value_changed.disconnect (vvalue_changed);
            }

            _vadjustment = value;

            if (_vadjustment != null) {
                _vadjustment.value_changed.connect (vvalue_changed);
                update_vadjustment_from_lv ();
                vvalue_changed ();
            }
        }
    }

    int _spacing = 0;
    public int spacing {
        get {
            return _spacing;
        }
        set {
            _spacing = value;
            queue_resize ();
        }
    }

    public Gtk.ScrollablePolicy vscroll_policy { get; set; }

    Adw.ClampScrollable _clamp = new Adw.ClampScrollable () {
        maximum_size = int.MAX
    };

    Gtk.ListView _list_view = new Gtk.ListView (null, null) {
        overflow = VISIBLE
    };

    int _lower_border = 0;
    int _upper_border = 0;

    Gtk.Widget? _header;
    public Gtk.Widget? header {
        get {
            return _header;
        }
        set {
            if (_header != null) {
                _header.unparent ();
            }

            _header = value;

            if (_header != null) {
                _header.set_parent (this);
            }
            queue_allocate ();
        }
    }

    Gtk.Widget? _footer;
    public Gtk.Widget? footer {
        get {
            return _footer;
        }
        set {
            if (_footer != null) {
                _footer.unparent ();
            }

            _footer = value;

            if (_footer != null) {
                _footer.set_parent (this);
            }
            queue_allocate ();
        }
    }

    public new signal void activate (uint position);

    ~ListView () {
        _clamp.unparent ();
        _header?.unparent ();
        _footer?.unparent ();
    }

    static construct {
        set_css_name ("clistview");
    }

    construct {
        overflow = HIDDEN;
        _clamp.child = _list_view;
        _clamp.set_parent (this);

        _list_view.activate.connect (on_list_view);

        bind_property ("hadjustment", _list_view, "hadjustment", SYNC_CREATE | BIDIRECTIONAL);
        bind_property ("hscroll-policy", _list_view, "hscroll-policy", SYNC_CREATE | BIDIRECTIONAL);
        bind_property ("vscroll-policy", _list_view, "vscroll-policy", SYNC_CREATE | BIDIRECTIONAL);

        _list_view.vadjustment.changed.connect (update_vadjustment_from_lv);
        _list_view.vadjustment.notify["value"].connect (on_list_view_vvalue_changed);
        update_vadjustment_from_lv ();
    }

    void on_list_view (uint position) {
        activate (position);
    }

    public void scroll_to (uint pos, Gtk.ListScrollFlags flags, owned Gtk.ScrollInfo? scroll) {
        _list_view.scroll_to (pos, flags, scroll);
    }

    void on_list_view_vvalue_changed () {
        vadjustment.value = _list_view.vadjustment.value + _lower_border;
    }

    void update_vadjustment_from_lv () {
        if (vadjustment == null) {
            return;
        }

        bool at_end = vadjustment.value >=
            _list_view.vadjustment.upper - _upper_border - _list_view.vadjustment.page_size;
        bool should_set_upper = vadjustment.upper !=
            _list_view.vadjustment.upper + _lower_border + _upper_border;

        if (!at_end || should_set_upper) {
            vadjustment.page_increment = _list_view.vadjustment.page_increment;
            vadjustment.page_size = _list_view.vadjustment.page_size;
            vadjustment.step_increment = _list_view.vadjustment.step_increment;
            vadjustment.upper = _list_view.vadjustment.upper + _lower_border + _upper_border;
            vadjustment.lower = _list_view.vadjustment.lower;
        }

        queue_allocate ();
    }

    public bool get_border (out Gtk.Border border) {
        return false;
    }

    void vvalue_changed () {
        _list_view.vadjustment.freeze_notify ();
        if (vadjustment.value <= _lower_border) {
            if (model != null) {
                if (model.get_n_items () > 0) {
                    _list_view.scroll_to (0, NONE, null);
                }
            }
        } else if (vadjustment.value >= vadjustment.upper - _upper_border - vadjustment.page_size) {
            _list_view.vadjustment.value = double.MAX;
        } else {
            _list_view.vadjustment.value =
                (vadjustment.value - _lower_border).clamp (_list_view.vadjustment.lower, _list_view.vadjustment.upper);
        }
        _list_view.vadjustment.thaw_notify ();
        queue_allocate ();
    }

    protected override void measure (
        Gtk.Orientation orientation,
        int for_size,
        out int minimum,
        out int natural,
        out int min_baseline,
        out int nat_baseline
    ) {
        if (orientation == Gtk.Orientation.VERTICAL) {
            compute_size (
                for_size,
                out minimum,
                out natural,
                out min_baseline,
                out nat_baseline
            );
        } else {
            compute_opposite_size (
                for_size,
                out minimum,
                out natural,
                out min_baseline,
                out nat_baseline
            );
        }
    }

    protected override void size_allocate (
        int width,
        int height,
        int baseline
    ) {
        int n_children = 0;
        for (var child = get_first_child (); child != null; child = child.get_next_sibling ()) {
            if (child.should_layout ()) {
                n_children++;
            }
        }

        if (n_children == 0) {
            return;
        }

        int available = height;

        int list_view_y = 0;

        if (_header != null) {
            if (_header.should_layout ()) {
                int min_size;

                _header.measure (
                    Gtk.Orientation.VERTICAL,
                    -1,
                    out min_size,
                    null,
                    null,
                    null
                );

                min_size += spacing;

                if (_lower_border != min_size) {
                    _lower_border = min_size;
                    update_vadjustment_from_lv ();
                }

                var offset = (int) (vadjustment.value).clamp (0, min_size);

                var alloc = Gtk.Allocation () {
                    x = 0,
                    y = -offset,
                    width = width,
                    height = min_size - spacing
                };

                available -= min_size - offset;
                _header.allocate_size (alloc, baseline);
                list_view_y += min_size - offset;
            }
        }

        if (_footer != null) {
            if (_footer.should_layout ()) {
                int min_size;

                _footer.measure (
                    Gtk.Orientation.VERTICAL,
                    -1,
                    out min_size,
                    null,
                    null,
                    null
                );

                min_size += spacing;

                if (_upper_border != min_size) {
                    _upper_border = min_size;
                    update_vadjustment_from_lv ();
                }

                var offset = (int) (
                    vadjustment.upper - (vadjustment.value + vadjustment.page_size)
                ).clamp (0, min_size);

                var alloc = Gtk.Allocation () {
                    x = 0,
                    y = height - (min_size - offset) + spacing,
                    width = width,
                    height = min_size - spacing
                };

                available -= min_size - offset;
                _footer.allocate_size (alloc, baseline);
            }
        }

        if (_clamp.should_layout ()) {
            var alloc = Gtk.Allocation () {
                x = 0,
                y = list_view_y,
                width = width,
                height = available
            };
            _clamp.allocate_size (alloc, baseline);
        }
    }

    void compute_size (
        int for_size,
        out int minimum,
        out int natural,
        out int min_baseline,
        out int nat_baseline
    ) {
        int n = 0;
        int sum_min = 0, sum_nat = 0;

        if (_header != null) {
            if (_header.should_layout ()) {
                int cmin, cnat, cbmin, cbnat;

                _header.measure (
                    Gtk.Orientation.VERTICAL, for_size,
                    out cmin,
                    out cnat,
                    out cbmin,
                    out cbnat
                );

                sum_min += cmin;
                sum_nat += cnat;
                n++;
            }
        }

        if (_clamp.should_layout ()) {
            int cmin, cnat, cbmin, cbnat;

            _clamp.measure (
                Gtk.Orientation.VERTICAL, for_size,
                out cmin,
                out cnat,
                out cbmin,
                out cbnat
            );

            sum_min += cmin;
            sum_nat += cnat;
            n++;
        }

        if (_footer != null) {
            if (_footer.should_layout ()) {
                int cmin, cnat, cbmin, cbnat;

                _footer.measure (
                    Gtk.Orientation.VERTICAL, for_size,
                    out cmin,
                    out cnat,
                    out cbmin,
                    out cbnat
                );

                sum_min += cmin;
                sum_nat += cnat;
                n++;
            }
        }

        if (n > 0) {
            sum_min += (n - 1) * spacing;
            sum_nat += (n - 1) * spacing;
        }

        minimum = sum_min;
        natural = sum_nat;
        min_baseline = -1;
        nat_baseline = -1;
    }

    void compute_opposite_size (
        int for_size,
        out int minimum,
        out int natural,
        out int min_baseline,
        out int nat_baseline
    ) {
        int max_min = 0, max_nat = 0;

        if (_header != null) {
            if (_header.should_layout ()) {
                int cmin, cnat;

                _header.measure (
                    Gtk.Orientation.HORIZONTAL,
                    for_size,
                    out cmin,
                    out cnat,
                    null,
                    null
                );

                max_min = int.max (max_min, cmin);
                max_nat = int.max (max_nat, cnat);
            }
        }

        if (_clamp.should_layout ()) {

            int cmin, cnat;

            _clamp.measure (
                Gtk.Orientation.HORIZONTAL,
                for_size,
                out cmin,
                out cnat,
                null,
                null
            );

            max_min = int.max (max_min, cmin);
            max_nat = int.max (max_nat, cnat);
        }

        if (_footer != null) {
            if (_footer.should_layout ()) {
                int cmin, cnat;

                _footer.measure (
                    Gtk.Orientation.HORIZONTAL,
                    for_size,
                    out cmin,
                    out cnat,
                    null,
                    null
                );

                max_min = int.max (max_min, cmin);
                max_nat = int.max (max_nat, cnat);
            }
        }

        minimum = max_min;
        natural = max_nat;
        min_baseline = -1;
        nat_baseline = -1;
    }
}
