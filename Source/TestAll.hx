import utest.ui.Report;
import utest.Runner;
import tests.TestChart;

class TestAll {
	public static function main() {
		var runner = new Runner();
		runner.addCase(new TestChart());
		Report.create(runner);
		runner.run();
	}
}
