package hxchart.tests;

import utest.Test;
import utest.Assert;
import hxchart.core.tickinfo.StringTickInfo;

class TestStringTickInfo extends Test {
	function testConstructor() {
		// Test with unique values
		var tickInfo = new StringTickInfo(["apple", "banana", "cherry"]);
		Assert.equals("", tickInfo.labels[0]);
		Assert.isTrue(tickInfo.labels.indexOf("apple") > 0);
		Assert.isTrue(tickInfo.labels.indexOf("banana") > 0);
		Assert.isTrue(tickInfo.labels.indexOf("cherry") > 0);
		// Check order
		var appleIndex = tickInfo.labels.indexOf("apple");
		var bananaIndex = tickInfo.labels.indexOf("banana");
		var cherryIndex = tickInfo.labels.indexOf("cherry");
		Assert.isTrue(appleIndex < bananaIndex && bananaIndex < cherryIndex);
		Assert.equals(4, tickInfo.tickNum);
		Assert.equals(0, tickInfo.zeroIndex);

		// Test with duplicate values
		tickInfo = new StringTickInfo(["red", "blue", "red"]);
		Assert.equals("", tickInfo.labels[0]);
		Assert.isTrue(tickInfo.labels.indexOf("red") > 0);
		Assert.isTrue(tickInfo.labels.indexOf("blue") > 0);
		Assert.equals(3, tickInfo.tickNum); // "", "red", "blue"
		Assert.equals(0, tickInfo.zeroIndex);

		// Test with empty array
		tickInfo = new StringTickInfo([]);
		Assert.same([""], tickInfo.labels);
		Assert.equals(1, tickInfo.tickNum);
		Assert.equals(0, tickInfo.zeroIndex);
	}

	function testSubTicks() {
		var testLabels = ["One", "Two", "Three"];
		var tickInfo = new StringTickInfo(testLabels);

		Assert.equals(0, tickInfo.subTickNum);
		Assert.same([], tickInfo.subLabels);
	}

	function testSetLabels() {
		var tickInfo = new StringTickInfo(["a", "b"]); // labels: ["", "a", "b"], tickNum: 3
		Assert.equals(3, tickInfo.tickNum);
		Assert.same(["", "a", "b"], tickInfo.labels);

		tickInfo.setLabels(["c", "d"]);
		Assert.same(["", "a", "b", "c", "d"], tickInfo.labels);
		Assert.equals(3, tickInfo.tickNum); // tickNum should not change yet

		tickInfo.setLabels(["a", "e"]); // "a" is duplicate, should not be added again to the internal unique list for labels
		Assert.same(["", "a", "b", "c", "d", "e"], tickInfo.labels);
		Assert.equals(3, tickInfo.tickNum);

		tickInfo.setLabels([]); // Calling with empty array should not change existing labels
		Assert.same(["", "a", "b", "c", "d", "e"], tickInfo.labels);
		Assert.equals(3, tickInfo.tickNum);
	}

	function testCalcTickNum() {
		var tickInfo = new StringTickInfo(["one", "two"]); // labels: ["", "one", "two"], tickNum: 3 initially
		Assert.equals(3, tickInfo.tickNum);

		tickInfo.calcTickNum(); // Should calculate based on current labels ["", "one", "two"]
		Assert.equals(3, tickInfo.tickNum);

		tickInfo.setLabels(["three", "four"]); // labels: ["", "one", "two", "three", "four"]
		// tickNum is still 3 because calcTickNum has not been called after setLabels
		Assert.equals(3, tickInfo.tickNum);
		Assert.same(["", "one", "two", "three", "four"], tickInfo.labels);

		tickInfo.calcTickNum(); // Recalculate based on ["", "one", "two", "three", "four"]
		Assert.equals(5, tickInfo.tickNum);

		tickInfo.setLabels(["one", "five"]); // labels: ["", "one", "two", "three", "four", "five"]
		// tickNum is still 5
		Assert.equals(5, tickInfo.tickNum);
		Assert.same(["", "one", "two", "three", "four", "five"], tickInfo.labels);

		tickInfo.calcTickNum(); // Recalculate based on ["", "one", "two", "three", "four", "five"]
		Assert.equals(6, tickInfo.tickNum);
	}
}
