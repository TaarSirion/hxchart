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
			id: "axis"
		};
		info.setAxisInfo([0, 1]);
		Assert.equals(linear, info.type);
		Assert.isTrue(info.tickInfo is NumericTickInfo);
		Assert.equals("1", info.tickInfo.labels[info.tickInfo.labels.length - 1]);

		var info:AxisInfo = {
			id: "axis"
		};
		info.setAxisInfo(["0", "1"]);
		Assert.equals(categorical, info.type);
		Assert.isTrue(info.tickInfo is StringTickInfo);
		Assert.equals("1", info.tickInfo.labels[info.tickInfo.labels.length - 1]);

		var info:AxisInfo = {
			id: "axis",
			type: linear
		};
		info.setAxisInfo(["0", "1"]);
		Assert.isTrue(info.tickInfo is NumericTickInfo);
		Assert.equals("1", info.tickInfo.labels[info.tickInfo.labels.length - 1]);

		var info:AxisInfo = {
			id: "axis",
			type: linear,
			tickInfo: new NumericTickInfo(["min" => [0], "max" => [10]])
		};
		info.setAxisInfo(["0", "1"]);
		Assert.isTrue(info.tickInfo is NumericTickInfo);
		Assert.equals("10", info.tickInfo.labels[info.tickInfo.labels.length - 1]);
	}

	function testAxisCreation() {
		var tickInfo:NumericTickInfo = new NumericTickInfo(["min" => [0], "max" => [100]]);
		var axisX = new Axis({
			id: "xaxis",
			tickInfo: tickInfo,
			start: new Point(50, 50),
			rotation: 0,
			length: 100,
			type: linear
		});
		Assert.equals(50, axisX.top);
		Assert.equals(50, axisX.left);
		Assert.equals(0, axisX.axisRotation);
		Assert.equals(100, axisX.axisLength);
		Assert.equals(true, axisX.showZeroTick);
		Assert.equals("xaxis", axisX.id);
		Assert.equals(50, axisX.startPoint.x);
		Assert.equals(50, axisX.startPoint.y);
		Assert.equals(0, axisX.sub_ticks.length);
		Assert.equals(2, axisX.childComponents.length);
		Assert.equals(10, axisX.tickMargin);
		Assert.isOfType(axisX.childComponents[0], Canvas);
		Assert.isOfType(axisX.childComponents[1], Absolute);
		Assert.equals(11, axisX.ticks.length);
		Assert.isNull(axisX.endPoint);
	}

	function testAxisStyle() {
		var tickInfo:NumericTickInfo = new NumericTickInfo(["min" => [0], "max" => [100]]);
		var axisX = new Axis({
			id: "xaxis",
			tickInfo: tickInfo,
			start: new Point(50, 50),
			rotation: 0,
			length: 100,
			type: linear
		});
		Assert.equals(0x000000, axisX.axisColor);

		var style = new StyleSheet();
		style.parse(".axis {background-color: #ababab;}");
		var axisX = new Axis({
			id: "xaxis",
			tickInfo: tickInfo,
			start: new Point(50, 50),
			rotation: 0,
			length: 100,
			type: linear
		}, style);
		Assert.equals(0xababab, axisX.axisColor);
	}

	function testTicks() {
		var tickInfo:NumericTickInfo = new NumericTickInfo(["min" => [0], "max" => [100]]);
		var axisX = new Axis({
			start: new Point(50, 50),
			rotation: 0,
			length: 100,
			tickInfo: tickInfo,
			id: "xaxis",
			type: linear
		});
		axisX.endPoint = new Point(150, 50);
		axisX.setTicks({tickInfo: tickInfo, isUpdate: false});
		Assert.equals(60, axisX.ticks[0].left);
		Assert.equals(68, axisX.ticks[1].left);
		Assert.equals(100, axisX.ticks[5].left);
		Assert.equals(132, axisX.ticks[9].left);
		Assert.equals(140, axisX.ticks[10].left);

		var axisX = new Axis({
			start: new Point(50, 50),
			rotation: 90,
			length: 100,
			tickInfo: tickInfo,
			id: "xaxis",
			type: linear
		});
		axisX.endPoint = new Point(50, 150);
		axisX.setTicks({tickInfo: tickInfo, isUpdate: false});
		Assert.equals(60, axisX.ticks[0].top);
		Assert.equals(68, axisX.ticks[1].top);
		Assert.equals(100, axisX.ticks[5].top);
		Assert.equals(132, axisX.ticks[9].top);
		Assert.equals(140, axisX.ticks[10].top);
	}
}
