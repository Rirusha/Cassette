void test_track_collections () {
    try {
        var settings = new Deser.Settings () { names_case = Deser.Case.CAMEL };
        var worker = new Deser.JsonWorker (
            "{\"id\":\"42\",\"title\":\"Song\",\"artists\":[{\"id\":\"7\",\"name\":\"Artist\"}]," +
            "\"albums\":[],\"availableForOptions\":[\"bookmate\"]}",
            settings
        );
        var track = worker.deserialize_object<Tape.YaMAPI.Track> ();
        assert (track.id == "42");
        assert (track.artists.length == 1);
        assert (track.artists[0].name == "Artist");
        assert (track.need_bookmate);

        var output = Deser.JsonWorker.serialize (
            track,
            new Deser.ObjectCodec<Tape.YaMAPI.Track> (),
            settings
        );
        var restored = new Deser.JsonWorker (output, settings)
            .deserialize_object<Tape.YaMAPI.Track> ();
        assert (restored.artists.length == 1);

        var cached_json = Deser.JsonWorker.serialize (
            (GLib.Object) track,
            new Deser.ObjectCodec<GLib.Object>.from_gtype (track.get_type ()),
            settings
        );
        var cached = new Deser.JsonWorker (cached_json, settings)
            .deserialize_object_by_type (typeof (Tape.YaMAPI.Track)) as Tape.YaMAPI.Track;
        assert (cached != null && cached.artists.length == 1);
    } catch (GLib.Error e) {
        error ("Track codec failed: %s", e.message);
    }
}

void test_nested_volumes () {
    try {
        var album = new Deser.JsonWorker (
            "{\"id\":\"a\",\"volumes\":[[{\"id\":\"t\"}]]}"
        ).deserialize_object<Tape.YaMAPI.Album> ();
        assert (album.volumes.length == 1);
        assert (album.volumes[0].length == 1);
        assert (album.volumes[0][0].id == "t");
    } catch (GLib.Error e) {
        error ("Nested collection codec failed: %s", e.message);
    }
}

void test_library_map () {
    try {
        var settings = new Deser.Settings () { names_case = Deser.Case.CAMEL };
        var ids = new Deser.JsonWorker (
            "{\"defaultLibrary\":{\"42\":1},\"artists\":{\"7\":-1}}",
            settings
        ).deserialize_object<Tape.YaMAPI.Library.AllIds> ();
        assert (ids.default_library.lookup ("42") == 1);
        assert (ids.artists.lookup ("7") == -1);
    } catch (GLib.Error e) {
        error ("Library codec failed: %s", e.message);
    }
}

int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/deser/track-collections", test_track_collections);
    Test.add_func ("/deser/library-map", test_library_map);
    Test.add_func ("/deser/nested-volumes", test_nested_volumes);
    return Test.run ();
}
