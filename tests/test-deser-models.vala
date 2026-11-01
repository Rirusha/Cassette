void test_library_map () {
    try {
        var settings = new Deser.Settings () { names_case = Deser.Case.CAMEL };
        var ids = new Deser.JsonWorker (
            "{\"defaultLibrary\":{\"42\":1},\"artists\":{\"7\":-1}}",
            settings
        ).deserialize_object<Tape.YaMAPILibraryAllIds> ();
        assert (ids.default_library.lookup ("42") == 1);
        assert (ids.artists.lookup ("7") == -1);
    } catch (GLib.Error e) {
        error ("Library codec failed: %s", e.message);
    }
}

int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/deser/library-map", test_library_map);
    return Test.run ();
}
