package hxchart.tests;

import hxchart.core.utils.Point;
import hxchart.core.utils.CompassOrientation;
import utest.Assert;
import utest.Test;
// Core imports
import hxchart.core.axis.Axis;
import hxchart.core.axis.AxisInfo;
import hxchart.core.axis.AxisTypes;
import hxchart.core.axis.AxisTitle;
import hxchart.core.coordinates.CoordinateSystem;
import hxchart.core.tickinfo.NumericTickInfo;
import hxchart.core.tickinfo.StringTickInfo;

class TestAxis extends Test {
	private function createNumericTickInfo(min:Float, max:Float):NumericTickInfo {
		return new NumericTickInfo(["min" => [min], "max" => [max]]);
	}

	private function createStringTickInfo(labels:Array<String>):StringTickInfo {
		return new StringTickInfo(labels);
	}

	function testCorePosition_BasicNoTitles_Horizontal() {
		var cs = new CoordinateSystem();
		cs.start = new Point(0, 0);
		cs.end = new Point(200, 150);

		var axisInfoX:AxisInfo = {
			id: "x-axis",
			rotation: 0,
			tickMargin: 10,
			tickInfo: createNumericTickInfo(0, 10), // Assumed: tickNum=11, zeroIndex=0
			type: AxisTypes.linear
		};

		var axes:Array<AxisInfo> = [axisInfoX];
		var axis = new Axis(axes, cs);
		axis.positionStartPoint();

		Assert.equals(10, axis.zeroPoint.x); // (0 * 200 / 10) + 0 + 10 = 10
		Assert.equals(75, axis.zeroPoint.y); // cs.height / 2 = 75

		Assert.equals(0, axisInfoX.start.x); // cs.left
		Assert.equals(75, axisInfoX.start.y); // zeroPoint.y
		Assert.equals(200, axisInfoX.length); // cs.width
		Assert.notNull(axisInfoX.end);
		if (axisInfoX.end != null) {
			Assert.equals(200, axisInfoX.end.x); // start.x + length
			Assert.equals(75, axisInfoX.end.y); // start.y
		}
	}

	function testCorePosition_HorizontalWithTitle_ZeroImpacted() {
		var cs = new CoordinateSystem();
		cs.start = new Point(0, 0);
		cs.end = new Point(200, 150);

		var titleX:AxisTitle = {text: "X-Axis Title"};
		var axisInfoX:AxisInfo = {
			id: "x-axis",
			rotation: 0,
			tickMargin: 10,
			tickInfo: createNumericTickInfo(0, 100), // zeroIndex=0, tickNum=11
			type: AxisTypes.linear,
			title: titleX
		};

		var axisInfoY:AxisInfo = {
			id: "y-axis",
			rotation: 90,
			tickMargin: 5,
			tickInfo: createNumericTickInfo(0, 50), // zeroIndex=0, tickNum=11
			type: AxisTypes.linear
		};

		var axes:Array<AxisInfo> = [axisInfoX, axisInfoY];
		var axis = new Axis(axes, cs);
		axis.positionStartPoint();

		// X-axis (axisInfoX): zeroIndex=0. zp.x = (0*200/10)+0+10 = 10
		// Y-axis (axisInfoY): zeroIndex=0. zp.y = (0*150/10)+0+5 = 5
		// Title for X-axis: zeroPoint.y (5) <= cs.bottom (0) + 12 + margin. So newHeight = 150-12=138. zeroPoint.y becomes 22.
		Assert.equals(10, axis.zeroPoint.x);
		Assert.equals(22, axis.zeroPoint.y);

		// axisInfoX: zeroPoint.y was changed by title, so start.x = zp.x - margin = 10 - 10 = 0 (ERROR in original prompt, should be zp.x - margin)
		// The prompt implies start.x should be cs.left if length!=newWidth, but here length *is* newWidth (implicitly, as it's not changed if title is on other axis)
		// Original logic: if (info.length != newWidth) { info.start.x = zeroPoint.x - info.tickMargin; } else { info.start.x = coordSystem.left; }
		// Here, newWidth = cs.width (200). info.length for X is cs.width (200). So start.x = cs.left = 0.
		Assert.equals(0, axisInfoX.start.x); // cs.left
		Assert.equals(22, axisInfoX.start.y); // zeroPoint.y
		Assert.equals(200, axisInfoX.length); // cs.width (newWidth not affected by X title)

		// axisInfoY: zeroPoint.y was changed by X-axis title, so start.y = zp.y = 12
		// length is newHeight = 138
		Assert.equals(10, axisInfoY.start.x); // zeroPoint.x
		Assert.equals(12, axisInfoY.start.y);
		Assert.equals(138, axisInfoY.length);
	}

