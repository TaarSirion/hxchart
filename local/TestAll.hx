// import hxchart.tests.TestAxis; // Commented out
// import hxchart.tests.TestDataLayer; // Commented out
// import hxchart.tests.TestUtils; // Commented out
import haxe.ui.HaxeUIApp;
// import hxchart.tests.TestStatistics; // Commented out
import haxe.ui.Toolkit;
// import hxchart.tests.TestAxisTools; // Commented out
// import hxchart.tests.TestScatter; // Commented out
// import hxchart.tests.TestLegend; // Commented out
// import hxchart.tests.TestChart; // Commented out
import utest.ui.Report;
import utest.Runner;
// import hxchart.tests.TestAxis; // Already commented
// import hxchart.tests.TestNumericTickInfo; // Commented out
import hxchart.tests.TestCoreScatter; // Keep this one

class TestAll {
	public static function main() {
		var runner = new Runner();
		Toolkit.init();
		var app = new HaxeUIApp();
		app.ready(function() {
			app.start();
			// runner.addCase(new TestAxisTools());
			// runner.addCase(new TestNumericTickInfo());
			// runner.addCase(new TestScatter());
			// runner.addCase(new TestLegend());
			// runner.addCase(new TestChart());
			// runner.addCase(new TestStatistics());
			// runner.addCase(new TestDataLayer());
			// runner.addCase(new TestUtils());
			// runner.addCase(new TestAxis());
			runner.addCase(new TestCoreScatter()); // Run only the new test
			Report.create(runner);
			runner.run();
		});
	}
}
