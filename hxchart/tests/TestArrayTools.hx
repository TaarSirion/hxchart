package hxchart.tests;

import utest.Assert;
import utest.Test;

using hxchart.core.utils.ArrayTools;

class TestArrayTools extends Test {
	function testOrder() {
		// Test with an empty array
		var arrEmpty:Array<Int> = [];
		Assert.same([], arrEmpty.order());

		// Test with an array of integers
		var arrInt = [1, 3, 5, 1, 2];
		Assert.same([0, 3, 4, 1, 2], arrInt.order());

		// Test with an array of strings
		var arrString = ["c", "a", "b"];
		Assert.same([1, 2, 0], arrString.order());

		// Test with an array of strings with duplicates
		var arrStringDup = ["b", "a", "b"];
		Assert.same([1, 0, 2], arrStringDup.order());

		// Original test case - ensuring it's robust
		var x = [1, 3, 5, 1, 2];
		Assert.same([0, 3, 4, 1, 2], x.order());
	}

	function testUnique() {
		// Test with an empty array
		var arrEmpty:Array<Int> = [];
		Assert.same([], arrEmpty.unique());

		// Test with an array of integers with no duplicates
		var arrIntNoDup = [1, 2, 3];
		Assert.same([1, 2, 3], arrIntNoDup.unique());

		// Test with an array of integers with duplicates
		var arrIntDup = [1, 1, 3, 2, 3, 2];
		Assert.same([1, 2, 3], arrIntDup.unique()); // Elements are sorted

		// Test with an array of strings with no duplicates
		var arrStringNoDup = ["a", "b", "c"];
		Assert.same(["a", "b", "c"], arrStringNoDup.unique());

		// Test with an array of strings with duplicates
		var arrStringDup = ["a", "b", "a", "c", "b"];
		Assert.same(["a", "b", "c"], arrStringDup.unique()); // Elements are sorted
	}

	function testPosition() {
		// Test with an empty array
		var arrEmpty:Array<Int> = [];
		Assert.same([], arrEmpty.position(1));

		// Test with an array of integers and a value present multiple times
		var arrIntMulti = [1, 4, 6, 1, 3];
		Assert.same([0, 3], arrIntMulti.position(1));

		// Test with an array of integers and a value not present
		var arrIntNotFound = [1, 2, 3];
		Assert.same([], arrIntNotFound.position(4));

		// Test with an array of strings and a value present multiple times
		var arrStringMulti = ["a", "b", "a", "c"];
		Assert.same([0, 2], arrStringMulti.position("a"));

		// Test with an array of strings and a value not present
		var arrStringNotFound = ["a", "b", "c"];
		Assert.same([], arrStringNotFound.position("d"));
	}

	function testRepeat() {
		// Test with an integer value and n > 0
		Assert.same([1, 1, 1], 1.repeat(3));

		// Test with a string value and n > 0
		Assert.same(["a", "a"], "a".repeat(2));

		// Test with n = 0 for integer
		Assert.same([], ArrayTools.repeat(1, 0));
		// Assert.same([], 1.repeat(0)); // Alternative if it works as an extension method

		// Test with n = 0 for string
		Assert.same([], ArrayTools.repeat("a", 0));
		// Assert.same([], "a".repeat(0)); // Alternative if it works as an extension method
	}

	function testAny() {
		// Test with an empty array
		var arrEmpty:Array<Int> = [];
		Assert.isFalse(ArrayTools.any(arrEmpty, function(v) return v > 0));

		// Test with an array of integers and a condition that is met
		var arrIntMet = [1, -2, 3];
		Assert.isTrue(ArrayTools.any(arrIntMet, function(v) return v > 0));

		// Test with an array of integers and a condition that is not met
		var arrIntNotMet = [-1, -2, -3];
		Assert.isFalse(ArrayTools.any(arrIntNotMet, function(v) return v > 0));

		// Test with an array of strings and a condition that is met
		var arrStringMet = ["a", "b", "c"];
		Assert.isTrue(ArrayTools.any(arrStringMet, function(v) return v == "b"));

		// Test with an array of strings and a condition that is not met
		var arrStringNotMet = ["a", "b", "c"];
		Assert.isFalse(ArrayTools.any(arrStringNotMet, function(v) return v == "d"));
	}
}
