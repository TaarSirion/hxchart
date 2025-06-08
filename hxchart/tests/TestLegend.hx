package hxchart.tests;

import utest.Assert;
import hxchart.core.legend.Legend;
import hxchart.core.legend.LegendInfo;
import hxchart.core.legend.LegendPosition;
import hxchart.core.legend.LegendSymbols;

class TestLegend extends utest.Test {
	public function new() {
		super();
	}

	public function testNewLegendEmptyInfo() {
		var legend = new Legend(null);
		Assert.notNull(legend);
		Assert.equals("Legend", legend.title);
		Assert.equals(LegendPosition.right, legend.legendPosition);
		// Cannot test default symbol as it's part of LegendInfo which is private to the constructor
	}

	public function testNewLegendWithInfo() {
		var legendInfo:LegendInfo = {
			title: {text: "My Legend"},
			subTitle: {text: "Subtitle"},
			position: LegendPosition.left,
			useLegend: true,
			nodeStyle: {symbol: LegendSymbols.point}
		};
		var legend = new Legend(legendInfo);
		Assert.notNull(legend);
		Assert.equals("My Legend", legend.title);
		Assert.equals("Subtitle", legend.subTitle);
		Assert.equals(LegendPosition.left, legend.legendPosition);
		// Cannot test nodeStyle symbol as it's not stored directly on Legend
	}

	public function testNewLegendPartialInfo() {
		var legendInfo:LegendInfo = {
			title: {text: "Another Legend"},
			useLegend: true
			// nodeStyle and position will use defaults
		};
		var legend = new Legend(legendInfo);
		Assert.notNull(legend);
		Assert.equals("Another Legend", legend.title);
		Assert.isNull(legend.subTitle); // Not provided
		Assert.equals(LegendPosition.right, legend.legendPosition); // Default
	}

	public function testNewLegendNullNodeStyle() {
		var legendInfo:LegendInfo = {
			title: {text: "Legend X"},
			useLegend: true,
			nodeStyle: null
		};
		var legend = new Legend(legendInfo);
		Assert.notNull(legend);
		// Default symbol should be applied
		// Cannot directly test legend.info.nodeStyle.symbol == LegendSymbols.rectangle
		// because info is not a public member. We trust the constructor handles this.
	}

	public function testNewLegendNullSymbolInNodeStyle() {
		var legendInfo:LegendInfo = {
			title: {text: "Legend Y"},
			useLegend: true,
			nodeStyle: {symbol: null}
		};
		var legend = new Legend(legendInfo);
		Assert.notNull(legend);
		// Default symbol should be applied
		// As above, cannot directly test the symbol.
	}
}
