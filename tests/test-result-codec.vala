class ResultItem : Deser.DataObject {
    public string id { get; set; }
}

void test_result_object () {
    try {
        var item = new Deser.JsonWorker (
            "{\"result\":{\"id\":\"42\"},\"ignored\":true}"
        ).deserialize_with_codec (
            new Tape.ResultCodec<ResultItem> (new Deser.ObjectCodec<ResultItem> ())
        );
        assert (item.id == "42");
    } catch (GLib.Error e) {
        error ("Result object failed: %s", e.message);
    }
}

void test_result_array () {
    try {
        var items = new Deser.JsonWorker (
            "{\"result\":[{\"id\":\"42\"}]}"
        ).deserialize_with_codec (
            new Tape.ResultCodec<GLib.GenericArray<ResultItem>> (
                Deser.create_codec_for_array<ResultItem> ()
            )
        );
        assert (items.length == 1 && items[0].id == "42");
    } catch (GLib.Error e) {
        error ("Result array failed: %s", e.message);
    }
}

int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/result/object", test_result_object);
    Test.add_func ("/result/array", test_result_array);
    return Test.run ();
}
