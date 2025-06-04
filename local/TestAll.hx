import hxchart.tests.TestNumericTickInfo;
import hxchart.tests.TestLegendInfo;
import hxchart.tests.TestLegend;
import hxchart.tests.TestAxisInfo;
import hxchart.tests.TestAxis;
import hxchart.tests.TestScatter;
import utest.ui.Report;
import utest.Runner;

class TestAll {
	public static function main() {
		var runner = new Runner();
		runner.addCase(new TestScatter());
		runner.addCase(new TestAxisInfo());
		runner.addCase(new TestAxis());
		runner.addCase(new TestLegend());
		runner.addCase(new TestLegendInfo());
		runner.addCase(new TestNumericTickInfo());
		Report.create(runner);
		runner.run();
		// });
	}
}
