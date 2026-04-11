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

internal class Cassette.IndicatorBin : Gtk.Widget, Gtk.Buildable {

    internal class MaskBin : Adw.Bin {
        static construct {
            set_css_name ("mask");
        }
    }

    internal class IndicatorBin : Adw.Bin {
        static construct {
            set_css_name ("indicator");
        }
    }

	Gtk.Widget? _child = null;
	bool _needs_attention = false;
	uint _badge_number = 0;
	string _description = "";

	Adw.Bin mask;
	Adw.Bin indicator;
	Gtk.Label label;

	public Gtk.Widget? child {
		get {
			return _child;
		}
		set {
			if (_child == value) {
				return;
			}

			if (_child != null) {
				_child.unparent ();
			}

			_child = value;

			if (_child != null) {
				_child.set_parent (this);
			}
		}
	}

	public bool needs_attention {
		get {
			return _needs_attention;
		}
		set {
			if (_needs_attention == value) {
				return;
			}
			_needs_attention = value;
			if (_needs_attention) {
				add_css_class ("needs-attention");
			} else {
				remove_css_class ("needs-attention");
			}

			queue_draw ();
			update_description ();
		}
	}

	public uint badge_number {
		get {
			return _badge_number;
		}
		set {
			if (_badge_number == value) {
				return;
			}
			_badge_number = value;
			string label_text = get_badge_label (_badge_number);
			label.set_text (label_text);
			if (_badge_number > 0) {
				add_css_class ("badge");
			} else {
				remove_css_class ("badge");
			}
			label.set_visible (_badge_number > 0);
			queue_draw ();
			update_description ();
		}
	}

	public string description {
		get {
			return _description;
		}
	}

    static construct {
        set_css_name ("indicatorbin");
    }

	construct {
		mask = new MaskBin ();
		mask.set_can_target (false);
		mask.set_parent (this);

		indicator = new IndicatorBin ();
		indicator.set_can_target (false);
		indicator.set_parent (this);

		label = new Gtk.Label (null) {
            visible = false,
            css_classes = { "numeric" }
        };
        indicator.child = label;

		update_description ();
	}

	public override void dispose () {
		if (_child != null) {
			_child.unparent ();
			_child = null;
		}
		if (mask != null) {
			mask.unparent ();
			mask = null;
		}
		if (indicator != null) {
			indicator.unparent ();
			indicator = null;
		}
		label = null;
		base.dispose ();
	}

	public override void measure (Gtk.Orientation orientation, int for_size, out int minimum, out int natural, out int minimum_baseline, out int natural_baseline) {
		if (_child == null) {
			minimum = 0;
			natural = 0;
			minimum_baseline = -1;
			natural_baseline = -1;
			return;
		}
		_child.measure (orientation, for_size, out minimum, out natural, out minimum_baseline, out natural_baseline);
	}

	public override void size_allocate (int width, int height, int baseline) {
		if (_child != null) {
			_child.allocate (width, height, baseline, null);
		}

		Gtk.Requisition mask_size = Gtk.Requisition ();
		Gtk.Requisition indicator_size = Gtk.Requisition ();
		Gtk.Requisition dummy = Gtk.Requisition ();

		mask.get_preferred_size (out dummy, out mask_size);
		indicator.get_preferred_size (out dummy, out indicator_size);

		int max_w = mask_size.width;
		if (indicator_size.width > max_w) {
			max_w = indicator_size.width;
		}
		int max_h = mask_size.height;
		if (indicator_size.height > max_h) {
			max_h = indicator_size.height;
		}

		float x;
		if (max_w > width * 2) {
			x = (width - max_w) / 2.0f;
		} else if (get_direction () == Gtk.TextDirection.RTL) {
			x = -max_h / 2.0f;
		} else {
			x = width - max_w + max_h / 2.0f;
		}
		float y = -max_h / 2.0f;

		Gsk.Transform transform = new Gsk.Transform ().translate ({ x, y });
		mask.allocate (max_w, max_h, baseline, transform);
		indicator.allocate (max_w, max_h, baseline, transform);
	}

	public override void snapshot (Gtk.Snapshot snapshot) {
		if (_badge_number == 0 && !_needs_attention) {
			if (_child != null) {
                snapshot_child (_child, snapshot);
			}
			return;
		}

		if (_child != null) {
			snapshot.push_mask (Gsk.MaskMode.INVERTED_ALPHA);
            snapshot_child (mask, snapshot);
			snapshot.pop ();
            snapshot_child (_child, snapshot);
			snapshot.pop ();
		}

		snapshot_child (indicator, snapshot);
	}

	void update_description () {
		string? needs_attention_desc = null;
		string? badge_desc = null;

		if (_needs_attention) {
			needs_attention_desc = dpgettext2 ("libadwaita", "view switcher button badge", "Attention requested.");
		}

		if (_badge_number > 999) {
			badge_desc = dpgettext2 ("libadwaita", "view switcher button badge", "Has a badge: more than 999.");
		} else if (_badge_number > 0) {
			badge_desc = dpgettext2 ("libadwaita", "view switcher button badge", "Has a badge: %u.").printf (_badge_number);
		}

		if (needs_attention_desc != null && badge_desc != null) {
			_description = "%s %s".printf (badge_desc, needs_attention_desc);
		} else if (needs_attention_desc != null) {
			_description = needs_attention_desc;
		} else if (badge_desc != null) {
			_description = badge_desc;
		} else {
			_description = "";
		}

        notify_property ("description");
	}

	string get_badge_label (uint badge_number) {
		if (badge_number > 999) {
			return "999+";
		}
		if (badge_number == 0) {
			return "";
		}
		return "%u".printf (badge_number);
	}

	public void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
		if (child is Gtk.Widget) {
			this.child = (Gtk.Widget) child;
		}
	}
}
