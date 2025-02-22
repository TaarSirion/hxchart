package hxchart.tests;

import haxe.ui.containers.Absolute;
import haxe.ui.components.Canvas;
import haxe.ui.util.Color;
import haxe.ui.geom.Point;
import hxchart.basics.axis.Axis;
import hxchart.basics.axis.NumericTickInfo;
import utest.Assert;
import hxchart.basics.axis.AxisTools;
import utest.Test;

class TestAxis extends Test {
	function testAxisCreation() {
		var tickInfo:NumericTickInfo = new NumericTickInfo(0, 100);
		var axisX = new Axis(new Point(50, 50), 0, 100, tickInfo, "xaxis");
		Assert.equals(50, axisX.top);
		Assert.equals(50, axisX.left);
		Assert.equals(0, axisX.axisRotation);
		Assert.equals(100, axisX.axisLength);
		Assert.equals(true, axisX.showZeroTick);
		Assert.equals(Color.fromString("black"), axisX.axisColor);
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

	function testTicks() {
		var tickInfo:NumericTickInfo = new NumericTickInfo(0, 100);
		var axisX = new Axis(new Point(50, 50), 0, 100, tickInfo, "xaxis");
		axisX.endPoint = new Point(150, 50);
		axisX.setTicks(tickInfo);
		Assert.equals(60, axisX.ticks[0].left);
		Assert.equals(68, axisX.ticks[1].left);
		Assert.equals(100, axisX.ticks[5].left);
		Assert.equals(132, axisX.ticks[9].left);
		Assert.equals(140, axisX.ticks[10].left);

		var axisX = new Axis(new Point(50, 50), 90, 100, tickInfo, "xaxis");
		axisX.endPoint = new Point(50, 150);
		axisX.setTicks(tickInfo);
		Assert.equals(60, axisX.ticks[0].top);
		Assert.equals(68, axisX.ticks[1].top);
		Assert.equals(100, axisX.ticks[5].top);
		Assert.equals(132, axisX.ticks[9].top);
		Assert.equals(140, axisX.ticks[10].top);
	}
}
