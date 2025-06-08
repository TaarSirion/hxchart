import hxchart.tests.TestBar;
import hxchart.tests.TestUtils;
import hxchart.tests.TestArrayTools;
import hxchart.tests.TestStringTickInfo;
import hxchart.tests.TestNumericTickInfo;
import hxchart.tests.TestLegendInfo;
import hxchart.tests.TestLegend;
import hxchart.tests.TestAxisInfo;
import hxchart.tests.TestAxis;
import hxchart.tests.TestScatter;
import hxchart.tests.TestTrigonometry;
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
		runner.addCase(new TestStringTickInfo());
		runner.addCase(new TestArrayTools());
		runner.addCase(new TestTrigonometry());
		runner.addCase(new TestUtils());
		runner.addCase(new TestBar());
		Report.create(runner);
		runner.run();
		// });
	}
}
