package hxchart.tests;

import utest.Test;
import utest.Assert;
import hxchart.core.coordinates.TrailCalcs;
import hxchart.core.utils.Point;
import hxchart.core.tick.Tick;
import Math; // For Math.isNaN

class TestTrailCalcs extends Test {
	// Helper to create ticks for tests
	private function createTick(text:String, xVal:Float, yVal:Float):Tick {
		var tick = new Tick();
		tick.text = text;
		tick.middlePos = new Point(xVal, yVal);

		var tempNum:Null<Float> = null;
		if (text != null) {
			// Std.parseFloat can return null if text is "null" (the string) or actual null.
			// It returns NaN for non-numeric strings like "A".
			if (text == "null") { // Std.parseFloat("null") is null
				tempNum = null;
			} else {
				tempNum = Std.parseFloat(text);
			}
		}

		if (tempNum == null || Math.isNaN(tempNum)) {
			tick.num = Math.NaN;
		} else {
			tick.num = tempNum;
		}
		// The original anonymous structure had 'value', TrailCalcs.hx uses 'text' for parsing and 'middlePos'.
		// 'num' is a standard field in Tick.hx assumed by other parts of a larger system.
		return tick;
	}

	public function testTransformValue_basicScaleUp() {
		var result = TrailCalcs.transformValueBetweenTicks(0, 100, 5, 0, 10);
		Assert.equals(50, result);
	}

	public function testTransformValue_scaleDown() {
		var result = TrailCalcs.transformValueBetweenTicks(0, 10, 50, 0, 100);
		Assert.equals(5, result);
	}

	public function testTransformValue_withOffset() {
		var result = TrailCalcs.transformValueBetweenTicks(10, 20, 5, 0, 10);
		Assert.equals(15, result);
	}

	public function testTransformValue_valueAtMin() {
		var result = TrailCalcs.transformValueBetweenTicks(0, 100, 0, 0, 10);
		Assert.equals(0, result);
	}

	public function testTransformValue_valueAtMax() {
		var result = TrailCalcs.transformValueBetweenTicks(0, 100, 10, 0, 10);
		Assert.equals(100, result);
	}

	public function testTransformValue_valueOutsideMax() {
		var result = TrailCalcs.transformValueBetweenTicks(0, 100, 20, 0, 10);
		Assert.equals(200, result);
	}

	public function testTransformValue_valueOutsideMin() {
		var result = TrailCalcs.transformValueBetweenTicks(0, 100, -5, 0, 10);
		Assert.equals(-50, result);
	}

	public function testTransformValue_tickLowEqualsTickHigh() {
		var result = TrailCalcs.transformValueBetweenTicks(50, 50, 5, 0, 10);
		Assert.equals(50, result);
	}

	public function testTransformValue_maxEqualsMin() {
		var result = TrailCalcs.transformValueBetweenTicks(0, 100, 5, 5, 5);
		Assert.isTrue(Math.isNaN(result));
	}

	// --- Tests for calcBarCoordinates ---

	public function testCalcBarCoordinates_useY_basic() {
		var ticks:Array<Tick> = [createTick("0", 0, 10), createTick("50", 0, 60), createTick("100", 0, 110)];
		var result = TrailCalcs.calcBarCoordinates(ticks, 25, 0, true);
		Assert.floatEquals(35, result, 0.001); // Added tolerance for float comparison
	}

	public function testCalcBarCoordinates_useX_basic() {
		var ticks:Array<Tick> = [createTick("0", 10, 0), createTick("50", 60, 0), createTick("100", 110, 0)];
		var result = TrailCalcs.calcBarCoordinates(ticks, 25, 0, false);
		Assert.floatEquals(35, result, 0.001);
	}

	public function testCalcBarCoordinates_valueMatchesTick() {
		var ticks:Array<Tick> = [createTick("0", 0, 10), createTick("50", 0, 60), createTick("100", 0, 110)];
		var result = TrailCalcs.calcBarCoordinates(ticks, 50, 0, true);
		Assert.floatEquals(60, result, 0.001);
	}

	public function testCalcBarCoordinates_valueBelowZero() {
		var ticks:Array<Tick> = [createTick("-50", 0, -40), createTick("0", 0, 10), createTick("50", 0, 60)];
		// Expected: transformValueBetweenTicks(10, 10, -25, 0, 0) which should be NaN
		var result = TrailCalcs.calcBarCoordinates(ticks, -25, 1, true);
		Assert.isTrue(Math.isNaN(result));
	}

