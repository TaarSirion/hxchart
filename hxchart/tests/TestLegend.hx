package hxchart.tests;

import haxe.ui.util.Color;
import utest.Assert;
import hxchart.basics.legend.Legend;
import utest.Test;

class TestLegend extends Test {
	function testAddNode() {
		var legend = new Legend();
		legend.addNode({
			text: "test",
			fontSize: 5,
			color: Color.fromString("black")
		});
		Assert.equals("test", legend.childComponents[0].childComponents[0].text);
		Assert.equals("test", legend.childNodes[0]);
	}
}
