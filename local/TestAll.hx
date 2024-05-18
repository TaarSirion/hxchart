import hxchart.tests.TestPoint;
import utest.ui.Report;
import utest.Runner;
import hxchart.tests.TestChart;
import hxchart.tests.TestAxis;

class TestAll {
	public static function main() {
		var runner = new Runner();

		runner.addCase(new TestChart());
		runner.addCase(new TestAxis());
		runner.addCase(new TestPoint());
		Report.create(runner);
		runner.run();
	}
}
