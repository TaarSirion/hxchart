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

	function testzeroIndex() {
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
}
