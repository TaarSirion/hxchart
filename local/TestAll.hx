import hxchart.tests.TestStatistics;
import haxe.ui.Toolkit;
import hxchart.tests.TestAxisTools;
import hxchart.tests.TestScatter;
import hxchart.tests.TestLegend;
import hxchart.tests.TestChart;
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
		runner.addCase(new TestLegend());
		runner.addCase(new TestChart());
		runner.addCase(new TestStatistics());
		Report.create(runner);
		runner.run();
	}
}
