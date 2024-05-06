// ind-check=skip-file

using Cassette.Client;
using Cassette.Client.Cachier;


public int main (string[] args) {
    Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.GNOMELOCALEDIR);
    Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
    Intl.textdomain (Config.GETTEXT_PACKAGE);

    Test.init (ref args);

    FileUtils.remove ("test.db");
    Logger.log_file = File.new_for_path ("./test.log");
    Logger.log_level = LogLevel.DEBUG;

    Test.add_func ("/db-info/open-db", () => {
        new InfoDB ("test.db");
    });

    Test.add_func ("/db-info/additional/set", () => {
        var db = new InfoDB ("test.db");

        db.set_additional_data ("test_name", "42");
    });

    Test.add_func ("/db-info/additional/get", () => {
        var db = new InfoDB ("test.db");

        string data = db.get_additional_data ("test_name");

        if (data != "42") {
            Test.fail_printf (@"$data != 42");
        }
    });

    Test.add_func ("/db-info/track-ref/set", () => {
        var db = new InfoDB ("test.db");

        db.set_content_ref ("111", "222");
        db.set_content_ref ("111", "222");
        db.set_content_ref ("111", "222");
        db.set_content_ref ("112", "222");
        db.set_content_ref ("112", "223");
        db.set_content_ref ("112", "224");
        db.set_content_ref ("113", "223");
    });

    Test.add_func ("/db-info/track-ref/get", () => {
        var db = new InfoDB ("test.db");

        int r1 = db.get_content_ref_count ("111");
        int r2 = db.get_content_ref_count ("112");
        int r3 = db.get_content_ref_count ("113");

        if (r1 != 1 || r2 != 3 || r3 != 1) {
            Test.fail_printf (
                @"$r1 != 1" +
                @"$r2 != 3" +
                @"$r3 != 1"
            );
        }
    });

    Test.add_func ("/db-info/track-ref/remove", () => {
        var db = new InfoDB ("test.db");

        db.remove_content_ref ("112", "222");

        int r2 = db.get_content_ref_count ("112");

        if (r2 != 2) {
            Test.fail_printf (
                @"$r2 != 2"
            );
        }
    });

    return Test.run ();
}
