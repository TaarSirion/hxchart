package hxchart.tests;

import haxe.ui.styles.StyleSheet;
import haxe.ui.containers.Absolute;
import haxe.ui.components.Canvas;
import haxe.ui.util.Color;
import haxe.ui.geom.Point;
import hxchart.basics.axis.Axis;
import hxchart.basics.axis.NumericTickInfo;
import hxchart.basics.axis.StringTickInfo;
import utest.Assert;
import hxchart.basics.axis.AxisTools;
import utest.Test;

class TestAxis extends Test {
	function testAxisInfo() {
		var info:AxisInfo = {
			id: "axis",
			rotation: 0
		};
		info.setAxisInfo([0, 1]);
		Assert.equals(linear, info.type);
		Assert.isTrue(info.tickInfo is NumericTickInfo);
		Assert.equals("1", info.tickInfo.labels[info.tickInfo.labels.length - 1]);

		var info:AxisInfo = {
			id: "axis",
			rotation: 0
		};
		info.setAxisInfo(["0", "1"]);
		Assert.equals(categorical, info.type);
		Assert.isTrue(info.tickInfo is StringTickInfo);
		Assert.equals("1", info.tickInfo.labels[info.tickInfo.labels.length - 1]);

		var info:AxisInfo = {
			id: "axis",
			rotation: 0,
			type: linear
		};
		info.setAxisInfo(["0", "1"]);
		Assert.isTrue(info.tickInfo is NumericTickInfo);
		Assert.equals("1", info.tickInfo.labels[info.tickInfo.labels.length - 1]);

		var info:AxisInfo = {
			id: "axis",
			rotation: 0,
			type: linear,
			tickInfo: new NumericTickInfo(["min" => [0], "max" => [10]])
		};
		info.setAxisInfo(["0", "1"]);
		Assert.isTrue(info.tickInfo is NumericTickInfo);
		Assert.equals("10", info.tickInfo.labels[info.tickInfo.labels.length - 1]);
	}

	function testAxisCreation() {
		var tickInfo:NumericTickInfo = new NumericTickInfo(["min" => [0], "max" => [100]]);
		var axisInfo:AxisInfo = {
			id: "xaxis",
			tickInfo: tickInfo,
			start: new Point(50, 50),
			rotation: 0,
			length: 100,
			type: linear
		};
		axisInfo.setAxisInfo([1, 6, 18, 40, 76]);

		var axis = new Axis("axis", [axisInfo]);

		Assert.equals(0, axis.top);
		Assert.equals(0, axis.left);
		Assert.equals(0, axis.axesInfo[0].rotation);
		Assert.equals(100, axis.axesInfo[0].length);
		Assert.equals(null, axis.axesInfo[0].showZeroTick);
		Assert.equals("axis", axis.id);
		Assert.equals(50, axis.axesInfo[0].start.x);
		Assert.equals(50, axis.axesInfo[0].start.y);
		Assert.equals(2, axis.childComponents.length);
		Assert.equals(10, axis.axesInfo[0].tickMargin);
		Assert.isOfType(axis.childComponents[0], Canvas);
		Assert.isOfType(axis.childComponents[1], Absolute);
		Assert.equals(0, axis.ticksPerInfo[0].length);
	}

	function testAxisStyle() {
		var tickInfo:NumericTickInfo = new NumericTickInfo(["min" => [0], "max" => [100]]);
		var axisX = new Axis("axis", [
			{
				id: "xaxis",
				tickInfo: tickInfo,
				start: new Point(50, 50),
				rotation: 0,
				length: 100,
				type: linear
			}
		]);
		Assert.equals(0x000000, axisX.axisColor);

		var style = new StyleSheet();
		style.parse(".axis {background-color: #ababab;}");
		var axisX = new Axis("axis", [
			{
				id: "xaxis",
				tickInfo: tickInfo,
				start: new Point(50, 50),
				rotation: 0,
				length: 100,
				type: linear
			}
		], style);
		Assert.equals(0xababab, axisX.axisColor);
	}

	function testTicks() {
		var tickInfo:NumericTickInfo = new NumericTickInfo(["min" => [0], "max" => [100]]);
		var axisX = new Axis("axis", [
			{
				start: new Point(50, 50),
				rotation: 0,
				length: 100,
				tickInfo: tickInfo,
				id: "xaxis",
				type: linear
			}
		]);
		axisX.setTicks(false);
		Assert.equals(60, axisX.ticksPerInfo[0][0].left);
		Assert.equals(68, axisX.ticksPerInfo[0][1].left);
		Assert.equals(100, axisX.ticksPerInfo[0][5].left);
		Assert.equals(132, axisX.ticksPerInfo[0][9].left);
		Assert.equals(140, axisX.ticksPerInfo[0][10].left);

		var axisX = new Axis("axis", [
			{
				start: new Point(50, 100),
				rotation: 90,
				length: 100,
				tickInfo: tickInfo,
				id: "xaxis",
				type: linear
			}
		]);
		axisX.setTicks(false);
		Assert.equals(90, axisX.ticksPerInfo[0][0].top);
		Assert.equals(82, axisX.ticksPerInfo[0][1].top);
		Assert.equals(50, axisX.ticksPerInfo[0][5].top);
		Assert.equals(18, axisX.ticksPerInfo[0][9].top);
		Assert.equals(10, axisX.ticksPerInfo[0][10].top);
	}

	function testPositionStartPoint() {
		var axisInfo:Array<AxisInfo> = [
			{
				id: "x-axis",
				type: AxisTypes.linear,
				values: [0, 10],
				rotation: 0,
				tickInfo: new NumericTickInfo(["min" => [0], "max" => [10]])
			},
			{
				id: "y-axis",
				type: AxisTypes.linear,
				values: [0, 100],
				rotation: 90,
				tickInfo: new NumericTickInfo(["min" => [0], "max" => [100]])
			}
		];

		var axis = new Axis("test-axis", axisInfo);
		axis.width = 100;
		axis.height = 100;
		axis.positionStartPoint();

		// Validate zeroPoint positioning
		Assert.notNull(axis.zeroPoint);
		Assert.isTrue(axis.zeroPoint.x > 0);
		Assert.isTrue(axis.zeroPoint.y > 0);

		// Validate axis lengths
		Assert.equals(axisInfo[0].length, axis.width - axis.axisMarginLeft * 2);
		Assert.equals(axisInfo[1].length, axis.height - axis.axisMarginTop * 2);
		Assert.equals(axisInfo[0].start.x, axis.axisMarginLeft);
		Assert.equals(axisInfo[1].start.y, axis.height - axis.axisMarginTop);
	}
}
