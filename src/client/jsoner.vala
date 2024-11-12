/* Copyright 2023-2024 Vladimir Vaskov
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

namespace Cassette.Client {

    /**
     * Перечисление нейм кейсов.
     */
    public enum Case {
        SNAKE,
        KEBAB,
        CAMEL
    }

    /**
     * Класс для сериализации и десериализации объектов ``Cassette.Client.YaMObject``.
     * Умеет работать с ``Cassette.Client.YaMAPI.YaMObject``, ``Gee.ArrayList<YaMObject>`` и ``GLib.Value``
     */
    public class Jsoner : Object {

        /**
         * Нейм кейс для десериализации
         */
        public Case names_case { get; construct; }

        /**
         * Корневая нода, получается после прохождения по названиям элементов json,
         * указанных в sub_members конструктора
         */
        public Json.Node root { get; construct; }

        /**
         * Базовый конструктор класса. Выполняет инициализацию для десериализации.
         * Принимает json строку. В случе ошибки при парсинге,
         * выбрасывает ``Cassette.Client.ClientError.PARSE_ERROR``
         *
         * @param json_string   json строка
         * @param sub_members   массив имён элементов json, по которым нужно пройти до целевой ноды
         * @param names_case    нейм кейс имён элементов в json строке
         */
        public Jsoner (
            string json_string,
            string[]? sub_members = null,
            Case names_case = Case.KEBAB
        ) throws ClientError {
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

        /**
         * Конструктор класса. Выполняет инициализацию для десериализации.
         * Принимает json строку в виде байтов, объекта ``GLib.Bytes``. В случе ошибки при парсинге,
         * выбрасывает ``Cassette.Client.ClientError.PARSE_ERROR``
         *
         * @param bytes         json строка в виде байтов, объекта ``GLib.Bytes``
         * @param sub_members   массив имён элементов json, по которым нужно пройти до целевой ноды
         * @param names_case    нейм кейс имён элементов в json строке
         */
        public static Jsoner from_bytes (
            Bytes bytes,
            string[]? sub_members = null,
            Case names_case = Case.KEBAB
        ) throws ClientError {
            if (bytes.length < 1) {
                throw new ClientError.PARSE_ERROR ("Json string is empty");
            }

            return from_data (bytes.get_data (), sub_members, names_case);
        }

        /**
         * Конструктор класса. Выполняет инициализацию для десериализации.
         * Принимает json строку в виде байтов, массива ``uint8``. В случе ошибки при парсинге,
         * выбрасывает ``Cassette.Client.ClientError.PARSE_ERROR``
         *
         * @param bytes         json строка в виде байтов, массива ``uint8``
         * @param sub_members   массив имён элементов json, по которым нужно пройти до целевой ноды
         * @param names_case    нейм кейс имён элементов в json строке
         */
        public static Jsoner from_data (
            uint8[] data,
            string[]? sub_members = null,
            Case names_case = Case.KEBAB
        ) throws ClientError {
            return new Jsoner ((string) data, sub_members, names_case);
        }

        /**
         * Функция для выполнения перехода в переданной ноде по названиям элементов.
         * В случае, если элемент не найден, будет выкинута ``Cassette.Client.ClientError.PARSE_ERROR``
         *
         * @param node          исходная json нода
         * @param sub_members   массив "путь" имён элементов, по которому нужно пройти
         *
         * @return              целевая json нода
         */
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

        /**
         * Функция для сериализации ``GLib.Datalist<string>`` в json строку.
         *
         * @param datalist  объект ``Glib.Datalist``, который нужно сериализовать
         *
         * @return          json строка
         */
        public static string serialize_datalist (Datalist<string> datalist) {
            var builder = new Json.Builder ();
            builder.begin_object ();

            datalist.foreach ((key_id, data) => {
                builder.set_member_name (key_id.to_string ());

                Jsoner.serialize_value (builder, data);
            });

            builder.end_object ();

            var generator = new Json.Generator ();
            generator.set_root (builder.get_root ());

            return generator.to_data (null);
        }

        /**
         * Функция для сериализации ``YaMObject`` в json строку.
         *
         * @param datalist      объект ``YaMObject``, который нужно сериализовать
         * @param names_case    нейм кейс имён элементов в json строке
         *
         * @return              json строка
         */
        public static string serialize (YaMObject yam_obj, Case names_case = Case.KEBAB) {
            var builder = new Json.Builder ();
            serialize_object (builder, yam_obj, names_case);

            return Json.to_string (builder.get_root (), false);
        }

        /**
         * Функция для сериализации ``Gee.ArrayList``.
         * Элементы списка могут быть:
         *  - ``Cassette.Client.YaMObject`` 
         *  - ``string`` 
         *  - ``int32`` 
         *  - ``int64`` 
         *  - ``double`` 
         *  - ``Gee.ArrayList`` 
         *
         * @param builder       объект ``Json.Builder``
         * @param array_list    объект ``Gee.ArrayList``, который нужно сериализовать
         * @param element_type  тип элементов в array_list
         * @param names_case    нейм кейс имён элементов в json строке
         */
        static void serialize_array (
            Json.Builder builder,
            ArrayList array_list,
            Type element_type,
            Case names_case = Case.KEBAB
        ) {
            builder.begin_array ();

            if (element_type.parent () == typeof (YaMObject)) {
                foreach (var yam_obj in (ArrayList<YaMObject>) array_list) {
                    serialize_object (builder, yam_obj, names_case);
                }

            } else if (element_type == typeof (ArrayList)) {
                var array_of_arrays = (ArrayList<ArrayList?>) array_list;
                if (array_of_arrays.size > 0) {
                    Type sub_element_type = ((ArrayList<ArrayList?>) array_list)[0].element_type;
                    foreach (var sub_array_list in (ArrayList<ArrayList?>) array_list) {
                        serialize_array (builder, sub_array_list, sub_element_type, names_case);
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

        /**
         * Функция для сериализации ``Cassette.Client.YaMAPI.YaMObject`` или ``null``.
         *
         * @param builder       объект ``Json.Builder``
         * @param yam_obj       объект ``Cassette.Client.YaMAPI.YaMObject``, который нужно сериализовать.
         *                      Может быть ``null``
         * @param names_case    нейм кейс имён элементов в json строке
         */
        static void serialize_object (Json.Builder builder, YaMObject? yam_obj, Case names_case = Case.KEBAB) {
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

                switch (names_case) {
                    case Case.CAMEL:
                        builder.set_member_name (kebab2camel (strip (property.name, '-')));
                        break;

                    case Case.SNAKE:
                        builder.set_member_name (kebab2snake (strip (property.name, '-')));
                        break;

                    case Case.KEBAB:
                        builder.set_member_name (strip (property.name, '-'));
                        break;

                    default:
                        Logger.error ("Unknown case - %s".printf (names_case.to_string ()));
                        assert_not_reached ();
                }

                var prop_val = Value (property.value_type);
                yam_obj.get_property (property.name, ref prop_val);

                if (property.value_type == typeof (ArrayList)) {
                    var array_list = (ArrayList) prop_val.get_object ();
                    Type element_type = array_list.element_type;

                    serialize_array (builder, array_list, element_type, names_case);

                } else if (property.value_type.parent () == typeof (YaMObject)) {
                    serialize_object (builder, (YaMObject) prop_val.get_object (), names_case);

                } else {
                    serialize_value (builder, prop_val);
                }
            }

            builder.end_object ();
        }

        /**
         * Функция для сериализации ``GLib.Value`` или ``null``.
         *
         * @param builder       объект ``Json.Builder``
         * @param prop_val      значение базового типа, который нужно сериализовать.
         *                      Может содержать ``null``
         */
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

        /**
         * Метод для десериализации данных о библиотеке пользователя.
         * Существует, так как API возвращает json, в котором вместо списков с id
         * решили каждый элемент списка сделать отдельным элементом json объекта.
         *
         * @return  десериализованный объект
         */
        public YaMAPI.Library.AllIds deserialize_lib_data () throws ClientError {
            var lib_data = new YaMAPI.Library.AllIds ();

            var node = root;

            if (node.get_node_type () != Json.NodeType.OBJECT) {
                Logger.warning (_("Wrong type: expected %s, got %s").printf (
                    Json.NodeType.OBJECT.to_string (), node.get_node_type ().to_string ()
                ));
                throw new ClientError.PARSE_ERROR ("Node isn't object");
            }

            var ld_obj = node.get_object ();

            foreach (var ld_type_name in ld_obj.get_members ()) {
                var ld_type_obj = ld_obj.get_member (ld_type_name).get_object ();

                if (ld_type_name == "defaultLibrary") {
                    foreach (var ld_val_name in ld_type_obj.get_members ()) {
                        if (ld_type_obj.get_int_member (ld_val_name) == 1) {
                            lib_data.liked_tracks.add (ld_val_name);

                        } else {
                            lib_data.disliked_tracks.add (ld_val_name);
                        }
                    }

                } else if (ld_type_name == "artists") {
                    foreach (var ld_val_name in ld_type_obj.get_members ()) {
                        if (ld_type_obj.get_int_member (ld_val_name) == 1) {
                            lib_data.liked_artists.add (ld_val_name);

                        } else {
                            lib_data.disliked_artists.add (ld_val_name);
                        }
                    }

                } else {
                    var tval = Value (Type.OBJECT);
                    lib_data.get_property (camel2kebab (ld_type_name), ref tval);

                    var lb = (Gee.ArrayList<string>) tval.get_object ();

                    foreach (var ld_val_name in ld_type_obj.get_members ()) {
                        lb.add (ld_val_name);
                    }
                }
            }

            return lib_data;
        }

        /**
         * Метод для десериализации объекта ``Cassette.Client.YaMAPI.YaMObject``.
         *
         * @param obj_type  тип объекта, по которому будет десериализован json
         * @param node      нода, которая будет десериализована. Будет использовано свойство
         *                  root, если передан ``null``   
         *
         * @return          десериализованный объект
         */
        public YaMObject? deserialize_object (GLib.Type obj_type, Json.Node? node = null) throws ClientError {
            if (node == null) {
                node = root;
            }

            if (node.get_node_type () != Json.NodeType.OBJECT) {
                Logger.warning (_("Wrong type: expected %s, got %s").printf (
                    Json.NodeType.OBJECT.to_string (), node.get_node_type ().to_string ()
                ));
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
                    case Case.CAMEL:
                        member_name = kebab2camel (strip (property.name, '-'));
                        break;

                    case Case.SNAKE:
                        member_name = kebab2snake (strip (property.name, '-'));
                        break;

                    case Case.KEBAB:
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

        /**
         * Метод для десериализации значения.
         * 
         * @param node      нода, которая будет десериализована. Будет использовано свойство
         *                  root, если передан ``null``   
         *
         * @return          десериализованное значение
         */
        public Value? deserialize_value (Json.Node? node = null) throws ClientError {
            if (node == null) {
                node = root;
            }

            if (node.get_node_type () != Json.NodeType.VALUE) {
                Logger.warning (_("Wrong type: expected %s, got %s").printf (
                    Json.NodeType.VALUE.to_string (), node.get_node_type ().to_string ()
                ));
                throw new ClientError.PARSE_ERROR ("Node isn't value");
            }

            return node.get_value ();
        }

        /**
         * Метод для десериализации ``Gee.ArrayList``.
         * Поддерживает только одиночную вложенность (список в списке).
         * В сучае вложенности, массив должен содержать в себе массив с определенным типом элементов
         * 
         * @param array_list    ссылка на ``Gee.ArrayList``, который будет заполнен значениями
         * @param node          нода, которая будет десериализована. Будет использовано свойство
         *                      root, если передан ``null``   
         */
        public void deserialize_array (ref ArrayList array_list, Json.Node? node = null) throws ClientError {
            if (node == null) {
                node = root;
            }

            if (node.get_node_type () != Json.NodeType.ARRAY) {
                Logger.warning (_("Wrong type: expected %s, got %s").printf (
                    Json.NodeType.ARRAY.to_string (), node.get_node_type ().to_string ()
                ));
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
                        Logger.warning ("Unknown type of element of array - %s".printf (
                            array_list.element_type.name ()
                        ));
                        break;
                }
            }
        }
    }
}
