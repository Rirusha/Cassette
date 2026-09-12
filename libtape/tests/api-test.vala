// ind-check=skip-file
// vala-lint=skip-file

using Tape.YaMAPI;

public async void account_about_test () {
    var client = new Client.with_token (TestConfig.TOKEN);
    yield client.init ();
    var about = yield client.account_about ();
    message (about.login);
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