	function testCorePosition_HorizontalWithTitle_ZeroNotImpactedButSpaceTaken() {
		var cs = new CoordinateSystem();
		cs.start = new Point(0, 0);
		cs.end = new Point(200, 150);

		var titleX:AxisTitle = {text: "X-Axis Title"};
		var axisInfoX:AxisInfo = {
			id: "x-axis",
			rotation: 0,
			tickMargin: 10,
			tickInfo: createNumericTickInfo(0, 100), // zeroIndex=0, tickNum=11
			type: AxisTypes.linear,
			title: titleX
		};

		var axisInfoY_highZero:AxisInfo = {
			id: "y-high",
			rotation: 90,
			tickMargin: 5,
			// NumericTickInfo(["min"=>[-50.], "max"=>[50.]]) -> tickNum=11, zeroIndex=5
			tickInfo: new NumericTickInfo(["min" => [-50.], "max" => [50.]]),
			type: AxisTypes.linear
		};

		var axes:Array<AxisInfo> = [axisInfoX, axisInfoY_highZero];
		var axis = new Axis(axes, cs);
		axis.positionStartPoint();

		// X-axis (axisInfoX): zeroIndex=0. zp.x = (0*200/10)+0+10 = 10
		// Y-axis (axisInfoY_highZero): zeroIndex=5. zp.y = (5*150/10)+0+5 = 75+5 = 80
		// Title for X-axis: zeroPoint.y (80) > cs.bottom (0) + 12. So newHeight not changed by title. zeroPoint.y remains 80.
		Assert.equals(10, axis.zeroPoint.x);
		Assert.equals(80, axis.zeroPoint.y);

		// axisInfoX: newHeight not changed. start.x = cs.left = 0. length = cs.width = 200
		Assert.equals(0, axisInfoX.start.x);
		Assert.equals(80, axisInfoX.start.y);
		Assert.equals(200, axisInfoX.length);

		// axisInfoY_highZero: newHeight not changed. start.y = cs.bottom = 0. length = cs.height = 150
		Assert.equals(10, axisInfoY_highZero.start.x);
		Assert.equals(0, axisInfoY_highZero.start.y);
		Assert.equals(150, axisInfoY_highZero.length);
	}

	function testCorePosition_StringTicksHorizontal() {
		var cs = new CoordinateSystem();
		cs.start = new Point(0, 0);
		cs.end = new Point(220, 100);

		var strLabels = ["A", "B", "C", "D"]; // tickNum=4, zeroIndex=0 (implicit)
		var axisInfoX:AxisInfo = {
			id: "x-str-axis",
			rotation: 0,
			tickMargin: 10,
			tickInfo: createStringTickInfo(strLabels),
			type: AxisTypes.categorical
		};
		var axes:Array<AxisInfo> = [axisInfoX];
		var axis = new Axis(axes, cs);
		axis.positionStartPoint();

		// StringInfo: tickNum=4, zeroIndex=0. Divisor = 3.
		// zp.x = (0 * 220 / 3) + 0 + 10 = 10. zp.y = 100/2 = 50.
		Assert.equals(10, Math.round(axis.zeroPoint.x)); // Original logic used tickNum-1 as divisor for StringTickInfo too
		Assert.equals(50, axis.zeroPoint.y);

		Assert.equals(0, axisInfoX.start.x); // cs.left
		Assert.equals(50, axisInfoX.start.y); // zeroPoint.y
		Assert.equals(220, axisInfoX.length); // cs.width
	}

