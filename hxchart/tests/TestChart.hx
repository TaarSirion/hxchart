package hxchart.tests;

import haxe.ui.util.Color;
import utest.Assert;
import hxchart.basics.plot.Chart;
import utest.Test;

class TestChart extends Test {
	function testSimpleChart() {
		var chart = new Chart({
			data: {
				xValues: [1],
				yValues: [1]
			},
			type: scatter
		});
		Assert.equals(1, chart.trailInfos[0].data.xValues[0]);
		Assert.equals(scatter, chart.trailInfos[0].type);
	}

	function testChartWithLegend() {
		var chart = new Chart({
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
		Assert.equals("Title", chart.legendInfo.title);
		Assert.equals("Title", chart.legend.legendTitle);
	}

	function testChartWithAlternativeData() {
		Assert.raises(function() {
			new Chart({
				data: {
					values: ["x" => [1, 2], "y" => [3, 4]]
				},
				type: scatter
			});
		});

		Assert.raises(function() {
			new Chart({
				data: {
					values: ["x" => [1, 2], "y" => [3, 4]]
				},
				x: "x",
				type: scatter
			});
		});

		Assert.raises(function() {
			new Chart({
				data: {
					values: ["x" => [1, 2], "y" => [3, 4]]
				},
				y: "y",
				type: scatter
			});
		});

		Assert.raises(function() {
			new Chart({
				data: {
					values: ["y" => [3, 4]],
					xValues: [1, 2]
				},
				type: scatter
			});
		});

		Assert.raises(function() {
			new Chart({
				data: {
					values: ["x" => [3, 4]],
					yValues: [1, 2]
				},
				type: scatter
			});
		});

		var chart = new Chart({
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
		}, chart.trailInfos[0].data);

		var chart = new Chart({
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
		}, chart.trailInfos[0].data);
	}

	function testChartGroups() {
		var chart = new Chart({
			data: {
				groups: ["A", "B"],
				yValues: [1, 2],
				xValues: [3, 4]
			},
			type: scatter
		});
		Assert.isTrue(chart.groups.exists("A"));
		Assert.equals(2, chart.groupNumber);

		var chart = new Chart({
			data: {
				values: ["groups" => ["A", "B"]],
				yValues: [1, 2],
				xValues: [3, 4]
			},
			type: scatter
		});
		Assert.isTrue(chart.groups.exists("A"));
		Assert.equals(2, chart.groupNumber);

		var chart = new Chart({
			data: {
				yValues: [1, 2],
				xValues: [3, 4]
			},
			type: scatter
		});
		Assert.isTrue(chart.groups.exists("1"));
		Assert.equals(1, chart.groupNumber);
	}

	function testStyle() {
		var chart = new Chart({
			data: {
				yValues: [1, 2],
				xValues: [3, 4]
			},
			type: scatter
		});
		Assert.contains(Color.fromString("black").toInt(), chart.trailInfos[0].style.colorPalette);

		var chart = new Chart({
			data: {
				values: ["groups" => ["A", "B"]],
				yValues: [1, 2],
				xValues: [3, 4]
			},
			type: scatter
		});
		Assert.contains(Color.fromString("orange").toInt(), chart.trailInfos[0].style.colorPalette);
	}
}
