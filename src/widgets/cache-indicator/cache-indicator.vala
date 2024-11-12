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
    [GtkTemplate (ui = "/space/rirusha/Cassette/ui/cache-indicator.ui")]
    public class CacheIndicator : Adw.Bin {
        [GtkChild]
        unowned Gtk.Popover jobs_popover;
        [GtkChild]
        unowned Gtk.Box jobs_box;
        [GtkChild]
        unowned Gtk.Revealer indicator_revealer;
        [GtkChild]
        unowned Gtk.DrawingArea jobs_icon;

        uint timeout_id = 0;

        public CacheIndicator () {
            Object ();
        }

        construct {
            jobs_popover.notify["visible"].connect (() => {
                while (jobs_box.get_last_child () != null) {
                    jobs_box.remove (jobs_box.get_last_child ());
                }

                if (jobs_popover.visible) {
                    fill_box ();
                }
            });

            indicator_revealer.notify["reveal-child"].connect (() => {
                if (indicator_revealer.reveal_child) {
                    indicator_revealer.visible = true;
                }
            });

            indicator_revealer.notify["child-revealed"].connect (() => {
                if (!indicator_revealer.child_revealed) {
                    indicator_revealer.visible = false;
                }
            });

            jobs_icon.set_draw_func (update_jobs_icon);

            cachier.job_added.connect ((job) => {
                job.track_saving_ended.connect (jobs_icon.queue_draw);

                indicator_revealer.reveal_child = true;
            });

            cachier.job_removed.connect (() => {
                jobs_icon.queue_draw ();

                if (jobs_popover.visible) {
                    if (timeout_id == 0) {
                        timeout_id = Timeout.add_seconds (5, () => {
                            if (jobs_popover.visible) {
                                return Source.CONTINUE;
                            }

                            if (cachier.job_list.size > 0) {
                                timeout_id = 0;
                                return Source.REMOVE;
                            }

                            indicator_revealer.reveal_child = false;

                            timeout_id = 0;
                            return Source.REMOVE;
                        });
                    }

                } else {
                    if (cachier.job_list.size == 0) {
                        indicator_revealer.reveal_child = false;
                    }
                }
            });
        }

        void fill_box () {
            foreach (var job in cachier.job_list) {
                jobs_box.append (new JobInfoBadge (job));
            }
        }

        // Took from https://gitlab.gnome.org/GNOME/nautilus/-/blob/main/src/nautilus-progress-indicator.c
        void update_jobs_icon (Gtk.DrawingArea drawing_area, Cairo.Context cairo, int width, int height) {
            int elapsed_progress = 0;
            int total_progress = 0;

            double ratio;

            var foreground = drawing_area.get_color ();
            var background = foreground;
            background.alpha *= 0.3f;

            foreach (var job in cachier.job_list) {
                elapsed_progress += job.saved_tracks_count;
                total_progress += job.total_tracks_count;
            }

            if (total_progress > 0) {
                ratio = max (0.01, (double) elapsed_progress / (double) total_progress);
            } else {
                ratio = 1;
            }

            width = drawing_area.get_width ();
            double dwidth = (double) width;

            height = drawing_area.get_height ();
            double dheight = (double) height;

            cairo.set_source_rgba (background.red, background.green, background.blue, background.alpha);

            cairo.arc (
                dwidth / 2.0,
                dheight / 2.0,
                min (dwidth, dheight) / 2.0,
                0,
                2 * Math.PI
            );
            cairo.fill ();

            cairo.move_to (
                dwidth / 2.0,
                dheight / 2.0
            );

            cairo.set_source_rgba (foreground.red, foreground.green, foreground.blue, foreground.alpha);

            cairo.arc (
                dwidth / 2.0,
                dheight / 2.0,
                min (dwidth, dheight) / 2.0,
                -Math.PI_2,
                ratio * 2 * Math.PI - Math.PI_2
            );
            cairo.fill ();
        }
    }
}
