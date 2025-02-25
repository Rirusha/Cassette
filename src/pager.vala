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
using Gee;


namespace Cassette {

    public const string PAGER_PAGES_DELIMETER = "__PAGES_DELIMETER__";
    public const string PAGER_PARTS_DELIMETER = "__PART_DELIMETER__";
    public const string PAGER_ARGS_DELIMETER = "__ARGS_DELIMETER__";

    public enum PagesType {
        ONLINE,
        LOCAL
    }

    public struct PageInfo {
        public string id;
        public string title;
        public string icon_name;
        public string view_type_name;
        public string?[] args;

        public static PageInfo from_string (string page_info_str) {
            string[] all = page_info_str.split (PAGER_PARTS_DELIMETER);

            string?[] all_args = all[4].split (PAGER_ARGS_DELIMETER);
            for (int i = 0; i < all_args.length; i++) {
                if (all_args[i] == "") {
                    all_args[i] = null;
                }
            }

            return {
                all[0],
                all[1],
                all[2],
                all[3],
                all_args
            };
        }

        public string to_string () {
            return id + PAGER_PARTS_DELIMETER +
                title + PAGER_PARTS_DELIMETER +
                icon_name + PAGER_PARTS_DELIMETER +
                view_type_name + PAGER_PARTS_DELIMETER +
                string.joinv (PAGER_ARGS_DELIMETER, args);
        }
    }

    public string[] get_args_names (Type view_type) {
        if (view_type == typeof (PlaylistView)) {
            return {"uid", "kind"};
        } else if (view_type == typeof (PlaylistsView)) {
            return {"uid"};
        } else {
            message (view_type.name ());
            assert_not_reached ();
        }
    }

    /**
     * Класс менеджера станиц, нужен для добавления кастомных страниц
     */
    public class Pager : Object {

        public Window window { get; construct set; }
        public Adw.ViewStack stack { get; construct set; }

        Gee.ArrayList<PageInfo?> _custom_pages = new Gee.ArrayList<PageInfo?> ();
        public Gee.ArrayList<PageInfo?> custom_pages {
            get {
                return _custom_pages;
            }
            set {
                _custom_pages = value;

                load_pages ();
            }
        }

        File pages_file;

        public Pager (Window window, Adw.ViewStack stack) {
            Object (window: window, stack: stack);
        }

        construct {
            pages_file = File.new_build_filename (storager.data_dir_file.peek_path (), "cassette.pages");

            // Type register
            typeof (PlaylistView).ensure ();
            typeof (PlaylistsView).ensure ();
            typeof (MainView).ensure ();
            typeof (DevelView).ensure ();

            Cassette.settings.changed.connect ((key) => {
                if (
                    (key == "show-main" ||
                    key == "show-liked" ||
                    key == "show-playlists") &&
                    Cassette.settings.get_boolean ("default-pages-set")
                ) {
                    load_pages ();
                }
            });
        }

        void add_page (PageInfo page_info) {
            Type view_type = Type.from_name (page_info.view_type_name);

            BaseView view;
            if (page_info.args.length == 0) {
                view = (BaseView) Object.new (view_type);
            } else {
                var vals = new Value[page_info.args.length];

                for (int i = 0; i < vals.length; i++) {
                    vals[i] = page_info.args[i];
                }

                view = (BaseView) Object.new_with_properties (view_type, get_args_names (view_type), vals);
            }

            var ready_view = new PageRoot (window, view);

            stack.add_titled_with_icon (
                ready_view,
                page_info.id,
                page_info.title,
                page_info.icon_name
            );
        }

        public void update_page (string page_id, string? new_page_title, string? new_page_icon_name) {
            if (
                new_page_title != null &&
                (
                    PAGER_ARGS_DELIMETER in new_page_title ||
                    PAGER_PARTS_DELIMETER in new_page_title ||
                    PAGER_PAGES_DELIMETER in new_page_title
                )
            ) {
                window.show_toast (_("Can't set title \"%s\" to page").printf (new_page_title));
                return;
            }
            if (
                new_page_icon_name != null &&
                (
                    PAGER_ARGS_DELIMETER in new_page_icon_name ||
                    PAGER_PARTS_DELIMETER in new_page_icon_name ||
                    PAGER_PAGES_DELIMETER in new_page_icon_name
                )
            ) {
                window.show_toast (_("Can't set icon with name \"%s\" to page").printf (new_page_icon_name));
                return;
            }

            for (int i = 0; i < _custom_pages.size; i++) {
                if (_custom_pages[i].id == page_id) {
                    var page_info = _custom_pages[i];

                    if (new_page_title != null) {
                        page_info.title = new_page_title;
                    }
                    if (new_page_title != null) {
                        page_info.icon_name = new_page_icon_name;
                    }

                    _custom_pages[i] = page_info;
                    break;
                }
            }

            save_pages ();
            load_pages ();
        }

