// ind-check=skip-file
// vala-lint=skip-file

using Tape;

public async void account_about_test () {
    var client = new Client (new Settings ("CassetteApiTest", "space.rirusha.Cassette.ApiTest"));
    bool inited = yield client.init (TestConfig.TOKEN);
    assert (inited);
    assert (client.ym.me.login != "");
}

public int main (string[] args) {
    Test.init (ref args);

    Test.add_func ("/api/account-about", () => {
        var ml = new MainLoop ();

        account_about_test.begin (() => {
            ml.quit ();
        });

        ml.run ();
    });

    return Test.run ();
}
