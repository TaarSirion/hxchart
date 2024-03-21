package tests;

import basics.ChartTools;
import utest.Assert;

class TestChart extends utest.Test {
	function testSortPoints() {
		var minmax = ChartTools.sortPoints([1, 0], [2, 3, 1]);

		Assert.equals(0, minmax.min_x);
		Assert.equals(1, minmax.max_x);
		Assert.equals(1, minmax.min_y);
		Assert.equals(3, minmax.max_y);
	}

	function testCalcAxisLength() {
		var length = ChartTools.calcAxisLength(100, 10);
		Assert.equals(80, length);
	}

	function testCalcAxisDists() {
		var dists = ChartTools.calcAxisDists(0, 100, 0.6);

		Assert.equals(60, dists.pos_dist);
		Assert.equals(40, dists.neg_dist);
	}

	function testSetStartPoint() {
		var point = ChartTools.setAxisStartPoint(0, 0, false);

		Assert.equals(0, point.x);
		Assert.equals(0, point.y);

		var point = ChartTools.setAxisStartPoint(1, 0, false);

		Assert.equals(1, point.x);
		Assert.equals(0, point.y);

		var point = ChartTools.setAxisStartPoint(0, 1, true);

		Assert.equals(1, point.x);
		Assert.equals(0, point.y);
	}

	function testSetEndPoint() {
		var spoint = ChartTools.setAxisStartPoint(0, 0, false);
		var point = ChartTools.setAxisEndPoint(spoint, 100, false);
		Assert.equals(100, point.x);
		Assert.equals(0, point.y);

		var point = ChartTools.setAxisEndPoint(spoint, 100, true);
		Assert.equals(0, point.x);
		Assert.equals(100, point.y);
	}
}
