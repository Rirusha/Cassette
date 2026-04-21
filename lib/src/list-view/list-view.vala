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

    Binding hadjustment_binding;
    Binding hscroll_policy_binding;
    Binding vscroll_policy_binding;

    Gtk.Scrollable scrollable_child {
        get {
            return (Gtk.Scrollable) _clamp.child;
        }
        set {
            if (scrollable_child != null) {
                hadjustment_binding.unbind ();
                hscroll_policy_binding.unbind ();
                vscroll_policy_binding.unbind ();
                scrollable_child.vadjustment.changed.disconnect (on_scrollable_child_changed);
                scrollable_child.vadjustment.notify["value"].disconnect (on_scrollable_child_vvalue_changed);
            }

            assert (value is Gtk.Widget);
            _clamp.child = (Gtk.Widget) value;

            if (scrollable_child != null) {
                hadjustment_binding = bind_property (
                    "hadjustment",
                    scrollable_child,
                    "hadjustment",
                    SYNC_CREATE | BIDIRECTIONAL
                );
                hscroll_policy_binding = bind_property (
                    "hscroll-policy",
                    scrollable_child,
                    "hscroll-policy",
                    SYNC_CREATE | BIDIRECTIONAL
                );
                vscroll_policy_binding = bind_property (
                    "vscroll-policy",
                    scrollable_child,
                    "vscroll-policy",
                    SYNC_CREATE | BIDIRECTIONAL
                );

                scrollable_child.vadjustment.changed.connect (on_scrollable_child_changed);
                scrollable_child.vadjustment.notify["value"].connect (on_scrollable_child_vvalue_changed);
                on_scrollable_child_changed ();
            }
            queue_allocate ();
        }
    }

    public Gtk.SelectionModel? model {
        get {
            return _list_view.model;
        }
        set {
            if (_list_view.model != null) {
                _list_view.model.items_changed.disconnect (on_items_changed);
            }

            _list_view.model = value;

            if (_list_view.model != null) {
                _list_view.model.items_changed.connect (on_items_changed);
            }
            on_items_changed ();
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

    public int clamp_top_margin {
        get {
            return _clamp.margin_top;
        }
        set {
            _clamp.margin_top = value;
        }
    }

    public int clamp_bottom_margin {
        get {
            return _clamp.margin_bottom;
        }
        set {
            _clamp.margin_bottom = value;
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
                on_scrollable_child_changed ();
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

    Gtk.Viewport placeholder_viewport = new Gtk.Viewport (null, null);

    int _lower_border = 0;
    int _upper_border = 0;

    public Gtk.Widget? placeholder {
        get {
            return placeholder_viewport.child;
        }
        set {
            placeholder_viewport.child = value;
            queue_allocate ();
        }
    }

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
        _clamp.set_parent (this);

        _list_view.activate.connect (on_list_view_activate);

        on_items_changed ();
    }

    void on_items_changed () {
        bool show_placeholder = false;

        if (_list_view.model == null) {
            show_placeholder = true;
        } else {
            if (_list_view.model.get_n_items () == 0 && placeholder_viewport.child != null) {
                show_placeholder = true;
            }
        }

        if (show_placeholder) {
            if (scrollable_child == placeholder_viewport) {
                return;
            }

            scrollable_child = placeholder_viewport;
        } else {
            if (scrollable_child == _list_view) {
                return;
            }

            scrollable_child = _list_view;
        }
    }

    void on_list_view_activate (uint position) {
        activate (position);
    }

    public void scroll_to (uint pos, Gtk.ListScrollFlags flags, owned Gtk.ScrollInfo? scroll) {
        _list_view.scroll_to (pos, flags, scroll);
    }

    void on_scrollable_child_vvalue_changed () {
        vadjustment.value = scrollable_child.vadjustment.value + _lower_border;
    }

    void on_scrollable_child_changed () {
        if (vadjustment == null) {
            return;
        }

        vadjustment.lower = scrollable_child.vadjustment.lower;
        vadjustment.page_increment = scrollable_child.vadjustment.page_increment;
        vadjustment.step_increment = scrollable_child.vadjustment.step_increment;

        queue_allocate ();
    }

    public bool get_border (out Gtk.Border border) {
        return false;
    }

    void vvalue_changed () {
        scrollable_child.vadjustment.freeze_notify ();
        if (vadjustment.value <= _lower_border) {
            if (model != null) {
                if (model.get_n_items () > 0) {
                    if (scrollable_child is Gtk.ListView) {
                        ((Gtk.ListView) scrollable_child).scroll_to (0, NONE, null);
                    } else {
                        scrollable_child.vadjustment.value = double.MIN;
                    }
                }
            }

        } else if (vadjustment.value >= vadjustment.upper - _upper_border - vadjustment.page_size) {
            scrollable_child.vadjustment.value = double.MAX;

        } else {
            scrollable_child.vadjustment.value =
                (vadjustment.value - _lower_border).clamp (
                    scrollable_child.vadjustment.lower,
                    scrollable_child.vadjustment.upper
                );
        }
        scrollable_child.vadjustment.thaw_notify ();
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

        bool header_layout = false;
        bool footer_layout = false;

        int header_nat_size = 0;
        int footer_nat_size = 0;
        int clamp_nat_size;

        if (_header != null) {
            if (_header.should_layout ()) {
                header_layout = true;
                _header.measure (
                    Gtk.Orientation.VERTICAL,
                    -1,
                    null,
                    out header_nat_size,
                    null,
                    null
                );
            }
        }
        var header_size_spaced = header_nat_size + spacing;
        if (_lower_border != header_size_spaced) {
            _lower_border = header_size_spaced;
            on_scrollable_child_changed ();
        }

        if (_footer != null) {
            if (_footer.should_layout ()) {
                footer_layout = true;
                _footer.measure (
                    Gtk.Orientation.VERTICAL,
                    -1,
                    null,
                    out footer_nat_size,
                    null,
                    null
                );
            }
        }
        var footer_size_spaced = footer_nat_size + spacing;
        if (_upper_border != footer_size_spaced) {
            _upper_border = footer_size_spaced;
            on_scrollable_child_changed ();
        }

        _clamp.measure (
            Gtk.Orientation.VERTICAL,
            -1,
            null,
            out clamp_nat_size,
            null,
            null
        );

        int available = height;

        int list_view_y = 0;
        bool list_view_fit = list_view_y + clamp_nat_size < height;

        if (header_layout) {
            var offset = (int) (vadjustment.value)
                .clamp (0, header_size_spaced);

            if (header_size_spaced + clamp_nat_size + footer_size_spaced < height) {
                offset = 0;
                vadjustment.value = 0;
            } else if (header_size_spaced - offset + clamp_nat_size + footer_size_spaced < height) {
                offset = ((height - (header_size_spaced + clamp_nat_size + footer_size_spaced))
                    .clamp (-header_size_spaced, 0))
                    .abs ();
            }

            var alloc = Gtk.Allocation () {
                x = 0,
                y = -offset,
                width = width,
                height = header_size_spaced - spacing
            };

            available -= header_size_spaced - offset;
            _header.allocate_size (alloc, baseline);
            list_view_y += header_size_spaced - offset;
        }

        int list_view_size = 0;

        if (footer_layout) {
            var offset = (int) (
                vadjustment.upper - (vadjustment.value + vadjustment.page_size)
            ).clamp (0, footer_size_spaced);

            available -= footer_size_spaced - offset;

            if (model.get_n_items () > 0 || (model.get_n_items () == 0 && placeholder != null)) {
                list_view_size = (!list_view_fit ? available : clamp_nat_size).clamp (0, int.MAX);
            }

            int y = list_view_y + list_view_size + spacing;

            var alloc = Gtk.Allocation () {
                x = 0,
                y = y,
                width = width,
                height = footer_size_spaced - spacing
            };

            _footer.allocate_size (alloc, baseline);
        }

        if (_clamp.should_layout ()) {
            if (!footer_layout) {
                if (model.get_n_items () > 0 || (model.get_n_items () == 0 && placeholder != null)) {
                    list_view_size = (!list_view_fit ? available : clamp_nat_size).clamp (0, int.MAX);
                }
            }
            var alloc = Gtk.Allocation () {
                x = 0,
                y = list_view_y,
                width = width,
                height = list_view_size
            };
            _clamp.allocate_size (alloc, baseline);
        }

        vadjustment.page_size = height;
        vadjustment.upper = double.max (
            height,
            _lower_border + _upper_border + scrollable_child.vadjustment.upper
        );
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