	function testCorePosition_SmallDimensions_LengthClamped() {
		var cs = new CoordinateSystem();
		cs.start = new Point(0, 0);
		cs.end = new Point(30, 20);

		var axisInfoX:AxisInfo = {
			id: "x-small",
			rotation: 0,
			tickMargin: 20,
			tickInfo: createNumericTickInfo(0, 1), // tickNum=2, zeroIndex=0
			type: AxisTypes.linear
		};
		var axes:Array<AxisInfo> = [axisInfoX];
		var axis = new Axis(axes, cs);
		axis.positionStartPoint();
		// zp.x = (0*30/1) + 0 + 20 = 20. zp.y = 20/2 = 10
		Assert.equals(20, axis.zeroPoint.x);
		Assert.equals(10, axis.zeroPoint.y);
		// start.x = cs.left = 0. length = cs.width = 30
		Assert.equals(0, axisInfoX.start.x);
		Assert.equals(10, axisInfoX.start.y);
		Assert.equals(30, axisInfoX.length); // Original does not clamp in positionStartPoint
	}

	function testCorePosition_VerticalWithSubtitle_ZeroImpacted() {
		var cs = new CoordinateSystem();
		cs.start = new Point(0, 0);
		cs.end = new Point(200, 150);

		var subtitleY:AxisTitle = {text: "Y-Axis Subtitle"};
		var axisInfoY:AxisInfo = {
			id: "y-axis",
			rotation: 90,
			tickMargin: 5,
			tickInfo: createNumericTickInfo(0, 50), // zeroIndex=0, tickNum=11
			type: AxisTypes.linear,
			subTitle: subtitleY
		};

		var axisInfoX:AxisInfo = {
			id: "x-axis",
			rotation: 0,
			tickMargin: 10,
			tickInfo: createNumericTickInfo(0, 100), // zeroIndex=0, tickNum=11
			type: AxisTypes.linear
		};

		var axes:Array<AxisInfo> = [axisInfoX, axisInfoY];
		var axis = new Axis(axes, cs);
		axis.positionStartPoint();

		// X-axis (axisInfoX): zeroIndex=0. zp.x = (0*200/10)+0+10 = 10
		// Y-axis (axisInfoY): zeroIndex=0. zp.y = (0*150/10)+0+5 = 5
		// As no title is present for
		Assert.equals(10, axis.zeroPoint.x);
		Assert.equals(5, axis.zeroPoint.y);

		// axisInfoY: newWidth was changed by Y-axis subtitle. start.x = zp.x = 20. length = cs.height = 150
		Assert.equals(10, axisInfoY.start.x);
		Assert.equals(0, axisInfoY.start.y); // cs.bottom
		Assert.equals(150, axisInfoY.length); // cs.height

		// axisInfoX: newWidth was changed by Y-axis subtitle. start.x = zp.x = 20
		// length = newWidth = 180
		Assert.equals(0, axisInfoX.start.x);
		Assert.equals(5, axisInfoX.start.y);
		Assert.equals(200, axisInfoX.length);
	}

