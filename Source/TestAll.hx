import tests.TestPoint;
import utest.ui.Report;
import utest.Runner;
import tests.TestChart;

class TestAll {
	public static function main() {
		var runner = new Runner();
		runner.addCase(new TestChart());
		runner.addCase(new TestPoint());
		Report.create(runner);
		runner.run();
	}
}