        public void add_custom_page (PageInfo page_info) {
            if (_custom_pages.size == 3) {
                window.show_toast (_("Reached max page count"));
                return;
            }

            foreach (var pg_i in _custom_pages) {
                if (pg_i.id == page_info.id) {
                    window.show_toast (_("Page '%s' already added").printf (page_info.title));
                    return;
                }
            }

            add_page (page_info);
            _custom_pages.add (page_info);

            save_pages ();
        }

        public void load_pages (PagesType? pages_type_if_failed = null) {
            /**
                Загружает страницы из файлы. Если файла неи, то загружает страницы по-умолчанию
                исходя из значения `is_online`
            */

            clear_pages ();

            if (pages_type_if_failed != null) {
                if (!Cassette.settings.get_boolean ("default-pages-set")) {
                    switch (pages_type_if_failed) {
                        case PagesType.ONLINE:
                            set_online_default_pages ();
                            break;
                        case PagesType.LOCAL:
                            set_local_default_pages ();
                            break;
                        default:
                            assert_not_reached ();
                    }
                    Cassette.settings.set_boolean ("default-pages-set", true);
                }
            }

            load_static_pages ();
            load_custom_pages ();
        }

        void set_online_default_pages () {
            Cassette.settings.set_boolean ("show-main", true);
            Cassette.settings.set_boolean ("show-liked", true);
            Cassette.settings.set_boolean ("show-playlists", true);
        }

        void set_local_default_pages () {
            assert_not_reached ();
        }

        void load_static_pages () {
            if (application.is_devel) {
                add_page ({
                    "devel",
                    "Devel",
                    "wave-mood-epic-symbolic",
                    typeof (DevelView).name ()
                });
            }

            if (Cassette.settings.get_boolean ("show-main")) {
                add_page ({
                    "main",
                    _("Main"),
                    "user-home-symbolic",
                    typeof (MainView).name ()
                });
            }

            if (Cassette.settings.get_boolean ("show-liked")) {
                add_page ({
                    "liked",
                    _("Liked"),
                    "emblem-favorite-symbolic",
                    typeof (PlaylistView).name (),
                    {null, "3"}
                });
            }

            if (Cassette.settings.get_boolean ("show-playlists")) {
                add_page ({
                    "playlists",
                    _("Playlists"),
                    "view-list-symbolic",
                    typeof (PlaylistsView).name (),
                    {null}
                });
            }
        }

        void load_custom_pages () {
            try {
                if (!pages_file.query_exists ()) {
                    return;
                }

                uint8[] content;
                pages_file.load_contents (null, out content, null);
                string content_str = (string) Base64.decode ((string) content);

                string[] contents = content_str.split (PAGER_PAGES_DELIMETER);

                for (int i = 0; i < contents.length; i++) {
                    add_custom_page (PageInfo.from_string (contents[i]));
                }

            } catch (Error e) {
                Logger.warning (_("Can't read pages file. Message: %s").printf (e.message));
            }
        }

        void save_pages () {
            string[] content = new string[_custom_pages.size];

            for (int i = 0; i < content.length; i++) {
                content[i] = _custom_pages[i].to_string ();
            }

            try {
                if (!pages_file.query_exists ()) {
                    pages_file.create (FileCreateFlags.PRIVATE);
                }

                string content_str = Base64.encode (string.joinv (PAGER_PAGES_DELIMETER, content).data);
                FileUtils.set_contents (pages_file.peek_path (), content_str, content_str.length);

            } catch (Error e) {
                Logger.warning (_("Can't create pages file. Message: %s").printf (e.message));
            }
        }

        void clear_pages () {
            foreach (var page_info in _custom_pages) {
                stack.remove (stack.get_child_by_name (page_info.id));
            }

            _custom_pages.clear ();

            clear_static_page ("devel");
            clear_static_page ("main");
            clear_static_page ("liked");
            clear_static_page ("playlists");
        }

        void clear_page (string page_id) {
            stack.remove (stack.get_child_by_name ( page_id));

            for (int i = 0; i < _custom_pages.size; i++) {
                if (_custom_pages[i].id == page_id) {
                    _custom_pages.remove_at (i);
                    break;
                }
            }
        }

        void clear_static_page (string page_id) {
            if (stack.get_child_by_name (page_id) != null) {
                clear_page (page_id);
            }
        }

        public void remove_page (string page_id) {
            clear_page (page_id);

            save_pages ();
        }
    }
}