	function testSetTicks_NumericHorizontal_InitialCreation() {
		// 1. Setup CoordinateSystem
		var cs = new CoordinateSystem();
		cs.start = new Point(0, 0);
		cs.end = new Point(200, 150);

		// 2. Create AxisInfo
		var numericTickInfo = createNumericTickInfo(0, 4); // Creates 5 ticks: 0, 1, 2, 3, 4
		var axisInfoX:AxisInfo = {
			id: "x-axis-numeric",
			rotation: 0,
			tickMargin: 10,
			tickInfo: numericTickInfo,
			type: AxisTypes.linear,
			showZeroTick: true // Explicitly true
		};

		var axes:Array<AxisInfo> = [axisInfoX];

		// 3. Create Axis
		var axis = new Axis(axes, cs);

		// 4. Call positionStartPoint
		axis.positionStartPoint();
		// From testCorePosition_BasicNoTitles_Horizontal:
		// axisInfoX.start.x should be 0
		// axisInfoX.start.y should be 75 (cs.height / 2)
		// axisInfoX.length should be 200 (cs.width)
		// axisInfoX.tickMargin is 10

		// 5. Call setTicks(false)
		axis.setTicks(false);

		// 6. Assertions
		Assert.equals(1, axis.ticksPerInfo.length, "Should be one entry for one AxisInfo");
		var ticks = axis.ticksPerInfo[0];
		Assert.equals(5, ticks.length, "Should create 5 ticks for values 0, 1, 2, 3, 4");

		var expectedTickPosStep = (axisInfoX.length - 2 * axisInfoX.tickMargin) / (numericTickInfo.tickNum - 1); // (200 - 2*10) / 4 = 180 / 4 = 45

		for (i in 0...ticks.length) {
			var tick = ticks[i];
			Assert.isFalse(tick.isSub, "Ticks should not be sub-ticks by default");
			Assert.equals(90, tick.tickRotation % 180, "Tick rotation should be vertical for horizontal axis"); // tickRotation is axisRotation + 90
			Assert.isTrue(tick.showLabel, "Labels should be shown by default");
			Assert.equals(CompassOrientation.S, tick.labelPosition, "Label position for horizontal axis should be South");
			Assert.isFalse(tick.hidden, "Tick " + i + " should not be hidden by default");
			Assert.equals(Std.string(i), tick.text, "Tick " + i + " text should be its value");

			var expectedX = axisInfoX.start.x + axisInfoX.tickMargin + i * expectedTickPosStep;
			var expectedY = axisInfoX.start.y;
			Assert.floatEquals(expectedX, tick.middlePos.x, 0.001, "Tick " + i + " X position");
			Assert.floatEquals(expectedY, tick.middlePos.y, 0.001, "Tick " + i + " Y position");
		}
	}

	function testSetTicks_NumericVertical_InitialCreation() {
		// 1. Setup CoordinateSystem
		var cs = new CoordinateSystem();
		cs.start = new Point(0, 0);
		cs.end = new Point(200, 150);

		// 2. Create AxisInfo
		var numericTickInfo = createNumericTickInfo(0, 3); // Creates 4 ticks: 0, 1, 2, 3
		var axisInfoY:AxisInfo = {
			id: "y-axis-numeric",
			rotation: 90, // Vertical axis
			tickMargin: 5,
			tickInfo: numericTickInfo,
			type: AxisTypes.linear,
			showZeroTick: true
		};

		var axes:Array<AxisInfo> = [axisInfoY];

		// 3. Create Axis
		var axis = new Axis(axes, cs);

		// 4. Call positionStartPoint
		axis.positionStartPoint();
		// Based on how positionStartPoint works:
		// axisInfoY.start.x should be cs.width / 2 = 100
		// axisInfoY.start.y should be 0 (cs.bottom)
		// axisInfoY.length should be cs.height = 150
		// axisInfoY.tickMargin is 5

		// 5. Call setTicks(false)
		axis.setTicks(false);

		// 6. Assertions
		Assert.equals(1, axis.ticksPerInfo.length, "Should be one entry for one AxisInfo");
		var ticks = axis.ticksPerInfo[0];
		Assert.equals(4, ticks.length, "Should create 4 ticks for values 0, 1, 2, 3");

		// tickPos = (info.length - 2 * info.tickMargin) / (tickNum - 1);
		var expectedTickPosStep = (axisInfoY.length - 2 * axisInfoY.tickMargin) / (numericTickInfo.tickNum - 1); // (150 - 2*5) / 3 = 140 / 3

		for (i in 0...ticks.length) {
			var tick = ticks[i];
			Assert.isFalse(tick.isSub);
			Assert.equals(0, tick.tickRotation % 180, "Tick rotation should be horizontal for vertical axis"); // tickRotation is axisRotation + 90
			Assert.isTrue(tick.showLabel);
			Assert.equals(CompassOrientation.W, tick.labelPosition, "Label position for vertical axis should be West");
			Assert.isFalse(tick.hidden, "Tick " + i + " should not be hidden");
			Assert.equals(Std.string(i), tick.text, "Tick " + i + " text should be its value");

			// For vertical axis (rotation 90), positionEndpoint calculates Y increasing from start.y
			var expectedX = axisInfoY.start.x;
			var expectedY = axisInfoY.start.y + axisInfoY.tickMargin + i * expectedTickPosStep;
			Assert.floatEquals(expectedX, tick.middlePos.x, 0.001, "Tick " + i + " X position");
			Assert.floatEquals(expectedY, tick.middlePos.y, 0.001, "Tick " + i + " Y position");
		}
	}

