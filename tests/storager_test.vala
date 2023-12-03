using YaMAPI;
using Cassette;

public static Storager storager;

public int main (string[] args){
    Test.init (ref args);

    Test.add_func ("/storager/init", () => {
        storager = new Storager ();
    });

    Test.add_func ("/storager/move", () => {
        
    });

    Test.add_func ("/storager/cookies_exists/exists", () => {
        storager.cookies_exists ();
    });

    Test.add_func ("/storager/images/save", () => {
        string image_url = "test_url";
        var test_pixbuf = new Gdk.Pixbuf (Gdk.Colorspace.RGB, false, 8, 1, 1);

        storager.save_image (test_pixbuf, image_url, true);
    });

    Test.add_func ("/storager/images/location", () => {
        string image_url = "test_url";
        var location = storager.image_cache_location (image_url);

        if (location.is_tmp != true || location.path == null) {
            Test.fail_printf ("Image not found");
        }
    });

    Test.add_func ("/storager/images/load", () => {
        string image_url = "test_url";
        storager.load_image (image_url);
    });

    Test.add_func ("/storager/tracks/save", () => {
        string track_url = "123456789";

        var test_track = new Bytes ("i swear, thats music string...".data);

        storager.save_audio (test_track, track_url, true);
    });

    Test.add_func ("/storager/tracks/location", () => {
        string track_url = "123456789";
        var location = storager.audio_cache_location (track_url);

        if (location.is_tmp != true || location.path == null) {
            Test.fail_printf ("Track not found");
        }
    });

    Test.add_func ("/storager/tracks/load", () => {
        string track_url = "123456789";
        storager.load_audio (track_url);
    });

    Test.add_func ("/storager/objects/save", () => {
        var test_obj = new Playlist.liked () { uid = "123", kind = "3"};
        
        storager.save_object (test_obj, true);
    });

    Test.add_func ("/storager/objects/location", () => {
        var location = storager.object_cache_location (typeof (Playlist), "123:3");

        if (location.is_tmp != true || location.path == null) {
            Test.fail_printf ("Object not found");
        }
    });

    Test.add_func ("/storager/objects/load", () => {
        var test_obj = (Playlist) storager.load_object (typeof (Playlist), "123:3");
        if (test_obj.uid != "123" || test_obj.kind != "3") {
            Test.fail_printf ("Wrong loading object");
        }
    });

    return Test.run ();
}
