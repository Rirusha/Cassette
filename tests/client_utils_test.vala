using CassetteClient;


public int main (string[] args){
    Test.init (ref args);

    Test.add_func ("/utils/snake2kebab/correct", () => {
        string res = snake2kebab ("test_string_5value");
        if (res != "test-string-5value") {
            Test.fail_printf (res + " != 'test-string-5value'");
        }
    });

    Test.add_func ("/utils/snake2kebab/empty", () => {
        string res = snake2kebab ("");
        if (res != "") {
            Test.fail_printf (res + " != ''");
        }
    });

    Test.add_func ("/utils/kebab2snake/correct", () => {
        string res = kebab2snake ("test-string-5value");
        if (res != "test_string_5value") {
            Test.fail_printf (res + " != 'test_string_5value'");
        }
    });

    Test.add_func ("/utils/kebab2snake/empty", () => {
        string res = kebab2snake ("");
        if (res != "") {
            Test.fail_printf (res + " != ''");
        }
    });

    Test.add_func ("/utils/kebab2camel/correct", () => {
        string res = kebab2camel ("test-string-5value");
        if (res != "testString5value") {
            Test.fail_printf (res + " != 'testString5value'");
        }
    });

    Test.add_func ("/utils/kebab2camel/empty", () => {
        string res = kebab2camel ("");
        if (res != "") {
            Test.fail_printf (res + " != ''");
        }
    });

    Test.add_func ("/utils/camel2kebab/correct", () => {
        string res = camel2kebab ("testString5value");
        if (res != "test-string5value") {
            Test.fail_printf (res + " != 'test-string5value'");
        }
    });

    Test.add_func ("/utils/camel2kebab/empty", () => {
        string res = camel2kebab ("");
        if (res != "") {
            Test.fail_printf (res + " != ''");
        }
    });

    Test.add_func ("/utils/strip/wo_changed", () => {
        string res = strip ("kekw", ' ');
        if (res != "kekw") {
            Test.fail_printf (res + " != 'kekw'");
        }
    });

    Test.add_func ("/utils/strip/only_left", () => {
        string res = strip ("     kekw", ' ');
        if (res != "kekw") {
            Test.fail_printf (res + " != 'kekw'");
        }
    });

    Test.add_func ("/utils/strip/only_right", () => {
        string res = strip ("kekw     ", ' ');
        if (res != "kekw") {
            Test.fail_printf (res + " != 'kekw'");
        }
    });

    Test.add_func ("/utils/strip/dsides", () => {
        string res = strip ("   kekw   ", ' ');
        if (res != "kekw") {
            Test.fail_printf (res + " != 'kekw'");
        }
    });

    return Test.run ();
}
