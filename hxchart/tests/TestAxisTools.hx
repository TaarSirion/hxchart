package hxchart.tests;

import hxchart.basics.axis.NumericTickInfo;
import hxchart.basics.axis.TickInfo;
import hxchart.basics.axis.Axis;
import haxe.ui.geom.Point;
import utest.Assert;
import hxchart.basics.axis.AxisTools;
import utest.Test;

class TestAxisTools extends Test {
	function testPositionEndpoint() {
		var errorMargin = 1e-2;

		var p = new Point(10, 10);
		var l = 10;
		var rot = 0;
		var e = AxisTools.positionEndpoint(p, rot, l);
		Assert.equals(20, e.x);
		Assert.equals(10, e.y);

		rot = 90;
		var e = AxisTools.positionEndpoint(p, rot, l);
		Assert.equals(10, e.x);
		Assert.equals(20, e.y);

		rot = 45;
		var e = AxisTools.positionEndpoint(p, rot, l);
		Assert.floatEquals(17.07, e.x, errorMargin);
		Assert.floatEquals(17.07, e.y, errorMargin);
	}

	function testOverlap() {
		var tickInfo:NumericTickInfo = new NumericTickInfo(0, 100);
		var axisX = new Axis(new Point(50, 50), 0, 100, tickInfo, "xaxis");
		var axisY = new Axis(new Point(70, 30), 0, 100, tickInfo, "yaxis"); // Rotation is irrelevant, because I set the endpoint from hand
		axisX.endPoint = new Point(150, 50);
		axisY.endPoint = new Point(70, 130);
		var overlap = AxisTools.findOverlap(axisX, axisY);
		Assert.equals(70, overlap.x);
		Assert.equals(50, overlap.y);

		var axisX = new Axis(new Point(50, 50), 0, 100, tickInfo, "xaxis");
		var axisY = new Axis(new Point(40, 30), 0, 100, tickInfo, "yaxis"); // Rotation is irrelevant, because I set the endpoint from hand
		axisX.endPoint = new Point(150, 50);
		axisY.endPoint = new Point(40, 130);
		var overlap = AxisTools.findOverlap(axisX, axisY);
		Assert.isNull(overlap);
	}
}
