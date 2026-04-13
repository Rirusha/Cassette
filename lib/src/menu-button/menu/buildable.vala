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

protected class Cassette.Buildable : Object, Gtk.Buildable {

    internal Buildable () {
        Object ();
    }

    public virtual void add_child (Gtk.Builder builder, GLib.Object child, string? type) {}

    public virtual void set_id (string id) {
        set_data_full ("gtk-builder-id", id.dup (), g_free);
    }

    public virtual unowned string get_id () {
        return get_data<string> ("gtk-builder-id");
    }

    public unowned Object get_internal_child (Gtk.Builder builder, string childname) {
        return null;
    }

    public void set_buildable_property (Gtk.Builder builder, string name, Value value) {
        set_property (name, value);
    }

    private void parser_finished (Gtk.Builder builder) {}

    private bool custom_tag_start (
        Gtk.Builder builder,
        Object? child,
        string tagname,
        out Gtk.BuildableParser parser,
        out void* data
    ) {
        parser = Gtk.BuildableParser ();
        data = null;
        return false;
    }

    private void custom_finished (Gtk.Builder builder, Object? child, string tagname, void* data) {}

    private void custom_tag_end (Gtk.Builder builder, Object? child, string tagname, void* data) {}
}
