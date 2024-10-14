import haxe.ui.Toolkit;
import hxchart.tests.TestAxisTools;
import hxchart.tests.TestScatter;
import utest.ui.Report;
import utest.Runner;
// import hxchart.tests.TestAxis;
import hxchart.tests.TestNumericTickInfo;

class TestAll {
	public static function main() {
		var runner = new Runner();
		Toolkit.init();
		runner.addCase(new TestAxisTools());
		runner.addCase(new TestNumericTickInfo());
		runner.addCase(new TestScatter());
		Report.create(runner);
		runner.run();
	}
}
