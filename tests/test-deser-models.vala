void test_account_uid () {
    try {
        var numeric = new Deser.JsonWorker ("{\"uid\":123456789}")
            .deserialize_object<Tape.AccountAbout> ();
        assert (numeric.uid == "123456789");
        assert (numeric.content_id == numeric.uid);

        var cached = new Deser.JsonWorker ("{\"uid\":\"123456789\"}")
            .deserialize_object<Tape.AccountAbout> ();
        assert (cached.uid == numeric.uid);
    } catch (GLib.Error e) {
        error ("Account UID codec failed: %s", e.message);
    }
}

int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/deser/account-uid", test_account_uid);
    return Test.run ();
}
