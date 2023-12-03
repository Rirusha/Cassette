using Cassette;

public int main (string[] args){
    Test.init (ref args);

    Test.add_func ("/logger/init", () => {
        new Logger ("test.log", LogLevel.DEBUG);
    });

    return Test.run ();
}
