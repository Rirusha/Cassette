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


namespace Cassette.Client {

    public enum LogLevel {
        // Включают все логи полностью
        DEVEL,
        // Нет логов libsoup
        DEBUG,
        // Нет debug логов
        USER,
        // Не оставлять следов
        NONE
    }

    public class Logger {

        const string TIME_PREFIX = "*TIME*   ";
        const string SYSTEM_PREFIX = "*SYSTEM* ";
        const string BODY_IN_PREFIX = "*BODY* <";
        const string IN_PREFIX = "*IN*   <";
        const string BODY_OUT_PREFIX = "*BODY* >";
        const string OUT_PREFIX = "*OUT*  >";
        const string DEBUG_PREFIX = "*DEBUG*  ";
        const string DEVEL_PREFIX = "*DEVEL*  ";
        const string INFO_PREFIX = "*INFO*   ";
        const string WARNING_PREFIX = "*WARNING*";
        const string ERROR_PREFIX = "*ERROR*  ";

        static LogLevel _log_level = LogLevel.USER;
        public static LogLevel log_level {
            get {
                return _log_level;
            }
            set {
                Logger.info ("Log level set to %s".printf (
                    value.to_string ()
                ));

                _log_level = value;
            }
        }

        static File _log_file = null;
        public static File log_file {
            get {
                return _log_file;
            }
            set {
                if (_log_file != null) {
                    try {
                        Logger._log_file.delete ();
                    } catch (Error e) {
                        if (e is IOError.NOT_FOUND) { }
                    }
                }

                if (!value.query_exists ()) {
                    try {
                        value.create (FileCreateFlags.PRIVATE);

                        Logger.info ("Logger file created");

                    } catch (Error e) {
                        GLib.warning ("Can't create log file on %s. Error message: %s".printf (
                            value.peek_path (),
                            e.message
                        ));
                    }
                }

                Logger._log_file = value;

                write_to_file (SYSTEM_PREFIX, null);
                write_to_file (SYSTEM_PREFIX, null);
                write_to_file (SYSTEM_PREFIX, "Log initialized");
                write_to_file (SYSTEM_PREFIX, null);
            }
        }

        static void write_to_file (string log_level_str, string? message) {
            if (log_file == null) {
                return;
            }

            try {
                FileOutputStream os = log_file.append_to (FileCreateFlags.NONE);
                string current_time = new DateTime.now ().format ("%T.%f");

                string final_message;
                if (message != null) {
                    final_message = "%s : %s : %s\n".printf (
                        log_level_str,
                        current_time,
                        message
                    );
                } else {
                    final_message = "\n";
                }

                os.write (final_message.data);

            } catch (Error e) {
                GLib.warning ("Can't write to log file. Error message: %s".printf (e.message));
            }
        }

        static void write_net_to_file (string direction, string data) {
            if (log_file == null) {
                return;
            }

            try {
                FileOutputStream os = log_file.append_to (FileCreateFlags.NONE);
                string final_message = "%s : %s\n".printf (
                    direction,
                    data
                );
                os.write (final_message.data);
            } catch (Error e) {
                GLib.warning ("Can't write to log file. Error message: %s".printf (e.message));
            }
        }

        public static void time () {
            write_to_file (TIME_PREFIX, "\n\n");
        }

        public static void net_in (Soup.LoggerLogLevel soup_log_level, string data) {
            if (soup_log_level == Soup.LoggerLogLevel.BODY && data != "") {
                write_net_to_file (BODY_IN_PREFIX, data);
            } else {
                write_net_to_file (IN_PREFIX, data);
            }
        }

        public static void net_out (Soup.LoggerLogLevel soup_log_level, string data) {
            if (soup_log_level == Soup.LoggerLogLevel.BODY && data != "") {
                write_net_to_file (BODY_OUT_PREFIX, data);
            } else {
                write_net_to_file (OUT_PREFIX, data);
            }
        }

        public static void debug (string message) {
            if (log_level <= LogLevel.DEBUG) {
                write_to_file (DEBUG_PREFIX, message);
                GLib.debug (message);
            }
        }

        public static void devel (string message) {
            if (log_level <= LogLevel.DEVEL) {
                write_to_file (DEVEL_PREFIX, message);

                string current_time = new DateTime.now ().format ("%T.%f");
                stdout.printf ("%s : %s : %s\n".printf (
                    DEVEL_PREFIX,
                    current_time,
                    message
                ));
            }
        }

        public static void info (string message) {
            if (log_level <= LogLevel.USER) {
                write_to_file (INFO_PREFIX, message);
                GLib.info (message);
            }
        }

        public static void warning (string message) {
            if (log_level <= LogLevel.USER) {
                write_to_file (WARNING_PREFIX, message);
                GLib.warning (message);
            }
        }

        public static void error (string message) {
            if (log_level <= LogLevel.USER) {
                write_to_file (ERROR_PREFIX, message);
                GLib.error (message);
            }
        }
    }
}
