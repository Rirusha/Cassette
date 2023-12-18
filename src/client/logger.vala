/* logger.vala
 *
 * Copyright 2023 Rirusha
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
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


namespace CassetteClient {

    public enum LogLevel {
        // Включают все логи полностью
        DEVEL,
        // Нет логов libsoup
        DEBUG,
        // Нет debug логов
        USER
    }

    public class Logger {

        public static LogLevel log_level { get; private set; default = LogLevel.USER; }

        private static File log_file;

        public static void base_setting (string log_path, LogLevel log_level) {
            log_file = File.new_for_path (log_path);
            if (!log_file.query_exists ()) {
                try {
                    log_file.create (FileCreateFlags.PRIVATE);
                } catch (Error e) {
                    // Translators: %s is path
                    GLib.warning (_("Can't create log on %s. Message: %s").printf (log_path, e.message));
                }
            }

            Logger.log_level = log_level;
        }

        public static void debug_enable () {
            if (log_level != LogLevel.DEVEL) {
                log_level = LogLevel.DEBUG;
            }
        }

        public static void debug_disable () {
            if (log_level != LogLevel.DEVEL) {
                log_level = LogLevel.USER;
            }
        }

        static void write_to_file (string log_level_str, string message) {
            if (log_file == null) {
                GLib.warning (_("Log file does not exist"));
                return;
            }

            try {
                FileOutputStream os = log_file.append_to (FileCreateFlags.NONE);
                string current_time = new DateTime.now ().format ("%T.%f");
                string final_message = log_level_str + " : " + current_time + " : " + message + "\n";
                os.write (final_message.data);
            } catch (Error e) {
                GLib.warning (_("Can't write to log file. Message: %s").printf (message));
            }
        }

        static void write_net_to_file (string direction, string data) {
            if (log_file == null) {
                GLib.warning (_("Can't write to log"));
                return;
            }

            try {
                FileOutputStream os = log_file.append_to (FileCreateFlags.NONE);
                string final_message = direction + " : " + data + "\n";
                os.write (final_message.data);
            } catch (Error e) {
                GLib.warning (_("Can't write to log"));
            }
        }

        public static void time () {
            if (log_level == LogLevel.DEVEL) {
                write_to_file ("*TIME*  ", "\n\n");
            }
        }

        public static void net_in (Soup.LoggerLogLevel soup_log_level, string data) {
            if (log_level == LogLevel.DEVEL) {
                if (soup_log_level == Soup.LoggerLogLevel.BODY && data != "") {
                    write_net_to_file ("*BODY* <", data);
                } else {
                    write_net_to_file ("*IN*   <", data);
                }
            }
        }

        public static void net_out (Soup.LoggerLogLevel soup_log_level, string data) {
            if (log_level == LogLevel.DEVEL) {
                if (soup_log_level == Soup.LoggerLogLevel.BODY && data != "") {
                    write_net_to_file ("*BODY* <", data);
                } else {
                    write_net_to_file ("*OUT*  >", data);
                }
            }
        }

        public static void debug (string message) {
            if (log_level <= LogLevel.DEBUG) {
                write_to_file ("*DEBUG*  ", message);
            }
        }

        public static void info (string message) {
            if (log_level <= LogLevel.USER) {
                write_to_file ("*INFO*   ", message);
            }
        }

        public static void warning (string message) {
            if (log_level <= LogLevel.USER) {
                write_to_file ("*WARNING*", message);
                GLib.warning (message);
            }
        }

        public static void error (string message) {
            if (log_level <= LogLevel.USER) {
                write_to_file ("*ERROR*  ", message);
                GLib.error (message);
            }
        }
    }
}
