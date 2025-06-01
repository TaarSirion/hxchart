package hxchart.tests;

import utest.Runner;
import utest.ui.Report;
import hxchart.tests.TestCoreScatter;

class RunCoreScatterTest {
    public static function main() {
        var runner = new Runner();
        runner.addCase(new TestCoreScatter());
        Report.create(runner); // Use default command line report
        runner.run();
    }
}
