package tests;

import utest.Assert;
import basics.AxisTools;
import utest.Test;

class TestAxis extends Test {
	function testSetTickInfo() {
		var tick_info = AxisTools.calcTickInfo(0, 1);

		Assert.same({
			num: 3,
			min: 0,
			pos_ratio: 1,
			prec: 0,
			step: 1,
			zero: 0
		}, tick_info);

		var tick_info = AxisTools.calcTickInfo(-1, 1);

		Assert.same({
			num: 5,
			min: -2,
			pos_ratio: 0.5,
			prec: 0,
			step: 1,
			zero: 2
		}, tick_info);
	}

	function testCalcTickPos() {
		var pos = AxisTools.calcTickPos(2, 10, 0, false);
		Assert.equals(0, pos[0]);
		Assert.equals(10, pos[1]);
	}

	function testCalcSubTickInfo() {
		var subtickinfo = AxisTools.calcSubTickInfo(10, 2, 1);

		Assert.same({
			dists: 5,
			step: 0.5,
			prec: 1
		}, subtickinfo);
	}
}
