public int main (string[] args){
    Test.init (ref args);

    Test.add_func ("/utils/ms2sec", () => {
        int res = Utils.ms2sec (432665);
        if (res != 432) {
            Test.fail_printf (res.to_string () + " != 432");
        }
    });

    Test.add_func ("/utils/zfill/bigger", () => {
        string res = Utils.zfill ("111", 5);
        if (res != "00111") {
            Test.fail_printf (res + " != '00111'");
        }
    });

    Test.add_func ("/utils/zfill/eq", () => {
        string res = Utils.zfill ("111", 3);
        if (res != "111") {
            Test.fail_printf (res + " != '111'");
        }
    });

    Test.add_func ("/utils/zfill/lower", () => {
        string res = Utils.zfill ("111", 1);
        if (res != "111") {
            Test.fail_printf (res + " != '111'");
        }
    });

    Test.add_func ("/utils/zfill/neg", () => {
        string res = Utils.zfill ("111", -1);
        if (res != "111") {
            Test.fail_printf (res + " != '111'");
        }
    });

    Test.add_func ("/utils/sec2str/long/w_hours", () => {
        string res = Utils.sec2str (432665, false);
        if (res != "Duration: 120 h. 11 min.") {
            Test.skip_printf (res + " !=" + "Duration: 120 h. 11 min.");
        }
    });

    Test.add_func ("/utils/sec2str/long/wo_hours", () => {
        string res = Utils.sec2str (665, false);
        if (res != _("Duration: 11 min.")) {
            Test.skip_printf (res + " !=" + _("Duration: 11 min."));
        }
    });

    Test.add_func ("/utils/sec2str/short/w_hours", () => {
        string res = Utils.sec2str (432665, true);
        if (res != "7211:05") {
            Test.fail_printf (res + " != '7211:05'");
        }
    });

    Test.add_func ("/utils/sec2str/short/round", () => {
        string res = Utils.sec2str (660, true);
        if (res != "11:00") {
            Test.fail_printf (res + " != '11:00'");
        }
    });

    Test.add_func ("/utils/sec2str/short/zero", () => {
        string res = Utils.sec2str (0, true);
        if (res != "0:00") {
            Test.fail_printf (res + " != '0:00'");
        }
    });

    Test.add_func ("/utils/ms2str/long/w_hours", () => {
        string res = Utils.ms2str (432665546, false);
        if (res != "Duration: 120 h. 11 min.") {
            Test.skip_printf (res + " !=" + "Duration: 120 h. 11 min.");
        }
    });

    Test.add_func ("/utils/ms2str/long/wo_hours", () => {
        string res = Utils.ms2str (665562, false);
        if (res != _("Duration: 11 min.")) {
            Test.skip_printf (res + " !=" + _("Duration: 11 min."));
        }
    });

    Test.add_func ("/utils/ms2str/short/w_hours", () => {
        string res = Utils.ms2str (432665546, true);
        if (res != "7211:05") {
            Test.fail_printf (res + " != '7211:05'");
        }
    });

    Test.add_func ("/utils/ms2str/short/round", () => {
        string res = Utils.ms2str (660000, true);
        if (res != "11:00") {
            Test.fail_printf (res + " != '11:00'");
        }
    });

    Test.add_func ("/utils/ms2str/short/zero", () => {
        string res = Utils.ms2str (0, true);
        if (res != "0:00") {
            Test.fail_printf (res + " != '0:00'");
        }
    });

    Test.add_func ("/utils/snake2kebab/correct", () => {
        string res = Utils.snake2kebab ("test_string_5value");
        if (res != "test-string-5value") {
            Test.fail_printf (res + " != 'test-string-5value'");
        }
    });

    Test.add_func ("/utils/snake2kebab/empty", () => {
        string res = Utils.snake2kebab ("");
        if (res != "") {
            Test.fail_printf (res + " != ''");
        }
    });

    Test.add_func ("/utils/kebab2snake/correct", () => {
        string res = Utils.kebab2snake ("test-string-5value");
        if (res != "test_string_5value") {
            Test.fail_printf (res + " != 'test_string_5value'");
        }
    });

    Test.add_func ("/utils/kebab2snake/empty", () => {
        string res = Utils.kebab2snake ("");
        if (res != "") {
            Test.fail_printf (res + " != ''");
        }
    });

    Test.add_func ("/utils/kebab2camel/correct", () => {
        string res = Utils.kebab2camel ("test-string-5value");
        if (res != "testString5value") {
            Test.fail_printf (res + " != 'testString5value'");
        }
    });

    Test.add_func ("/utils/kebab2camel/empty", () => {
        string res = Utils.kebab2camel ("");
        if (res != "") {
            Test.fail_printf (res + " != ''");
        }
    });

    Test.add_func ("/utils/camel2kebab/correct", () => {
        string res = Utils.camel2kebab ("testString5value");
        if (res != "test-string5value") {
            Test.fail_printf (res + " != 'test-string5value'");
        }
    });

    Test.add_func ("/utils/camel2kebab/empty", () => {
        string res = Utils.camel2kebab ("");
        if (res != "") {
            Test.fail_printf (res + " != ''");
        }
    });

    Test.add_func ("/utils/strip/wo_changed", () => {
        string res = Utils.strip ("kekw", ' ');
        if (res != "kekw") {
            Test.fail_printf (res + " != 'kekw'");
        }
    });

    Test.add_func ("/utils/strip/only_left", () => {
        string res = Utils.strip ("     kekw", ' ');
        if (res != "kekw") {
            Test.fail_printf (res + " != 'kekw'");
        }
    });

    Test.add_func ("/utils/strip/only_right", () => {
        string res = Utils.strip ("kekw     ", ' ');
        if (res != "kekw") {
            Test.fail_printf (res + " != 'kekw'");
        }
    });

    Test.add_func ("/utils/strip/dsides", () => {
        string res = Utils.strip ("   kekw   ", ' ');
        if (res != "kekw") {
            Test.fail_printf (res + " != 'kekw'");
        }
    });

    Test.add_func ("/utils/parse_time/m_s_MS", () => {
        int64 res = Utils.parse_time ("[0:0.24]");
        if (res != 240) {
            Test.fail_printf (res.to_string () + " != 240");
        }
    });

    Test.add_func ("/utils/parse_time/m_s_MS2", () => {
        int64 res = Utils.parse_time ("[0:0.01]");
        if (res != 10) {
            Test.fail_printf (res.to_string () + " != 10");
        }
    });

    Test.add_func ("/utils/parse_time/m_S_MS", () => {
        int64 res = Utils.parse_time ("[0:02.24]");
        if (res != 2240) {
            Test.fail_printf (res.to_string () + " != 2240");
        }
    });

    Test.add_func ("/utils/parse_time/M_S_MS", () => {
        int64 res = Utils.parse_time ("[2:23.24]");
        if (res != 143240) {
            Test.fail_printf (res.to_string () + " != 143240");
        }
    });

    Test.add_func ("/utils/parse_time/M_s_ms", () => {
        int64 res = Utils.parse_time ("[2:00.00]");
        if (res != 120000) {
            Test.fail_printf (res.to_string () + " != 120000");
        }
    });

    Test.add_func ("/utils/range_set/normal", () => {
        var res = Utils.range_set (1, 15, 4);
        if (res.size != 4 || !(1  in res) || !(5 in res) || !(9 in res) || !(13 in res)) {
            Test.fail_printf (">:(");
        }
    });

    Test.add_func ("/utils/range_set/negative", () => {
        var res = Utils.range_set (-5, 15, 5);
        if (res.size != 4 || !(-5 in res) || !(0 in res) || !(5 in res) || !(10 in res)) {
            Test.fail_printf (">:(");
        }
    });

    Test.add_func ("/utils/difference/first", () => {
        var set_1 = Utils.range_set (-5, 15, 5);
        var set_2 = Utils.range_set (-5, 16, 5);

        var res = Utils.difference (set_1, set_2);

        if (res.size != 0) {
            Test.fail_printf (">:(");
        }
    });

    Test.add_func ("/utils/difference/second", () => {
        var set_1 = Utils.range_set (-5, 16, 5);
        var set_2 = Utils.range_set (-5, 15, 5);

        var res = Utils.difference (set_1, set_2);

        if (res.size != 1 || !(15 in res)) {
            Test.fail_printf (">:(");
        }
    });

    Test.add_func ("/utils/difference/both", () => {
        var set_1 = Utils.range_set (-10, 15, 5);
        var set_2 = Utils.range_set (-5, 16, 5);

        var res = Utils.difference (set_1, set_2);

        if (res.size != 1 || 
            !(-10 in res)) {
            Test.fail_printf (">:(");
        }
    });

    Test.add_func ("/utils/difference/none", () => {
        var set_1 = Utils.range_set (-5, 15, 5);
        var set_2 = Utils.range_set (-5, 15, 5);

        var res = Utils.difference (set_1, set_2);

        if (res.size != 0) {
            Test.fail_printf (">:(");
        }
    });

    return Test.run ();
}
