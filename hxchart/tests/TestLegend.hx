package hxchart.tests;

import haxe.ui.styles.Dimension;
import haxe.ui.containers.HBox;
import haxe.ui.HaxeUIApp;
import haxe.ui.core.Component;
import haxe.ui.containers.VBox;
import haxe.ui.util.Color;
import utest.Assert;
import hxchart.basics.legend.Legend;
import utest.Test;

class TestLegend extends Test {
	function testNewLegend() {
		var legend = new Legend();
		Assert.isTrue(legend.hasClass("legend-class"));
		Assert.equals(10, legend.marginBottom);
		Assert.equals(10, legend.marginTop);
		Assert.equals(10, legend.marginRight);
		Assert.equals(10, legend.marginLeft);
		Assert.equals(30, legend.height);
		Assert.equals(100, legend.percentWidth);
		Assert.equals(0, legend.childNodes.length);

		Assert.equals("legend-container", legend.childComponents[0].id);
		Assert.equals(100, legend.childComponents[0].percentHeight);
		Assert.equals(100, legend.childComponents[0].percentWidth);
		Assert.isOfType(legend.childComponents[0], VBox);

		Assert.equals("legend-container", legend.childComponents[1].id);
		Assert.equals(100, legend.childComponents[1].percentHeight);
		Assert.equals(100, legend.childComponents[1].percentWidth);
		Assert.isOfType(legend.childComponents[1], HBox);
	}

	function testStyleSheet() {
		var legend = new Legend();

		Assert.equals(".legend-class", legend.styleSheet.rules[0].selector.toString());
		var legendDirectives = legend.styleSheet.rules[0].directives;
		// Check both top and right to see if it got set for everything
		var borderSize:Dimension = legendDirectives.get("border-top-size").value.getParameters()[0];
		Assert.equals(1, borderSize.getParameters()[0]);
		var borderSize:Dimension = legendDirectives.get("border-right-size").value.getParameters()[0];
		Assert.equals(1, borderSize.getParameters()[0]);
		Assert.equals("solid", legendDirectives.get("border-style").value.getParameters()[0]);
		// Check both top and right to see if it got set for everything
		Assert.equals(Color.fromString("#000000"), legendDirectives.get("border-top-color").value.getParameters()[0]);
		Assert.equals(Color.fromString("#000000"), legendDirectives.get("border-right-color").value.getParameters()[0]);
		Assert.equals(Color.fromString("#F5F5F5"), legendDirectives.get("background-color").value.getParameters()[0]);
		// Check both top and right to see if it got set for everything
		var paddingTop:Dimension = legendDirectives.get("padding-top").value.getParameters()[0];
		Assert.equals(10, paddingTop.getParameters()[0]);
		var paddingRight:Dimension = legendDirectives.get("padding-right").value.getParameters()[0];
		Assert.equals(10, paddingRight.getParameters()[0]);
		Assert.equals("Arial", legendDirectives.get("font-family").value.getParameters()[0]);

		Assert.equals(".legend-title", legend.styleSheet.rules[1].selector.toString());
		var legendDirectives = legend.styleSheet.rules[1].directives;
		Assert.equals("center", legendDirectives.get("text-align").value.getParameters()[0]);
		var fontSize:Dimension = legendDirectives.get("font-size").value.getParameters()[0];
		Assert.equals(20, fontSize.getParameters()[0]);
	}

	function testAddNode() {
		var legend = new Legend();
		legend.addNode({
			text: "test",
			fontSize: 5,
			color: Color.fromString("black")
		});

		Assert.equals("test", legend.childComponents[0].childComponents[0].text);
		Assert.equals("test", legend.childNodes[0]);
		Assert.equals(null, legend.childComponents[0].childComponents[0].percentHeight);
		Assert.equals(100, legend.childComponents[0].childComponents[0].percentWidth);
	}
}