	function testSetTicks_StringHorizontal_InitialCreation() {
		// 1. Setup CoordinateSystem
		var cs = new CoordinateSystem();
		cs.start = new Point(0, 0);
		cs.end = new Point(250, 150);

		// 2. Create AxisInfo
		var labels = ["Apple", "Banana", "Cherry"]; // tickNum will be 3 initially
		var stringTickInfo = createStringTickInfo(labels);
		var axisInfoX:AxisInfo = {
			id: "x-axis-string",
			rotation: 0,
			tickMargin: 15,
			tickInfo: stringTickInfo,
			type: AxisTypes.categorical, // Typically for string/categorical data
			showZeroTick: true // Does not apply directly to StringTickInfo in the same way as Numeric
		};

		var axes:Array<AxisInfo> = [axisInfoX];

		// 3. Create Axis
		var axis = new Axis(axes, cs);

		// 4. Call positionStartPoint
		axis.positionStartPoint();
		// axisInfoX.start.x = 0
		// axisInfoX.start.y = 75 (cs.height / 2)
		// axisInfoX.length = 250
		// axisInfoX.tickMargin = 15
		// stringTickInfo.tickNum is 3 (length of labels)

		// 5. Call setTicks(false)
		axis.setTicks(false);

		// 6. Assertions
		Assert.equals(1, axis.ticksPerInfo.length);
		var ticks = axis.ticksPerInfo[0];
		Assert.equals(stringTickInfo.tickNum, ticks.length, "Should create ticks based on number of labels"); // Will be 3

		// In setTicks: if (Std.isOfType(tickInfo, StringTickInfo)) { tickNum++; }
		// So, for calculation, effectiveTickNum = stringTickInfo.tickNum + 1 = 4
		var effectiveTickNumForCalc = stringTickInfo.tickNum + 1;
		var expectedTickPosStep = (axisInfoX.length - 2 * axisInfoX.tickMargin) / (effectiveTickNumForCalc - 1);
		// (250 - 2*15) / (4 - 1) = (250 - 30) / 3 = 220 / 3

		for (i in 0...ticks.length) {
			var tick = ticks[i];
			Assert.isFalse(tick.isSub);
			Assert.equals(90, tick.tickRotation % 180);
			Assert.isTrue(tick.showLabel);
			Assert.equals(CompassOrientation.S, tick.labelPosition);
			Assert.isFalse(tick.hidden);

			if (i != 0) {
				// The first label is always empty
				Assert.equals(labels[i - 1], tick.text, "Tick " + i + " text should match label");
			} else {
				Assert.equals("", tick.text, "Tick 0 text should be empty");
			}
			var expectedX = axisInfoX.start.x + axisInfoX.tickMargin + i * expectedTickPosStep;
			var expectedY = axisInfoX.start.y;
			Assert.floatEquals(expectedX, tick.middlePos.x, 0.001, "Tick " + i + " X position");
			Assert.floatEquals(expectedY, tick.middlePos.y, 0.001, "Tick " + i + " Y position");
		}
	}

	function testSetTicks_Numeric_HideZeroTick() {
		// 1. Setup CoordinateSystem
		var cs = new CoordinateSystem();
		cs.start = new Point(0, 0);
		cs.end = new Point(200, 150);

		// 2. Create AxisInfo
		// Ticks: -2, -1, 0, 1, 2. So tickNum = 5. zeroIndex should be 2.
		var numericTickInfo = createNumericTickInfo(-2, 2);
		var axisInfoX:AxisInfo = {
			id: "x-axis-hide-zero",
			rotation: 0,
			tickMargin: 10,
			tickInfo: numericTickInfo,
			type: AxisTypes.linear,
			showZeroTick: false // Key setting for this test
		};

		var axes:Array<AxisInfo> = [axisInfoX];

		// 3. Create Axis
		var axis = new Axis(axes, cs);

		// 4. Call positionStartPoint
		axis.positionStartPoint();
		// numericTickInfo.tickNum = 5
		// numericTickInfo.zeroIndex = 2 (for values -2, -1, 0, 1, 2)

		// 5. Call setTicks(false)
		axis.setTicks(false);

		// 6. Assertions
		Assert.equals(1, axis.ticksPerInfo.length);
		var ticks = axis.ticksPerInfo[0];
		Assert.equals(5, ticks.length, "Should create 5 ticks");

		var zeroTickIndex = numericTickInfo.zeroIndex; // Should be 2

		for (i in 0...ticks.length) {
			var tick = ticks[i];
			if (i == zeroTickIndex) {
				Assert.isTrue(tick.hidden, "Tick at zeroIndex (" + zeroTickIndex + ") should be hidden");
			} else {
				Assert.isFalse(tick.hidden, "Tick " + i + " should not be hidden");
			}
			// Other assertions like position, text could be added but hidden is the focus
			Assert.equals(Std.string(numericTickInfo.labels[i]), tick.text); // labels are "-2", "-1", "0", "1", "2"
		}
	}

