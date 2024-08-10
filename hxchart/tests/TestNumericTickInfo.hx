package hxchart.tests;

import hxchart.basics.axis.NumericTickInfo;
import utest.Assert;

class TestNumericTickInfo extends utest.Test {
	function testPrecision() {
		var tickInfo = new NumericTickInfo(0, 10);
		Assert.equals(0, tickInfo.precision);

		var tickInfo = new NumericTickInfo(-9, 80);
		Assert.equals(1, tickInfo.precision);

		var tickInfo = new NumericTickInfo(-99, 0);
		Assert.equals(1, tickInfo.precision);

		var tickInfo = new NumericTickInfo(0, 0.5);
		Assert.equals(1, tickInfo.precision);
		var tickInfo = new NumericTickInfo(-0.5, 0);
		Assert.equals(1, tickInfo.precision);

		var tickInfo = new NumericTickInfo(-0.5, 0.6);
		Assert.equals(1, tickInfo.precision);
	}

	function testPower() {
		var tickInfo = new NumericTickInfo(0, 10);
		Assert.equals(1, tickInfo.power);

		var tickInfo = new NumericTickInfo(-9, 80);
		Assert.equals(10, tickInfo.power);

		var tickInfo = new NumericTickInfo(-99, 0);
		Assert.equals(10, tickInfo.power);

		var tickInfo = new NumericTickInfo(0, 0.5);
		Assert.equals(0.1, tickInfo.power);
		var tickInfo = new NumericTickInfo(-0.5, 0);
		Assert.equals(0.1, tickInfo.power);
		var tickInfo = new NumericTickInfo(-0.5, 0.6);
		Assert.equals(0.1, tickInfo.power);
	}

	@:depends(testPrecision, testPower)
	function testTickNum() {
		var tickInfo = new NumericTickInfo(0, 10);
		tickInfo.calcTickNum();
		Assert.equals(11, tickInfo.tickNum);

		var tickInfo = new NumericTickInfo(-9, 80);
		tickInfo.calcTickNum();
		Assert.equals(10, tickInfo.tickNum);

		var tickInfo = new NumericTickInfo(-99, 0);
		tickInfo.calcTickNum();
		Assert.equals(11, tickInfo.tickNum);

		var tickInfo = new NumericTickInfo(0, 0.6);
		tickInfo.calcTickNum();
		Assert.equals(7, tickInfo.tickNum);

		var tickInfo = new NumericTickInfo(-0.6, 0);
		tickInfo.calcTickNum();
		Assert.equals(7, tickInfo.tickNum);
		var tickInfo = new NumericTickInfo(-0.6, 0.7);
		tickInfo.calcTickNum();
		Assert.equals(14, tickInfo.tickNum);
	}

	@:depends(testTickNum)
	function testZeroIndex() {
		var tickInfo = new NumericTickInfo(0, 10);
		tickInfo.calcTickNum();
		Assert.equals(0, tickInfo.zeroIndex);

		var tickInfo = new NumericTickInfo(-9, 80);
		tickInfo.calcTickNum();
		Assert.equals(1, tickInfo.zeroIndex);

		var tickInfo = new NumericTickInfo(-99, 0);
		tickInfo.calcTickNum();
		Assert.equals(10, tickInfo.zeroIndex);

		var tickInfo = new NumericTickInfo(-10, 10);
		Assert.equals(10, tickInfo.zeroIndex);

		var tickInfo = new NumericTickInfo(0, 0.6);
		tickInfo.calcTickNum();
		Assert.equals(0, tickInfo.zeroIndex);

		var tickInfo = new NumericTickInfo(-0.6, 0);
		tickInfo.calcTickNum();
		Assert.equals(6, tickInfo.zeroIndex);
		var tickInfo = new NumericTickInfo(-0.6, 0.7);
		tickInfo.calcTickNum();
		Assert.equals(6, tickInfo.zeroIndex);
	}

	@:depends(testTickNum)
	function testNegNum() {
		var tickInfo = new NumericTickInfo(0, 10);
		tickInfo.calcTickNum();
		Assert.equals(0, tickInfo.negNum);

		var tickInfo = new NumericTickInfo(-9, 80);
		tickInfo.calcTickNum();
		Assert.equals(1, tickInfo.negNum);

		var tickInfo = new NumericTickInfo(-99, 0);
		tickInfo.calcTickNum();
		Assert.equals(10, tickInfo.negNum);

		var tickInfo = new NumericTickInfo(-10, 10);
		Assert.equals(10, tickInfo.negNum);

		var tickInfo = new NumericTickInfo(0, 0.6);
		tickInfo.calcTickNum();
		Assert.equals(0, tickInfo.negNum);

		var tickInfo = new NumericTickInfo(-0.6, 0);
		tickInfo.calcTickNum();
		Assert.equals(6, tickInfo.negNum);
		var tickInfo = new NumericTickInfo(-0.6, 0.7);
		tickInfo.calcTickNum();
		Assert.equals(6, tickInfo.negNum);
	}

