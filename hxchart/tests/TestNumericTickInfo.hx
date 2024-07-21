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
		Assert.equals(10, tickInfo.tickNum);

		var tickInfo = new NumericTickInfo(-9, 80);
		tickInfo.calcTickNum();
		Assert.equals(10, tickInfo.tickNum);

		var tickInfo = new NumericTickInfo(-99, 0);
		tickInfo.calcTickNum();
		Assert.equals(10, tickInfo.tickNum);

		var tickInfo = new NumericTickInfo(0, 0.6);
		tickInfo.calcTickNum();
		Assert.equals(6, tickInfo.tickNum);

		var tickInfo = new NumericTickInfo(-0.6, 0);
		tickInfo.calcTickNum();
		Assert.equals(6, tickInfo.tickNum);
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
		Assert.equals(9, tickInfo.zeroIndex);

		var tickInfo = new NumericTickInfo(0, 0.6);
		tickInfo.calcTickNum();
		Assert.equals(0, tickInfo.zeroIndex);

		var tickInfo = new NumericTickInfo(-0.6, 0);
		tickInfo.calcTickNum();
		Assert.equals(5, tickInfo.zeroIndex);
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
		Assert.equals(9, tickInfo.negNum);

		var tickInfo = new NumericTickInfo(0, 0.6);
		tickInfo.calcTickNum();
		Assert.equals(0, tickInfo.negNum);

		var tickInfo = new NumericTickInfo(-0.6, 0);
		tickInfo.calcTickNum();
		Assert.equals(5, tickInfo.negNum);
		var tickInfo = new NumericTickInfo(-0.6, 0.7);
		tickInfo.calcTickNum();
		Assert.equals(6, tickInfo.negNum);
	}

	@:depends(testTickNum, testZeroIndex, testNegNum)
	function testCalcLabels() {
		var tickInfo = new NumericTickInfo(0, 10);
		tickInfo.calcTickNum();
		var labels = tickInfo.calcTickLabels();
		Assert.contains("7", labels);
		Assert.notContains("11", labels);

		var tickInfo = new NumericTickInfo(-9, 80);
		tickInfo.calcTickNum();
		var labels = tickInfo.calcTickLabels();
		Assert.contains("-10", labels);
		Assert.contains("0", labels);
		Assert.contains("40", labels);
		Assert.notContains("-11", labels);
		Assert.notContains("90", labels);

		var tickInfo = new NumericTickInfo(-0.6, 0.7);
		tickInfo.calcTickNum();
		var labels = tickInfo.calcTickLabels();
		Assert.contains("-0.2", labels);
		Assert.contains("0", labels);
		Assert.contains("0.3", labels);
		Assert.notContains("-0.7", labels);
		Assert.notContains("0.8", labels);
	}
}