	public function testCalcBarCoordinates_differentZeroIndex() {
		var ticks:Array<Tick> = [createTick("50", 0, 60), createTick("100", 0, 110), createTick("150", 0, 160)];
		// Expected: transformValueBetweenTicks(60, 110, 75, 0, 100) = 97.5
		var result = TrailCalcs.calcBarCoordinates(ticks, 75, 0, true);
		Assert.floatEquals(97.5, result, 0.001);
	}

	// --- Tests for calcScatterCoordinates ---

	public function testCalcScatterCoordinates_useY_basic() {
		var ticks:Array<Tick> = [createTick("0", 0, 10), createTick("50", 0, 60), createTick("100", 0, 110)];
		var result = TrailCalcs.calcScatterCoordinates(ticks, 25, true);
		Assert.floatEquals(35, result, 0.001);
	}

	public function testCalcScatterCoordinates_useX_basic() {
		var ticks:Array<Tick> = [createTick("0", 10, 0), createTick("50", 60, 0), createTick("100", 110, 0)];
		var result = TrailCalcs.calcScatterCoordinates(ticks, 25, false);
		Assert.floatEquals(35, result, 0.001);
	}

	public function testCalcScatterCoordinates_valueMatchesTick() {
		var ticks:Array<Tick> = [createTick("0", 0, 10), createTick("50", 0, 60), createTick("100", 0, 110)];
		var result = TrailCalcs.calcScatterCoordinates(ticks, 50, true);
		Assert.floatEquals(60, result, 0.001);
	}

	public function testCalcScatterCoordinates_valueBelowSmallestTick() {
		var ticks:Array<Tick> = [createTick("10", 0, 20), createTick("20", 0, 40)];
		var result = TrailCalcs.calcScatterCoordinates(ticks, 5, true);
		Assert.floatEquals(20, result, 0.001); // Expected: snaps to the first tick's position
	}

	public function testCalcScatterCoordinates_valueBetweenTicks() {
		var ticks:Array<Tick> = [createTick("0", 0, 10), createTick("50", 0, 60), createTick("100", 0, 110)];
		var result = TrailCalcs.calcScatterCoordinates(ticks, 60, true);
		Assert.floatEquals(70, result, 0.001);
	}

	public function testCalcScatterCoordinates_valueAboveAllTicks_ErrorCase() {
		var ticks:Array<Tick> = [createTick("0", 0, 10), createTick("50", 0, 60)];
		Assert.raises(function() {
			TrailCalcs.calcScatterCoordinates(ticks, 75, true);
		});
	}

	public function testCalcScatterCoordinates_maxEqualsMin_valueIsAtTickNotTheFirst() {
		var ticks:Array<Tick> = [createTick("0", 0, 10), createTick("50", 0, 60), createTick("100", 0, 110)];
		var result = TrailCalcs.calcScatterCoordinates(ticks, 0, true);
		Assert.floatEquals(10, result, 0.001); // Snaps to the exact tick's position
	}

	// --- Tests for getCategoricPosFromTick ---

	public function testGetCategoricPosFromTick_found() {
		var ticks:Array<Tick> = [createTick("A", 10, 20), createTick("B", 30, 40), createTick("C", 50, 60)];
		var result = TrailCalcs.getCategoricPosFromTick("B", ticks);
		Assert.notNull(result);
		Assert.floatEquals(30, result.x, 0.001);
		Assert.floatEquals(40, result.y, 0.001);
	}

	public function testGetCategoricPosFromTick_notFound() {
		var ticks:Array<Tick> = [createTick("A", 10, 20), createTick("B", 30, 40), createTick("C", 50, 60)];
		var result = TrailCalcs.getCategoricPosFromTick("D", ticks);
		Assert.isNull(result);
	}

	public function testGetCategoricPosFromTick_emptyTicksArray() {
		var ticks:Array<Tick> = [];
		var result = TrailCalcs.getCategoricPosFromTick("A", ticks);
		Assert.isNull(result);
	}

	public function testGetCategoricPosFromTick_valueIsNull() {
		var ticks:Array<Tick> = [
			createTick("A", 10, 20),
			createTick(null, 30, 40) // Assuming createTick handles null string for text
		];
		var result = TrailCalcs.getCategoricPosFromTick(null, ticks);
		Assert.notNull(result);
		Assert.floatEquals(30, result.x, 0.001);
		Assert.floatEquals(40, result.y, 0.001);
	}
}
