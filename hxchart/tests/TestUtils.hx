package hxchart.tests;

import hxchart.basics.utils.Utils;
import utest.Assert;
import utest.Test;

class TestUtils extends Test {
	function testRemoveTrailingZeros() {
		Assert.equals("1", Utils.removeTrailingZeros("100"));
		Assert.equals("0.", Utils.removeTrailingZeros("0.0"));
	}

	@:depends(testRemoveTrailingZeros)
	function testFloatToStringPrecision() {
		Assert.equals("100.45", Utils.floatToStringPrecision(100.45, 2));
		Assert.equals("100.5", Utils.floatToStringPrecision(100.45, 1));
		Assert.equals("100", Utils.floatToStringPrecision(100.45, 0));
		Assert.equals("10", Utils.floatToStringPrecision(100.45, -1));
		Assert.equals("100.45", Utils.floatToStringPrecision(100.45, 3));

		Assert.equals("-10.3", Utils.floatToStringPrecision(-10.3, 1));
		Assert.equals("-10", Utils.floatToStringPrecision(-10.3, 0));
		Assert.equals("-10.3", Utils.floatToStringPrecision(-10.3, 2));

		Assert.equals("0.352", Utils.floatToStringPrecision(0.352, 3));
		Assert.equals("0.35", Utils.floatToStringPrecision(0.352, 2));
		Assert.equals("0.4", Utils.floatToStringPrecision(0.352, 1));
		Assert.equals("0", Utils.floatToStringPrecision(0.352, 0));
	}

	function testRoundToPrec() {
		Assert.equals(20, Utils.roundToPrec(10.45, 1));
		Assert.equals(11, Utils.roundToPrec(10.45, 0));
		Assert.equals(100, Utils.roundToPrec(10.45, 2));
		Assert.equals(10.5, Utils.roundToPrec(10.45, -1));

		Assert.equals(-20, Utils.roundToPrec(-10.45, 1));
		Assert.equals(-11, Utils.roundToPrec(-10.45, 0));
		Assert.equals(-100, Utils.roundToPrec(-10.45, 2));
		Assert.equals(-10.5, Utils.roundToPrec(-10.45, -1));

		Assert.equals(0.5, Utils.roundToPrec(0.45, 1));
		Assert.equals(1, Utils.roundToPrec(0.45, 0));
		Assert.equals(0.45, Utils.roundToPrec(0.45, 2));
		Assert.equals(10, Utils.roundToPrec(0.45, -1));
	}

	function testRemoveLeadingNumbers() {
		Assert.equals("123", Utils.removeLeadingNumbers("345.123"));
		Assert.equals("345", Utils.removeLeadingNumbers("345"));
	}
}