	function testSetTicks_NumericHorizontal_UpdateTicks() {
		// 1. Setup CoordinateSystem
		var cs = new CoordinateSystem();
		cs.start = new Point(0, 0);
		cs.end = new Point(200, 150);

		// 2. Create AxisInfo
		var numericTickInfo = createNumericTickInfo(0, 4); // 5 ticks: 0, 1, 2, 3, 4
		var axisInfoX:AxisInfo = {
			id: "x-axis-update",
			rotation: 0,
			tickMargin: 10, // Initial tickMargin
			tickInfo: numericTickInfo,
			type: AxisTypes.linear,
			showZeroTick: true
		};

		var axes:Array<AxisInfo> = [axisInfoX];
		var axis = new Axis(axes, cs);

		// 3. Initial setup
		axis.positionStartPoint();
		axis.setTicks(false); // Create initial ticks

		// Store references to original ticks to check they are updated
		var originalTicks = [for (tick in axis.ticksPerInfo[0]) tick];
		Assert.equals(5, originalTicks.length);

		// 4. Modify AxisInfo property that affects tick positions
		axisInfoX.tickMargin = 20; // Change tickMargin
		// Note: positionStartPoint() is NOT called again, setTicks should use the current axisInfoX.start etc.
		// but recalculate tick positions based on the new tickMargin.

		// 5. Call setTicks(true) to update
		axis.setTicks(true);

		// 6. Assertions
		Assert.equals(1, axis.ticksPerInfo.length, "Should still be one entry for one AxisInfo");
		var updatedTicks = axis.ticksPerInfo[0];
		Assert.equals(5, updatedTicks.length, "Number of ticks should remain the same");

		// Check that the tick objects themselves are the same instances
		for (i in 0...originalTicks.length) {
			Assert.isTrue(originalTicks[i] == updatedTicks[i], "Tick object instance " + i + " should be the same");
		}

		// Recalculate expected positions with the new tickMargin
		var expectedTickPosStep = (axisInfoX.length - 2 * axisInfoX.tickMargin) / (numericTickInfo.tickNum - 1);
		// (200 - 2*20) / 4 = (200 - 40) / 4 = 160 / 4 = 40

		for (i in 0...updatedTicks.length) {
			var tick = updatedTicks[i];
			Assert.isFalse(tick.hidden); // Assuming no other changes to hide them
			Assert.equals(Std.string(i), tick.text); // Text should remain

			var expectedX = axisInfoX.start.x + axisInfoX.tickMargin + i * expectedTickPosStep;
			var expectedY = axisInfoX.start.y; // Y remains same as start.y from initial positionStartPoint

			Assert.floatEquals(expectedX, tick.middlePos.x, 0.001, "Updated Tick " + i + " X position");
			Assert.floatEquals(expectedY, tick.middlePos.y, 0.001, "Updated Tick " + i + " Y position");
		}
	}

