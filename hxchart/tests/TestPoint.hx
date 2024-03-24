package tests;

import basics.PointTools;
import utest.Assert;

class TestPoint extends utest.Test {
	function testCalcXCoord() {
		var x = PointTools.calcXCoord(1, 2, 0, 0, {pos_dist: 2, neg_dist: 0});
		Assert.equals(1, x);

		var x = PointTools.calcXCoord(-1, 0, -2, 0, {pos_dist: 0, neg_dist: 2});
		Assert.equals(-1, x);

		var x = PointTools.calcXCoord(0.5, 2, -2, 0, {pos_dist: 2, neg_dist: 2});
		Assert.equals(0.5, x);
	}

	function testCalcYCoord() {
		var x = PointTools.calcYCoord(1, 2, 0, 0, {pos_dist: 2, neg_dist: 0});
		Assert.equals(-1, x);

		var x = PointTools.calcYCoord(-1, 0, -2, 0, {pos_dist: 0, neg_dist: 2});
		Assert.equals(1, x);

		var x = PointTools.calcYCoord(0.5, 2, -2, 0, {pos_dist: 2, neg_dist: 2});
		Assert.equals(-0.5, x);
	}
}
