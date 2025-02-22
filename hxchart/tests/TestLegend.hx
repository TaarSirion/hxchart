package hxchart.tests;

import hxchart.basics.legend.LegendNode;
import haxe.Timer;
import utest.Async;
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
	var legend:Legend;

	function setup() {
		legend = new Legend({
			useLegend: true
		});
	}

	function testNewLegend() {
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

	@:depends(testStyleSheet)
	function testAddNode() {
		legend.addNode({
			text: "test",
			style: {
				symbol: rectangle,
				textColor: 0x000000,
				fontSize: 5,
				symbolColor: 0xababab
			}
		});

		Assert.equals("test", legend.childComponents[0].childComponents[0].text);
		Assert.equals("test", legend.childNodes[0]);
		Assert.equals(null, legend.childComponents[0].childComponents[0].percentHeight);
		Assert.equals(100, legend.childComponents[0].childComponents[0].percentWidth);
		Assert.equals(10, legend.childComponents[0].childComponents[0].marginLeft);
		Assert.equals(10, legend.childComponents[0].childComponents[0].marginRight);
		Assert.equals(20, legend.childComponents[0].childComponents[0].childComponents[0].percentWidth);
		Assert.equals(80, legend.childComponents[0].childComponents[0].childComponents[1].percentWidth);

		var node:LegendNode = cast(legend.childComponents[0].childComponents[0], LegendNode);
		Assert.isTrue(node.childComponents[1].hasClass("legend-text"));
		Assert.equals("left", node.childComponents[1].customStyle.textAlign);
		Assert.isTrue(node.childComponents[0].hasClass("legend-text-symbol"));
		Assert.equals(24, node.childComponents[0].height);
		Assert.equals("rectangle", node.symbol);
		Assert.equals(0x000000, node.textColor);

		Assert.equals(5, node.fontSize);
		Assert.equals(0xababab, node.symbolColor);
	}

	function testValidation() {
		var info:LegendInfo = {
			useLegend: true,
			data: [
				{
					text: "A",
					style: {
						symbolColor: 0xababab
					}
				},
				{
					text: "B",
					style: {
						symbol: point
					}
				}
			],
			nodeStyle: {
				textColor: 0x000000,
				symbol: rectangle,
				fontSize: 16,
				symbolColor: 0xee0000
			}
		}
		info.validate();
		Assert.equals(16, info.data[0].style.fontSize);
		Assert.equals(0xababab, info.data[0].style.symbolColor);
		Assert.equals(rectangle, info.data[0].style.symbol);
		Assert.equals(16, info.data[1].style.fontSize);
		Assert.equals(0xee0000, info.data[1].style.symbolColor);
		Assert.equals(point, info.data[1].style.symbol);
	}
}