	function testSetTicks_Numeric_MinimumTicks() {
		// 1. Setup CoordinateSystem
		var cs = new CoordinateSystem();
		cs.start = new Point(0, 0);
		cs.end = new Point(200, 150);

		// 2. Create AxisInfo
		// createNumericTickInfo(0,1) will result in tickNum = 2 (ticks for 0 and 1)
		// labels will be ["0", "1"]
		var numericTickInfo = createNumericTickInfo(0, 1);
		Assert.equals(2, numericTickInfo.tickNum, "Confirming tickNum for 0-1 range");

		var axisInfoX:AxisInfo = {
			id: "x-axis-min-ticks",
			rotation: 0,
			tickMargin: 10,
			tickInfo: numericTickInfo,
			type: AxisTypes.linear,
			showZeroTick: true
		};

		var axes:Array<AxisInfo> = [axisInfoX];
		var axis = new Axis(axes, cs);
		axis.positionStartPoint(); // Sets up axisInfoX.start, axisInfoX.length

		// 5. Call setTicks(false)
		axis.setTicks(false);

		// 6. Assertions
		Assert.equals(1, axis.ticksPerInfo.length);
		var ticks = axis.ticksPerInfo[0];
		Assert.equals(2, ticks.length, "Should create 2 ticks");

		// tickPos = (info.length - 2 * info.tickMargin) / (tickNum - 1);
		// (200 - 2*10) / (2 - 1) = 180 / 1 = 180
		var expectedTickPosStep = (axisInfoX.length - 2 * axisInfoX.tickMargin) / (numericTickInfo.tickNum - 1);
		Assert.floatEquals(180.0, expectedTickPosStep, 0.001);

		// Tick 0 (label "0")
		var tick0 = ticks[0];
		Assert.equals("0", tick0.text);
		var expectedX0 = axisInfoX.start.x + axisInfoX.tickMargin + 0 * expectedTickPosStep;
		Assert.floatEquals(expectedX0, tick0.middlePos.x, 0.001, "Tick 0 X position");
		Assert.floatEquals(axisInfoX.start.y, tick0.middlePos.y, 0.001, "Tick 0 Y position");

		// Tick 1 (label "1")
		var tick1 = ticks[1];
		Assert.equals("1", tick1.text);
		var expectedX1 = axisInfoX.start.x + axisInfoX.tickMargin + 1 * expectedTickPosStep;
		Assert.floatEquals(expectedX1, tick1.middlePos.x, 0.001, "Tick 1 X position");
		Assert.floatEquals(axisInfoX.start.y, tick1.middlePos.y, 0.001, "Tick 1 Y position");
	}

	function testSetTicks_Numeric_LargeMargins() {
		// 1. Setup CoordinateSystem
		var cs = new CoordinateSystem();
		cs.start = new Point(0, 0);
		cs.end = new Point(200, 150);

		// 2. Create AxisInfo
		var numericTickInfo = createNumericTickInfo(0, 2); // 3 Ticks: 0, 1, 2. tickNum = 3
		var axisInfoX:AxisInfo = {
			id: "x-axis-large-margins",
			rotation: 0,
			// Margins combined (80*2=160) leave 40 for tick distribution space (length - 2*margin)
			tickMargin: 80,
			tickInfo: numericTickInfo,
			type: AxisTypes.linear,
			showZeroTick: true
		};

		var axes:Array<AxisInfo> = [axisInfoX];
		var axis = new Axis(axes, cs);
		axis.positionStartPoint();

		// 5. Call setTicks(false)
		axis.setTicks(false);

		// 6. Assertions
		Assert.equals(1, axis.ticksPerInfo.length);
		var ticks = axis.ticksPerInfo[0];
		Assert.equals(3, ticks.length, "Should create 3 ticks");

		// tickPos = (axisInfoX.length - 2 * axisInfoX.tickMargin) / (numericTickInfo.tickNum - 1);
		// (200 - 2*80) / (3 - 1) = (200 - 160) / 2 = 40 / 2 = 20
		var expectedTickPosStep = (axisInfoX.length - 2 * axisInfoX.tickMargin) / (numericTickInfo.tickNum - 1);
		Assert.floatEquals(20.0, expectedTickPosStep, 0.001);

		for (i in 0...ticks.length) {
			var tick = ticks[i];
			var expectedX = axisInfoX.start.x + axisInfoX.tickMargin + i * expectedTickPosStep;
			Assert.floatEquals(expectedX, tick.middlePos.x, 0.001, "Tick " + i + " X position");
			Assert.floatEquals(axisInfoX.start.y, tick.middlePos.y, 0.001, "Tick " + i + " Y position");
		}
	}
}
