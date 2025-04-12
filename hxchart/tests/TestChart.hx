package hxchart.tests;

import haxe.ui.util.Color;
import utest.Assert;
import hxchart.basics.plot.Chart;
import utest.Test;

class TestChart extends Test {
	function testSimpleChart() {
		var chart = new Chart({
			data: {
				values: ["x" => [1], "y" => [1]]
			},
			type: scatter
		});
		Assert.equals(1, chart.trailInfos[0].data.values.get("x")[0]);
		Assert.equals(scatter, chart.trailInfos[0].type);
	}

	function testChartWithLegend() {
		var chart = new Chart({
			data: {
				values: ["x" => [1], "y" => [1]]
			},
			type: scatter
		}, {
			title: {
				text: "Title"
			},
			useLegend: true
		});
		Assert.equals("Title", chart.legendInfo.title.text);
		Assert.equals("Title", chart.legend.legendTitle);
	}

	function testChartWithAlternativeData() {
		Assert.raises(function() {
			new Chart({
				data: {
					values: []
				},
				type: scatter
			});
		});

		Assert.raises(function() {
			new Chart({
				data: {
					values: ["y" => [3, 4]]
				},
				type: scatter
			});
		});

		Assert.raises(function() {
			new Chart({
				data: {
					values: ["x" => [1, 2]]
				},
				type: scatter
			});
		});
	}

	function testChartGroups() {
		var chart = new Chart({
			data: {
				values: ["groups" => ["A", "B"], "y" => [1, 2], "x" => [3, 4]]
			},
			type: scatter
		});
		Assert.isTrue(chart.groups.exists("A"));
		Assert.equals(2, chart.groupNumber);

		var chart = new Chart({
			data: {
				values: ["y" => [1, 2], "x" => [3, 4]]
			},
			type: scatter
		});
		Assert.isTrue(chart.groups.exists("1"));
		Assert.equals(1, chart.groupNumber);
	}

	function testStyle() {
		var chart = new Chart({
			data: {
				values: ["y" => [1, 2], "x" => [3, 4]]
			},
			type: scatter
		});
		Assert.contains(Color.fromString("black").toInt(), chart.trailInfos[0].style.colorPalette);

		var chart = new Chart({
			data: {
				values: ["groups" => ["A", "B"], "y" => [1, 2], "x" => [3, 4]]
			},
			type: scatter
		});
		Assert.contains(Color.fromString("orange").toInt(), chart.trailInfos[0].style.colorPalette);
	}
}
