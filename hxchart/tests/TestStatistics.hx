package hxchart.tests;

import utest.Assert;
import utest.Test;

using hxchart.basics.utils.Statistics;

class TestStatistics extends Test {
	function testOrder() {
		var x = [1, 3, 5, 1, 2];
		Assert.equals(0, x.order()[0]);
		Assert.equals(3, x.order()[1]);
		Assert.equals(4, x.order()[2]);
		Assert.equals(1, x.order()[3]);
		Assert.equals(2, x.order()[4]);
	}

	function testUnique() {
		var x = [1, 1, 3, 2, 3, 2];
		Assert.equals(1, x.unique()[0]);
		Assert.equals(2, x.unique()[1]);
		Assert.equals(3, x.unique()[2]);
		Assert.equals(3, x.unique().length);
	}

	function testPosition() {
		var x = [1, 4, 6, 1, 3];
		Assert.equals(0, x.position(1)[0]);
		Assert.equals(3, x.position(1)[1]);
		Assert.equals(2, x.position(1).length);
	}

	function testRepeat() {
		Assert.equals(1, 1.repeat(2)[1]);
		Assert.equals(2, 1.repeat(2).length);
		Assert.equals("a", "a".repeat(3)[2]);
		Assert.equals(3, "a".repeat(3).length);
	}
}
