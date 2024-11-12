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
    [GtkTemplate (ui = "/space/rirusha/Cassette/ui/job-info-badge.ui")]
    public class JobInfoBadge : Gtk.Grid {
        [GtkChild]
        unowned Gtk.Label title_label;
        [GtkChild]
        unowned Gtk.ProgressBar progress_bar;
        [GtkChild]
        unowned Gtk.Label progress_label;
        [GtkChild]
        unowned Gtk.Button abort_button;

        public Cachier.Job job { get; construct; }

        public JobInfoBadge (Cachier.Job job) {
            Object (job: job);
        }

        string get_job_object_type () {
            switch (job.object_type) {
                case Cachier.ContentType.PLAYLIST:
                    return _("Playlist");
                case Cachier.ContentType.ALBUM:
                    return _("Album");
                default:
                    assert_not_reached ();
            }
        }

        construct {
            title_label.label = "%s '%s'".printf (get_job_object_type (), job.object_title);

            job.track_saving_started.connect (update_info);
            job.track_saving_ended.connect (update_info);
            update_info (job.saved_tracks_count, job.total_tracks_count, job.now_saving_tracks_count);

            job.cancelled.connect (() => {
                abort_button.sensitive = false;
            });
            abort_button.sensitive = !job.is_cancelled;

            abort_button.clicked.connect (() => {
                job.abort ();
                abort_button.sensitive = false;
            });

            job.job_done.connect (() => {
                sensitive = false;
                abort_button.sensitive = false;
                abort_button.icon_name = "emblem-default-symbolic";
            });
        }

        void update_info (int saved, int total, int now) {
            // Translators: n track from n tracks saved
            progress_label.label = ngettext (
                "%d / %d saved%s",
                "%d / %d saved%s",
                saved
            ).printf (
                saved,
                total,
                (now != 0? ". " + ngettext (
                    "%d track saving now",
                    "%d tracks saving now",
                    now
                ).printf (
                    now
                ) : "")
            );

            progress_bar.fraction = (double) saved / (double) total;
        }
    }
}
