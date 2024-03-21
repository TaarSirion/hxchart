package tests;

import utest.Assert;
import basics.AxisTools;
import utest.Test;

class TestAxis extends Test {
	function testSetTickInfo() {
		var tick_info = AxisTools.calcTickInfo(0, 1);

		Assert.equals(3, tick_info.num);
		Assert.equals(0, tick_info.min);
		Assert.equals(1, tick_info.pos_ratio);
		Assert.equals(0, tick_info.prec);
		Assert.equals(1, tick_info.step);
		Assert.equals(0, tick_info.zero);

		var tick_info = AxisTools.calcTickInfo(-1, 1);

		Assert.equals(5, tick_info.num);
		Assert.equals(-2, tick_info.min);
		Assert.equals(0.5, tick_info.pos_ratio);
		Assert.equals(0, tick_info.prec);
		Assert.equals(1, tick_info.step);
		Assert.equals(2, tick_info.zero);
	}
}