	@:depends(testTickNum, testZeroIndex, testNegNum)
	function testCalcLabels() {
		var tickInfo = new NumericTickInfo(0, 10);
		tickInfo.calcTickNum();
		tickInfo.calcTickLabels();
		var labels = tickInfo.labels;
		Assert.contains("7", labels);
		Assert.contains("10", labels);
		Assert.contains("0", labels);
		Assert.notContains("11", labels);

		var tickInfo = new NumericTickInfo(-9, 80);
		tickInfo.calcTickNum();
		tickInfo.calcTickLabels();
		var labels = tickInfo.labels;
		Assert.contains("-10", labels);
		Assert.contains("0", labels);
		Assert.contains("40", labels);
		Assert.contains("80", labels);
		Assert.notContains("-11", labels);
		Assert.notContains("90", labels);

		var tickInfo = new NumericTickInfo(-10, 10);
		var labels = tickInfo.labels;
		Assert.contains("-10", labels);
		Assert.contains("0", labels);
		Assert.contains("3", labels);
		Assert.contains("10", labels);
		Assert.notContains("-11", labels);
		Assert.notContains("11", labels);

		var tickInfo = new NumericTickInfo(-0.6, 0.7);
		tickInfo.calcTickNum();
		tickInfo.calcTickLabels();
		var labels = tickInfo.labels;
		Assert.contains("-0.2", labels);
		Assert.contains("0", labels);
		Assert.contains("0.3", labels);
		Assert.notContains("-0.7", labels);
		Assert.notContains("0.8", labels);
	}

	function testSubTickNum() {
		var tickInfo = new NumericTickInfo(0, 10, true);
		tickInfo.calcTickNum();
		Assert.equals(30, tickInfo.subTickNum);

		var tickInfo = new NumericTickInfo(-9, 80, true);
		tickInfo.calcTickNum();
		Assert.equals(27, tickInfo.subTickNum);

		var tickInfo = new NumericTickInfo(-99, 0, true);
		tickInfo.calcTickNum();
		Assert.equals(30, tickInfo.subTickNum);

		var tickInfo = new NumericTickInfo(0, 0.6, true);
		tickInfo.calcTickNum();
		Assert.equals(18, tickInfo.subTickNum);

		var tickInfo = new NumericTickInfo(-0.6, 0, true);
		tickInfo.calcTickNum();
		Assert.equals(18, tickInfo.subTickNum);

		var tickInfo = new NumericTickInfo(-0.6, 0.7, true);
		tickInfo.calcTickNum();
		Assert.equals(39, tickInfo.subTickNum);
	}

	@:depends(testNegNum)
	function testSubNegNum() {
		var tickInfo = new NumericTickInfo(0, 10, true);
		tickInfo.calcTickNum();
		Assert.equals(0, tickInfo.subNegNum);

		var tickInfo = new NumericTickInfo(-9, 80, true);
		tickInfo.calcTickNum();
		Assert.equals(3, tickInfo.subNegNum);

		var tickInfo = new NumericTickInfo(-99, 0, true);
		tickInfo.calcTickNum();
		Assert.equals(30, tickInfo.subNegNum);

		var tickInfo = new NumericTickInfo(0, 0.6, true);
		tickInfo.calcTickNum();
		Assert.equals(0, tickInfo.subNegNum);

		var tickInfo = new NumericTickInfo(-0.6, 0, true);
		tickInfo.calcTickNum();
		Assert.equals(18, tickInfo.subNegNum);

		var tickInfo = new NumericTickInfo(-0.6, 0.7, true);
		tickInfo.calcTickNum();
		Assert.equals(18, tickInfo.subNegNum);
	}

	@:depends(testSubTickNum, testSubNegNum)
	function testSubLabels() {
		var tickInfo = new NumericTickInfo(0, 10, true, 3, true);
		var labels = tickInfo.subLabels;
		Assert.contains(".25", labels);
		Assert.contains(".75", labels);
		Assert.notContains("0", labels);
		Assert.notContains("10.25", labels);

		var tickInfo = new NumericTickInfo(-9, 80, true);
		var labels = tickInfo.subLabels;
		Assert.contains("-7.5", labels);
		Assert.contains("-5", labels);
		Assert.contains("45", labels);
		Assert.contains("77.5", labels);
		Assert.notContains("-12.5", labels);
		Assert.notContains("82.5", labels);

		var tickInfo = new NumericTickInfo(-0.6, 0.7, true);
		var labels = tickInfo.subLabels;

		Assert.contains("-0.575", labels);
		Assert.contains("0.025", labels);
		Assert.contains("0.675", labels);
		Assert.notContains("-0.625", labels);
		Assert.notContains("0.725", labels);
	}
}
