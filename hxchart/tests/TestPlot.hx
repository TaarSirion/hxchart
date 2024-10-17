package hxchart.tests;

import utest.Assert;
import hxchart.basics.plot.Plot;
import utest.Test;

class TestPlot extends Test {
	function testSimplePlot() {
		var plot = new Plot({
			data: {
				xValues: [1],
				yValues: [1]
			},
			type: scatter
		}, 100, 100);
		Assert.equals(1, plot.chartInfos[0].data.xValues[0]);
		Assert.equals(scatter, plot.chartInfos[0].type);
	}

	function testPlotWithLegend() {
		var plot = new Plot({
			data: {
				xValues: [1],
				yValues: [1]
			},
			type: scatter
		}, 100, 100, {
			title: "Title",
			useLegend: true,
			nodeFontSize: 5
		});
		Assert.equals("Title", plot.legendInfo.title);
		Assert.equals("Title", plot.legend.legendTitle);
	}
}
