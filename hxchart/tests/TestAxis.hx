package hxchart.tests;

import utest.Assert;
import utest.Test;
// Core imports
import hxchart.core.axis.Axis;
import hxchart.core.axis.AxisInfo;
import hxchart.core.axis.AxisTypes;
import hxchart.core.axis.AxisTitle;
import hxchart.core.utils.CoordinateSystem;
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
		cs.left = 0;
		cs.bottom = 0;
		cs.width = 200;
		cs.height = 150;

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
		cs.left = 0;
		cs.bottom = 0;
		cs.width = 200;
		cs.height = 150;

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
		cs.left = 0;
		cs.bottom = 0;
		cs.width = 200;
		cs.height = 150;

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
		cs.left = 0;
		cs.bottom = 0;
		cs.width = 220;
		cs.height = 100;
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
		cs.left = 0;
		cs.bottom = 0;
		cs.width = 30;
		cs.height = 20;
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
		cs.left = 0;
		cs.bottom = 0;
		cs.width = 200;
		cs.height = 150;

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
}
