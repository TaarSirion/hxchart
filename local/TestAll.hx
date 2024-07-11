import hxchart.tests.TestPoint;
import utest.ui.Report;
import utest.Runner;
import hxchart.tests.TestChart;
// import hxchart.tests.TestAxis;
import hxchart.tests.TestNumericTickInfo;

class TestAll {
	public static function main() {
		var runner = new Runner();

		runner.addCase(new TestChart());
		// runner.addCase(new TestAxis());
		runner.addCase(new TestPoint());
		runner.addCase(new TestNumericTickInfo());
		Report.create(runner);
		runner.run();
	}
}
