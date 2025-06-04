package hxchart.tests;

import utest.Assert;
import hxchart.core.legend.LegendInfo;
import hxchart.core.legend.LegendPosition;
import hxchart.core.legend.LegendSymbols;
import hxchart.core.legend.LegendTitle; // Assuming LegendTitle is a typedef/class
import hxchart.core.legend.LegendNodeStyling; // Assuming LegendNodeStyling is a typedef/class

class TestLegendInfo extends utest.Test {
	public function new() {
		super();
	}

	public function testBasicLegendInfo() {
		var legendTitle:LegendTitle = {text: "Test Title"};
		var nodeStyling:LegendNodeStyling = {symbol: LegendSymbols.rectangle, symbolColor: 0xFF0000};

		var info:LegendInfo = {
			title: legendTitle,
			subTitle: {text: "Subtitle"},
			position: LegendPosition.bottom,
			useLegend: true,
			nodeStyle: nodeStyling,
			data: [
				{text: "Series 1", style: {symbol: LegendSymbols.line, symbolColor: 0x0000FF}},
				{text: "Series 2"} // Style will be default
			]
		};

		Assert.notNull(info);
		Assert.equals("Test Title", info.title.text);
		Assert.equals("Subtitle", info.subTitle.text);
		Assert.equals(LegendPosition.bottom, info.position);
		Assert.isTrue(info.useLegend);
		Assert.notNull(info.nodeStyle);
		Assert.equals(LegendSymbols.rectangle, info.nodeStyle.symbol);
		Assert.equals(0xFF0000, info.nodeStyle.symbolColor);
		// Assert.equals(0x00FF00, info.nodeStyle.textColor); // This field does not exist on LegendNodeStyling
		// Assert.equals(12, info.nodeStyle.textSize); // This field does not exist on LegendNodeStyling
		Assert.equals(2, info.data.length);
		Assert.equals("Series 1", info.data[0].text);
		Assert.equals(LegendSymbols.line, info.data[0].style.symbol);
	}

	public function testOptionalFields() {
		var infoMinimal:LegendInfo = {
			useLegend: false
		};
		Assert.notNull(infoMinimal);
		Assert.isFalse(infoMinimal.useLegend);
		Assert.isNull(infoMinimal.title);
		Assert.isNull(infoMinimal.subTitle);
		Assert.isNull(infoMinimal.position); // Should default in Legend class, not here
		Assert.isNull(infoMinimal.nodeStyle); // Should default in Legend class, not here
		Assert.isNull(infoMinimal.data);

		var nodeStylingNoColor:LegendNodeStyling = {symbol: LegendSymbols.point};
		var infoWithNodeStyle:LegendInfo = {
			useLegend: true,
			nodeStyle: nodeStylingNoColor
		};
		Assert.notNull(infoWithNodeStyle.nodeStyle);
		Assert.equals(LegendSymbols.point, infoWithNodeStyle.nodeStyle.symbol);
		Assert.isNull(infoWithNodeStyle.nodeStyle.symbolColor); // Optional
	}
}
