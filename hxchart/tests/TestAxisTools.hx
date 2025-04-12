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
		Assert.equals(0, e.y);

		rot = 45;
		var e = AxisTools.positionEndpoint(p, rot, l);
		Assert.floatEquals(17.07, e.x, errorMargin);
		Assert.floatEquals(2.93, e.y, errorMargin);
	}
}
