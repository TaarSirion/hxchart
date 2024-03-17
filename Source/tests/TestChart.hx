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

	function testSetTickInfo() {
		var tick_info = ChartTools.setTickInfo(0, 1);

		Assert.equals(3, tick_info.num);
		Assert.equals(0, tick_info.min);
		Assert.equals(1, tick_info.pos_ratio);
		Assert.equals(0, tick_info.prec);
		Assert.equals(1, tick_info.step);
		Assert.equals(0, tick_info.zero);

		var tick_info = ChartTools.setTickInfo(-1, 1);

		Assert.equals(5, tick_info.num);
		Assert.equals(-2, tick_info.min);
		Assert.equals(0.5, tick_info.pos_ratio);
		Assert.equals(0, tick_info.prec);
		Assert.equals(1, tick_info.step);
		Assert.equals(2, tick_info.zero);
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
