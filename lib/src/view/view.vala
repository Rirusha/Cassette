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

/**
 * Children must have fixed size. Otherwise kaboom
 */
public abstract class Cassette.View : Gtk.Widget, Gtk.Scrollable {

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
                scrollable_child.vadjustment.changed.disconnect (update_vadjustment_data);
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

                scrollable_child.vadjustment.changed.connect (update_vadjustment_data);
                update_vadjustment_data ();
            }
            queue_allocate ();
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
                _vadjustment.value_changed.disconnect (vvalue_changed_with_allocate);
            }

            _vadjustment = value;

            if (_vadjustment != null) {
                _vadjustment.value_changed.connect_after (vvalue_changed_with_allocate);
                update_vadjustment_data ();
                vvalue_changed_with_allocate ();
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

    protected abstract Gtk.Scrollable view_widget { get; }

    Gtk.Viewport placeholder_viewport = new Gtk.Viewport (null, null);

    int _lower_vadjustment_border = 0;
    int _upper_vadjustment_border = 0;

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

    public abstract Gtk.SelectionModel? model { get; set; }

    ~View () {
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

        bind_property ("css-classes", view_widget, "css-classes", SYNC_CREATE);
    }

    protected void on_model_items_changed (ListModel? model) {
        bool show_placeholder = false;

        if (model == null) {
            show_placeholder = true;
        } else {
            if (model.get_n_items () == 0 && placeholder_viewport.child != null) {
                show_placeholder = true;
            }
        }

        if (show_placeholder) {
            if (scrollable_child == placeholder_viewport) {
                return;
            }

            scrollable_child = placeholder_viewport;
        } else {
            if (scrollable_child == view_widget) {
                return;
            }

            scrollable_child = view_widget;
        }
        queue_allocate ();
    }

    void update_vadjustment_data () {
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

    public abstract void scroll_to (uint pos, Gtk.ListScrollFlags flags, owned Gtk.ScrollInfo? scroll);

    void vvalue_changed () {
        if (vadjustment.value < _lower_vadjustment_border) {
            if (model != null) {
                if (model.get_n_items () > 0) {
                    if (scrollable_child == placeholder_viewport) {
                        scrollable_child.vadjustment.value = double.MIN;
                    } else {
                        scroll_to (
                            0,
                            NONE,
                            null
                        );
                    }
                }
            }

        } else if (vadjustment.value > vadjustment.upper - _upper_vadjustment_border - vadjustment.page_size) {
            if (model != null) {
                if (model.get_n_items () > 0) {
                    if (scrollable_child == placeholder_viewport) {
                        scrollable_child.vadjustment.value = double.MAX;
                    } else {
                        scroll_to (
                            model.get_n_items () - 1,
                            NONE,
                            null
                        );
                    }
                }
            }

        } else {
            scrollable_child.vadjustment.value = vadjustment.value - _lower_vadjustment_border;
        }
    }

    void vvalue_changed_with_allocate () {
        vvalue_changed ();
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
        bool layout_header = false;
        bool layout_footer = false;
        bool layout_clamp = false;

        int header_natural_size = 0;
        int footer_natural_size = 0;
        int clamp_natural_size = 0;

        int header_y = 0;
        int header_h = 0;

        int footer_y = 0;
        int footer_h = 0;

        int clamp_y = 0;
        int clamp_h = 0;

        if (_header != null) {
            if (_header.should_layout ()) {
                layout_header = true;

                _header.measure (
                    Gtk.Orientation.VERTICAL,
                    width,
                    null,
                    out header_natural_size,
                    null,
                    null
                );
            }
        }
        if (_footer != null) {
            if (_footer.should_layout ()) {
                layout_footer = true;

                _footer.measure (
                    Gtk.Orientation.VERTICAL,
                    width,
                    null,
                    out footer_natural_size,
                    null,
                    null
                );
            }
        }
        if (_clamp.should_layout ()) {
            layout_clamp = true;

            _clamp.measure (
                Gtk.Orientation.VERTICAL,
                width,
                null,
                out clamp_natural_size,
                null,
                null
            );
        }

        var header_natural_size_spaced = header_natural_size + spacing;
        if (_lower_vadjustment_border != header_natural_size_spaced) {
            _lower_vadjustment_border = header_natural_size_spaced;
            vvalue_changed ();
        }

        var footer_natural_size_spaced = footer_natural_size + spacing;
        if (_upper_vadjustment_border != footer_natural_size_spaced) {
            _upper_vadjustment_border = footer_natural_size_spaced;
            vvalue_changed ();
        }

        var new_upper = double.max (
            height,
            header_natural_size_spaced + footer_natural_size_spaced + clamp_natural_size
        );

        //  All fits, so we don't need to do any calculation, just allocate
        if (header_natural_size_spaced + clamp_natural_size + footer_natural_size_spaced <= height) {
            vadjustment.value = 0;
            if (layout_header) {
                header_h = header_natural_size;
                header_y = 0;
            }
            if (layout_clamp) {
                clamp_h = clamp_natural_size;
                clamp_y = header_natural_size_spaced;
            }
            if (layout_footer) {
                footer_h = footer_natural_size;
                footer_y = clamp_y + clamp_natural_size + spacing;
            }

        } else {
            int header_visible_part = 0;
            int header_offset = 0;
            int footer_visible_part = 0;
            int footer_offset = 0;

            if (layout_header) {
                header_offset = (int) vadjustment.value.clamp (0, header_natural_size_spaced);

                //  Header offseted but there is place on bottom
                if (header_natural_size_spaced - header_offset +
                        clamp_natural_size + footer_natural_size_spaced <= height) {
                    header_offset = (
                        (height - (header_natural_size_spaced + clamp_natural_size + footer_natural_size_spaced)
                    ).clamp (-header_natural_size_spaced, 0)).abs ();

                    if (header_offset != header_natural_size_spaced) {
                        vadjustment.value = header_offset;
                    }
                }

                header_visible_part = header_natural_size_spaced - header_offset;

                header_y = -header_offset;
                header_h = header_natural_size - spacing;
            }

            if (layout_footer) {
                footer_offset = (int) (
                    new_upper - (vadjustment.value + height)
                ).clamp (0, footer_natural_size_spaced);

                footer_visible_part = footer_natural_size_spaced - footer_offset;

                if (footer_offset == 0) {
                    vadjustment.value = new_upper - height;
                }
            }

            var available = height - (header_visible_part + footer_visible_part);

            clamp_y += header_visible_part;
            clamp_h = int.min (available, clamp_natural_size).clamp (0, clamp_natural_size);

            if (layout_footer) {
                footer_y = clamp_y + clamp_h + spacing;
                footer_h = footer_natural_size;
            }
        }

        Gtk.Allocation alloc;
        if (layout_header) {
            alloc = Gtk.Allocation () {
                x = 0,
                y = header_y,
                width = width,
                height = header_h
            };

            _header.allocate_size (alloc, baseline);
        }
        if (layout_clamp) {
            alloc = Gtk.Allocation () {
                x = 0,
                y = clamp_y,
                width = width,
                height = clamp_h
            };

            _clamp.allocate_size (alloc, baseline);
        }
        if (layout_footer) {
            alloc = Gtk.Allocation () {
                x = 0,
                y = footer_y,
                width = width,
                height = footer_h
            };

            _footer.allocate_size (alloc, baseline);
        }

        //  Set page_size to height, so scroll alwys has normal scroll step
        vadjustment.page_size = height;

        //  If all_fits, we should set upper to height, so bottom ScrolledWindow
        //  effect doesn't show up
        vadjustment.upper = new_upper;

        //  Correct scrolled child value
        vadjustment.value_changed ();
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
                    Gtk.Orientation.VERTICAL,
                    for_size,
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
                Gtk.Orientation.VERTICAL,
                for_size,
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
                    Gtk.Orientation.VERTICAL,
                    for_size,
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
