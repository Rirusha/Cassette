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


using Gee;

namespace Cassette.Client.Cachier {
    public class InfoDB : Object {
        /**
            Класс-обёртка для базы данных
            База данных имеет таблицу additional для всякой доп инфы по типу uid пользователя приложения
                и таблицу tracks_refs, в которой ведется подсчёт обьектов, которые имют трек. Нужна для
                корректного освобождения кэшей (картинок и треков), то есть данные трека не удаляются, если
                сохранен обьект, имеющий этот трек.
        */

        public string db_path { get; construct; }

        Sqlite.Database db;

        public InfoDB (string db_path) {
            Object (db_path: db_path);
        }

        construct {
            int error_code = Sqlite.Database.open_v2 (
                db_path, out db, Sqlite.OPEN_FULLMUTEX | Sqlite.OPEN_READWRITE | Sqlite.OPEN_CREATE);
            if (error_code != Sqlite.OK) {
                Logger.error ("Error while opening db %s, Sqlite error code: %s, message: %s".printf (
                    db_path,
                    db.errcode ().to_string (),
                    db.errmsg ()
                ));
            }

            string query = "CREATE TABLE IF NOT EXISTS additional (" +
                           "   name    TEXT    PRIMARY KEY NOT NULL," +
                           "   data    TEXT                NOT NULL" +
                           ");" +
                           "CREATE TABLE IF NOT EXISTS content_refs (" +
                           "   what_id     TEXT    NOT NULL," +
                           "   source_id   TEXT    NOT NULL," +
                           "   PRIMARY KEY (what_id, source_id));";

            error_code = db.exec (query, null);
            if (error_code != Sqlite.OK) {
                Logger.error ("Error while creating tables %s, Sqlite error code: %s, message: %s".printf (
                    db_path,
                    db.errcode ().to_string (),
                    db.errmsg ()
                ));
            }
        }

        public void set_additional_data (string name, string data) {
            /**
                Добавляет в базу данных кастомную запись
            */

            string query = "REPLACE INTO additional VALUES ($NAME, $DATA)";

            Sqlite.Statement statement;
            db.prepare_v2 (query, query.length, out statement);

            statement.bind_text (statement.bind_parameter_index ("$NAME"), name);
            statement.bind_text (statement.bind_parameter_index ("$DATA"), data);

            int error_code = statement.step ();
            if (error_code != Sqlite.DONE) {
                Logger.error (
                    "Error while replacing additional_data %s=%s in %s, Sqlite error code: %s, message: %s".printf (
                        name,
                        data,
                        db_path,
                        db.errcode ().to_string (),
                        db.errmsg ()
                    )
                );
            }
        }

        public string get_additional_data (string name) {
            /**
                Получает из базы данны кастомную запись по имени.
                Получемые данные должны быть в базе данных
            */

            string query = "SELECT * FROM additional WHERE name=$NAME;";

            Sqlite.Statement statement;
            db.prepare_v2 (query, query.length, out statement);

            statement.bind_text (statement.bind_parameter_index ("$NAME"), name);

            int error_code = statement.step ();
            if (error_code != Sqlite.DONE && error_code != Sqlite.ROW) {
                Logger.error (
                    "Error while getting additional_data %s in %s, Sqlite error code: %s, message: %s".printf (
                        name,
                        db_path,
                        db.errcode ().to_string (),
                        db.errmsg ()
                    )
                );
            }

            string result = statement.column_text (1);
            statement.reset ();

            return result;
        }

        public void set_content_ref (string what_id, string source_id) {
            /**
                Создать запись о сохраненном объекте

                what_id: Индентификатор объекта
                source_id: Индентификатор держателя объекта
            */

            if (get_content_ref_count (what_id, source_id) != 0) {
                return;
            }

            string query = "REPLACE INTO content_refs VALUES ($WHAT_ID, $SOURCE_ID)";

            Sqlite.Statement statement;
            db.prepare_v2 (query, query.length, out statement);

            statement.bind_text (statement.bind_parameter_index ("$WHAT_ID"), what_id);
            statement.bind_text (statement.bind_parameter_index ("$SOURCE_ID"), source_id);

            int error_code = statement.step ();
            if (error_code != Sqlite.DONE) {
                Logger.error ("Error while set ref for %s %s in %s, Sqlite error code: %s, message: %s".printf (
                    what_id,
                    source_id,
                    db_path,
                    db.errcode ().to_string (),
                    db.errmsg ()
                ));
            }
        }

        public void remove_content_ref (string what_id, string source_id) {
            /**
                Удалить запись о сохраненном объекте

                what_id: Индентификатор объекта
                source_id: Индентификатор держателя объекта
            */

            string query = "DELETE FROM content_refs WHERE what_id=$WHAT_ID AND source_id=$SOURCE_ID;";

            Sqlite.Statement statement;
            db.prepare_v2 (query, query.length, out statement);

            statement.bind_text (statement.bind_parameter_index ("$WHAT_ID"), what_id);
            statement.bind_text (statement.bind_parameter_index ("$SOURCE_ID"), source_id);

            int error_code = statement.step ();
            if (error_code != Sqlite.DONE) {
                Logger.error ("Error while set ref for %s %s in %s, Sqlite error code: %s, message: %s".printf (
                    what_id,
                    source_id,
                    db_path,
                    db.errcode ().to_string (),
                    db.errmsg ()
                ));
            }
        }

        public int get_content_ref_count (string what_id, string? source_id = null) {
            /**
                Получить количество записей об объекте

                what_id: Индентификатор объекта
                source_id: Индентификатор держателя объекта. 
                           Если null, будут получены все записи, имеющие what_id
            */

            string query = "SELECT COUNT(*) FROM content_refs WHERE what_id=$WHAT_ID";

            if (source_id != null) {
                query += " AND source_id=$SOURCE_ID;";
            } else {
                query += ";";
            }

            Sqlite.Statement statement;
            db.prepare_v2 (query, query.length, out statement);

            statement.bind_text (statement.bind_parameter_index ("$WHAT_ID"), what_id);
            if (source_id != null) {
                statement.bind_text (statement.bind_parameter_index ("$SOURCE_ID"), source_id);
            }

            int error_code = statement.step ();
            if (error_code != Sqlite.ROW) {
                Logger.error ("Error while getting ref for %s in %s, Sqlite error code: %s, message: %s".printf (
                    what_id, db_path, db.errcode ().to_string (), db.errmsg ()
                ));
            }
            return statement.column_int (0);
        }
    }
}
