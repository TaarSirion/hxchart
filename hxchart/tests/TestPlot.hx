package hxchart.tests;

import haxe.ui.util.Color;
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
		});
		Assert.equals(1, plot.trailInfos[0].data.xValues[0]);
		Assert.equals(scatter, plot.trailInfos[0].type);
	}

	function testPlotWithLegend() {
		var plot = new Plot({
			data: {
				xValues: [1],
				yValues: [1]
			},
			type: scatter
		}, {
			title: "Title",
			useLegend: true,
			nodeFontSize: 5
		});
		Assert.equals("Title", plot.legendInfo.title);
		Assert.equals("Title", plot.legend.legendTitle);
	}

	function testPlotWithAlternativeData() {
		Assert.raises(function() {
			new Plot({
				data: {
					values: ["x" => [1, 2], "y" => [3, 4]]
				},
				type: scatter
			});
		});

		Assert.raises(function() {
			new Plot({
				data: {
					values: ["x" => [1, 2], "y" => [3, 4]]
				},
				x: "x",
				type: scatter
			});
		});

		Assert.raises(function() {
			new Plot({
				data: {
					values: ["x" => [1, 2], "y" => [3, 4]]
				},
				y: "y",
				type: scatter
			});
		});

		Assert.raises(function() {
			new Plot({
				data: {
					values: ["y" => [3, 4]],
					xValues: [1, 2]
				},
				type: scatter
			});
		});

		Assert.raises(function() {
			new Plot({
				data: {
					values: ["x" => [3, 4]],
					yValues: [1, 2]
				},
				type: scatter
			});
		});

		var plot = new Plot({
			data: {
				values: ["x" => [1, 2], "y" => [3, 4]]
			},
			x: "x",
			y: "y",
			type: scatter
		});
		Assert.same({
			values: ["x" => [1, 2], "y" => [3, 4]],
			xValues: [1, 2],
			yValues: [3, 4],
			groups: ["1", "1"]
		}, plot.trailInfos[0].data);

		var plot = new Plot({
			data: {
				values: ["x" => [1, 2], "y" => [3, 4]],
				yValues: [1, 2],
				xValues: [3, 4]
			},
			x: "x",
			y: "y",
			type: scatter
		});
		Assert.same({
			values: ["x" => [1, 2], "y" => [3, 4]],
			xValues: [3, 4],
			yValues: [1, 2],
			groups: ["1", "1"]
		}, plot.trailInfos[0].data);
	}

	function testPlotGroups() {
		var plot = new Plot({
			data: {
				groups: ["A", "B"],
				yValues: [1, 2],
				xValues: [3, 4]
			},
			type: scatter
		});
		Assert.isTrue(plot.groups.exists("A"));
		Assert.equals(2, plot.groupNumber);

		var plot = new Plot({
			data: {
				values: ["groups" => ["A", "B"]],
				yValues: [1, 2],
				xValues: [3, 4]
			},
			type: scatter
		});
		Assert.isTrue(plot.groups.exists("A"));
		Assert.equals(2, plot.groupNumber);

		var plot = new Plot({
			data: {
				yValues: [1, 2],
				xValues: [3, 4]
			},
			type: scatter
		});
		Assert.isTrue(plot.groups.exists("1"));
		Assert.equals(1, plot.groupNumber);
	}

	function testStyle() {
		var plot = new Plot({
			data: {
				yValues: [1, 2],
				xValues: [3, 4]
			},
			type: scatter
		});
		Assert.contains(Color.fromString("black").toInt(), plot.trailInfos[0].style.colorPalette);

		var plot = new Plot({
			data: {
				values: ["groups" => ["A", "B"]],
				yValues: [1, 2],
				xValues: [3, 4]
			},
			type: scatter
		});
		Assert.contains(Color.fromString("orange").toInt(), plot.trailInfos[0].style.colorPalette);
	}
}
