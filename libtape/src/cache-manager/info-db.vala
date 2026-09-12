/*
 * Copyright (C) 2024 Vladimir Romanov
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
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


using Gee;

/**
 * Wrapper class for the database
 * The database has an additional table for all additional information
 * about the type of uid of the application user and the tracks_rus table,
 * which counts objects that have a track. It is necessary for the correct
 * release of porridge (images and tracks), that is, track data is not
 * deleted if an object with this track is saved.
 */
public class Tape.InfoDB : Object {

    public string db_path { get; construct; }

    Sqlite.Database db;

    public InfoDB (string db_path) {
        Object (db_path: db_path);
    }

    construct {
        int error_code = Sqlite.Database.open_v2 (
            db_path,
            out db,
            Sqlite.OPEN_FULLMUTEX | Sqlite.OPEN_READWRITE | Sqlite.OPEN_CREATE
        );

        if (error_code != Sqlite.OK) {
            error ("Error while opening db %s, Sqlite error code: %s, message: %s".printf (
                db_path,
                db.errcode ().to_string (),
                db.errmsg ()
            ));
        }

        string query = "CREATE TABLE IF NOT EXISTS additional ("
                     + "   name    TEXT    PRIMARY KEY NOT NULL,"
                     + "   data    TEXT                NOT NULL"
                     + ");"
                     + "CREATE TABLE IF NOT EXISTS content_refs ("
                     + "   what_id     TEXT    NOT NULL,"
                     + "   source_id   TEXT    NOT NULL,"
                     + "   PRIMARY KEY (what_id, source_id));";

        error_code = db.exec (query, null);
        if (error_code != Sqlite.OK) {
            error ("Error while creating tables %s. Sqlite error code: %s, message: %s".printf (
                db_path,
                db.errcode ().to_string (),
                db.errmsg ()
            ));
        }
    }

    /**
     * Add or replace an additional data to db
     *
     * @param name  name of additional data
     * @param data  what to store
     */
    public void set_additional_data (string name, string data) {
        string query = "REPLACE INTO additional VALUES ($NAME, $DATA)";

        Sqlite.Statement statement;
        db.prepare_v2 (query, query.length, out statement);

        statement.bind_text (statement.bind_parameter_index ("$NAME"), name);
        statement.bind_text (statement.bind_parameter_index ("$DATA"), data);

        int error_code = statement.step ();
        if (error_code != Sqlite.DONE) {
            error ("Error while replacing additional_data %s=%s in %s. Sqlite error code: %s, message: %s".printf (
                name,
                data,
                db_path,
                db.errcode ().to_string (),
                db.errmsg ()
            ));
        }
    }

    /**
     * Get an additional data from db.
     *
     * @param name  name of additional data
     */
    public string? get_additional_data (string name) {
        string query = "SELECT * FROM additional WHERE name=$NAME;";

        Sqlite.Statement statement;
        db.prepare_v2 (query, query.length, out statement);

        statement.bind_text (statement.bind_parameter_index ("$NAME"), name);

        int error_code = statement.step ();
        if (error_code != Sqlite.DONE && error_code != Sqlite.ROW) {
            error ("Error while getting additional_data %s in %s. Sqlite error code: %s, message: %s".printf (
                name,
                db_path,
                db.errcode ().to_string (),
                db.errmsg ()
            ));
        }

        string? result = statement.column_text (1);
        statement.reset ();

        return result;
    }

    /**
     * Add or replace a content ref to db
     *
     * @param what_id   id of content
     * @param source_id id of content handler
     */
    public void set_content_ref (string what_id, string source_id) {
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
            error ("Error while set ref for %s %s in %s. Sqlite error code: %s, message: %s".printf (
                what_id,
                source_id,
                db_path,
                db.errcode ().to_string (),
                db.errmsg ()
            ));
        }
    }

    /**
     * Remove a content ref from db
     *
     * @param what_id   id of content
     * @param source_id id of content handler
     */
    public void remove_content_ref (string what_id, string source_id) {
        string query = "DELETE FROM content_refs WHERE what_id=$WHAT_ID AND source_id=$SOURCE_ID;";

        Sqlite.Statement statement;
        db.prepare_v2 (query, query.length, out statement);

        statement.bind_text (statement.bind_parameter_index ("$WHAT_ID"), what_id);
        statement.bind_text (statement.bind_parameter_index ("$SOURCE_ID"), source_id);

        int error_code = statement.step ();
        if (error_code != Sqlite.DONE) {
            error ("Error while set ref for %s %s in %s Sqlite error code: %s, message: %s".printf (
                what_id,
                source_id,
                db_path,
                db.errcode ().to_string (),
                db.errmsg ()
            ));
        }
    }

    /**
     * Get count of content refs in db
     *
     * @param what_id   id of content
     * @param source_id id of content handler. If null, returns all refs
     */
    public int get_content_ref_count (string what_id, string? source_id = null) {
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
            error ("Error while geting ref for %s in %s, Sqlite error code: %s, message: %s".printf (
                what_id,
                db_path,
                db.errcode ().to_string (),
                db.errmsg ()
            ));
        }

        return statement.column_int (0);
    }
}
