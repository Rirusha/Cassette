/* Copyright 2023-2024 Rirusha
 *
 * program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Gee;

namespace CassetteClient {

    public enum Case {
        SNAKE_CASE,
        KEBAB_CASE,
        CAMEL_CASE
    }

    //  Класс для сериализации и десериализации YaMObject'ов
    public class Jsoner : Object {

        public Case names_case { get; construct; }
        public Json.Node root { get; construct; }

        public Jsoner (string json_string, string[]? sub_members = null, Case names_case = Case.KEBAB_CASE) throws ClientError {
            Json.Node? node;
            try {
                node = Json.from_string (json_string);
            } catch (Error e) {
                throw new ClientError.PARSE_ERROR ("'%s' is not correct json string".printf (json_string));
            }

            if (node == null) {
                throw new ClientError.PARSE_ERROR ("Json string is empty");
            }

            if (sub_members != null) {
                node = steps (node, sub_members);
            }

            Object (root: node, names_case: names_case);
        }

        public static Jsoner from_bytes (Bytes bytes, string[]? sub_members = null, Case names_case = Case.KEBAB_CASE) throws ClientError {
            return new Jsoner ((string) bytes.get_data (), sub_members, names_case);
        }

        public static Jsoner from_data (uint8[] data, string[]? sub_members = null, Case names_case = Case.KEBAB_CASE) throws ClientError {
            return new Jsoner ((string) data, sub_members, names_case);
        }

        static Json.Node? steps (Json.Node node, string[] sub_members) throws ClientError {
            string has_members = "";

            foreach (string member_name in sub_members) {
                if (node.get_object ().has_member (member_name)) {
                    node = node.get_object ().get_member (member_name);
                    has_members += member_name + "-";
                } else {
                    throw new ClientError.PARSE_ERROR ("Json has no %s%s".printf (has_members, member_name));
                }
            }
            return node;
        }

        /////////////////
        //  Serialize  //
        /////////////////

        public static string serialize (YaMObject yam_obj) {
            var builder = new Json.Builder ();
            serialize_object (builder, yam_obj);

            return Json.to_string (builder.get_root (), false);
        }

        static void serialize_array (Json.Builder builder, ArrayList array_list, Type element_type) {
            builder.begin_array ();

            if (element_type.parent () == typeof (YaMObject)) {
                foreach (var yam_obj in (ArrayList<YaMObject>) array_list) {
                    serialize_object (builder, yam_obj);
                }

            } else if (element_type == typeof (ArrayList)) {
                var array_of_arrays = (ArrayList<ArrayList?>) array_list;
                if (array_of_arrays.size > 0) {
                    Type sub_element_type = ((ArrayList<ArrayList?>) array_list)[0].element_type;
                    foreach (var sub_array_list in (ArrayList<ArrayList?>) array_list) {
                        serialize_array (builder, sub_array_list, sub_element_type);
                    }
                }
            } else {
                switch (element_type) {
                    case Type.STRING:
                        foreach (string val in (ArrayList<string>) array_list) {
                            serialize_value (builder, val);
                        }
                        break;

                    case Type.INT:
                        foreach (int val in (ArrayList<int>) array_list) {
                            serialize_value (builder, val);
                        }
                        break;
                }


            }
            builder.end_array ();
        }

        static void serialize_object (Json.Builder builder, YaMObject? yam_obj) {
            if (yam_obj == null) {
                builder.add_null_value ();
                return;
            }
            builder.begin_object ();
            var cls = (ObjectClass) yam_obj.get_type ().class_ref ();
            foreach (ParamSpec property in cls.list_properties ()) {
                if ((property.flags & ParamFlags.READABLE) == 0 || (property.flags & ParamFlags.WRITABLE) == 0) {
                    continue;
                }

                builder.set_member_name (strip (property.name, '-'));

                var prop_val = Value (property.value_type);
                yam_obj.get_property (property.name, ref prop_val);


                if (property.value_type == typeof (ArrayList)) {
                    var array_list = (ArrayList) prop_val.get_object ();
                    Type element_type = array_list.element_type;

                    serialize_array (builder, array_list, element_type);
                } else if (property.value_type.parent () == typeof (YaMObject)) {
                    serialize_object (builder, (YaMObject) prop_val.get_object ());
                } else {
                    serialize_value (builder, prop_val);
                }
            }
            builder.end_object ();
        }

        static void serialize_value (Json.Builder builder, Value prop_val) {
            switch (prop_val.type ()) {
                case Type.INT:
                    builder.add_int_value (prop_val.get_int ());
                    break;

                case Type.INT64:
                    builder.add_int_value (prop_val.get_int64 ());
                    break;

                case Type.DOUBLE:
                    builder.add_double_value (prop_val.get_double ());
                    break;

                case Type.STRING:
                    builder.add_string_value (prop_val.get_string ());
                    break;

                case Type.BOOLEAN:
                    builder.add_boolean_value (prop_val.get_boolean ());
                    break;

                case Type.NONE:
                    builder.add_null_value ();
                    break;

                default:
                    Logger.warning ("Unknown type for serialize - %s".printf (prop_val.type ().name ()));
                    break;
            }
        }

        ///////////////////
        //  Deserialize  //
        ///////////////////

        public YaMObject? deserialize_object (GLib.Type obj_type, Json.Node? node = null) throws ClientError {
            if (node == null) {
                node = root;
            }

            if (node.get_node_type () != Json.NodeType.OBJECT) {
                Logger.warning (_("Wrong type: expected %s, got %s").printf (Json.NodeType.OBJECT.to_string (), node.get_node_type ().to_string ()));
                throw new ClientError.PARSE_ERROR ("Node isn't object");
            }

            var yam_object = (YaMObject) Object.new (obj_type);
            yam_object.freeze_notify ();

            var class_ref = (ObjectClass) obj_type.class_ref ();
            ParamSpec[] properties = class_ref.list_properties ();

            foreach (ParamSpec property in properties) {
                if ((property.flags & ParamFlags.WRITABLE) == 0) {
                    continue;
                }

                Type prop_type = property.value_type;

                string member_name;
                switch (names_case) {
                    case Case.CAMEL_CASE:
                        member_name = kebab2camel (strip (property.name, '-'));
                        break;

                    case Case.SNAKE_CASE:
                        member_name = kebab2snake (strip (property.name, '-'));
                        break;

                    case Case.KEBAB_CASE:
                        member_name = strip (property.name, '-');
                        break;

                    default:
                        Logger.error ("Unknown case - %s".printf (names_case.to_string ()));
                        assert_not_reached ();
                }

                if (!node.get_object ().has_member (member_name)) {
                    continue;
                }

                var sub_node = node.get_object ().get_member (member_name);

                switch (sub_node.get_node_type ()) {
                    case Json.NodeType.ARRAY:
                        var arrayval = Value (prop_type);
                        yam_object.get_property (property.name, ref arrayval);
                        ArrayList array_list = (Gee.ArrayList) arrayval.get_object ();

                        deserialize_array (ref array_list, sub_node);
                        yam_object.set_property (
                            property.name,
                            array_list
                        );
                        break;

                    case Json.NodeType.OBJECT:
                        yam_object.set_property (
                            property.name,
                            deserialize_object (prop_type, sub_node)
                        );
                        break;

                    case Json.NodeType.VALUE:
                        var val = deserialize_value (sub_node);
                        if (val.type () == Type.INT64 && prop_type == Type.STRING) {
                            yam_object.set_property (
                                property.name,
                                val.get_int64 ().to_string ()
                            );
                        } else {
                            yam_object.set_property (
                                property.name,
                                val
                            );
                        }
                        break;
                    case Json.NodeType.NULL:
                        yam_object.set_property (
                            property.name,
                            Value (prop_type)
                        );
                        break;
                }
            }

            yam_object.thaw_notify ();
            return yam_object;
        }

        public Value? deserialize_value (Json.Node? node = null) throws ClientError {
            if (node == null) {
                node = root;
                            }

            if (node.get_node_type () != Json.NodeType.VALUE) {
                Logger.warning (_("Wrong type: expected %s, got %s").printf (Json.NodeType.VALUE.to_string (), node.get_node_type ().to_string ()));
                throw new ClientError.PARSE_ERROR ("Node isn't value");
            }

            return node.get_value ();
        }

        public void deserialize_array (ref ArrayList array_list, Json.Node? node = null) throws ClientError {
            if (node == null) {
                node = root;
                            }

            if (node.get_node_type () != Json.NodeType.ARRAY) {
                Logger.warning (_("Wrong type: expected %s, got %s").printf (Json.NodeType.ARRAY.to_string (), node.get_node_type ().to_string ()));
                throw new ClientError.PARSE_ERROR ("Node isn't array");
            }

            var jarray = node.get_array ();

            if (array_list.element_type.parent () == typeof (YaMObject)) {
                array_list.clear ();
                var narray_list = array_list as ArrayList<YaMObject>;

                jarray.foreach_element ((array, _index, sub_node) => {
                    try {
                        narray_list.add (deserialize_object (narray_list.element_type, sub_node));
                    } catch (ClientError e) { }
                });

            //  Нужен только для YaMAPI.Album.tracks, так как апи возвращает массив из массивов
            } else if (array_list.element_type == typeof (ArrayList)) {
                var narray_list = array_list as ArrayList<ArrayList>;

                // Проверка, если ли в массиве массив, из которого будет взят тип
                assert (narray_list.size != 0);

                Type sub_element_type = narray_list[0].element_type;

                jarray.foreach_element ((array, _index, sub_node) => {
                    ArrayList new_array_list;

                    //  Добавлять новые типы при необходимости
                    if (sub_element_type == typeof (YaMAPI.Track)) {
                        new_array_list = new ArrayList<YaMAPI.Track> ();
                    } else {
                        Logger.warning ("Unknown type of element of subarray - %s".printf (sub_element_type.name ()));
                        return;
                    }

                    try {
                        deserialize_array (ref new_array_list, sub_node);
                        narray_list.add (new_array_list);
                    } catch (ClientError e) { }
                });
                narray_list.remove (narray_list[0]);

            } else {
                array_list.clear ();
                switch (array_list.element_type) {
                    case Type.STRING:
                        var narray_list = array_list as ArrayList<string>;
                        jarray.foreach_element ((array, _index, sub_node) => {
                            try {
                                narray_list.add (deserialize_value (sub_node).get_string ());
                            } catch (ClientError e) { }
                        });
                        break;

                    case Type.INT:
                        var narray_list = array_list as ArrayList<int>;
                        jarray.foreach_element ((array, _index, sub_node) => {
                            try {
                                narray_list.add ((int) deserialize_value (sub_node).get_int64 ());
                            } catch (ClientError e) { }
                        });
                        break;

                    case Type.INT64:
                        var narray_list = array_list as ArrayList<int64>;
                        jarray.foreach_element ((array, _index, sub_node) => {
                            try {
                                narray_list.add (deserialize_value (sub_node).get_int64 ());
                            } catch (ClientError e) { }
                        });
                        break;

                    default:
                        Logger.warning ("Unknown type of element of array - %s".printf (array_list.element_type.name ()));
                        break;
                }
            }
        }
    }
}
