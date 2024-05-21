package hxchart.tests;

import eval.Vector;
import utest.Assert;
import hxchart.basics.axis.AxisTools;
import utest.Test;

class TestAxis extends Test {
	function testSetTickInfo() {
		var tick_info = AxisTools.calcTickInfo(0, 1);

		Assert.same({
			num: 2,
			min: 0,
			pos_ratio: 1,
			prec: 0,
			step: 1,
			zero: 0,
			labels: ["0", "1"]
		}, tick_info);

		var tick_info = AxisTools.calcTickInfo(-1, 1);
		Assert.same({
			num: 3,
			min: -1,
			pos_ratio: 0.5,
			prec: 0,
			step: 1,
			zero: 1,
			labels: ["-1", "0", "1"]
		}, tick_info);

		var tick_info = AxisTools.calcTickInfo(-0.5, 0.5);
		Assert.same({
			num: 11,
			min: -0.5,
			pos_ratio: 0.5,
			prec: -1,
			step: 0.1,
			zero: 5,
			labels: ["-0.5", "-0.4", "-0.3", "-0.2", "-0.1", "0", "0.1", "0.2", "0.3", "0.4", "0.5"]
		}, tick_info);
	}

	function testCalcTickPos() {
		var pos = AxisTools.calcTickPos(2, 10, 0, false);
		Assert.equals(0, pos[0]);
		Assert.equals(10, pos[1]);
	}

	function testTickVals() {
		var min = -94.10371600388673;
		var max = 99.96867246679707;
		var tickInfo = AxisTools.calcTickInfo(min, max);
		Assert.equals("-100", tickInfo.labels[0]);
		Assert.equals("0", tickInfo.labels[tickInfo.zero]);
		Assert.equals("100", tickInfo.labels[tickInfo.labels.length - 1]);

		var min = -93.68653918516794;
		var max = 87.12945296;
		var tickInfo = AxisTools.calcTickInfo(min, max);
		Assert.equals("-100", tickInfo.labels[0]);
		Assert.equals("0", tickInfo.labels[tickInfo.zero]);
		Assert.equals("90", tickInfo.labels[tickInfo.labels.length - 1]);
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
