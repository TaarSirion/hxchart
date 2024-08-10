package hxchart.tests;

import hxchart.basics.points.Points;
import hxchart.basics.pointchart.ChartTools;
import hxchart.basics.pointchart.Chart;
import utest.Assert;

class TestChart extends utest.Test {
	function testPadding() {
		var chart = new Chart();
		chart.paddingTop = 10;

		Assert.equals(0, chart.paddingTop);
		Assert.equals(10, chart.chartPoint.y);
		Assert.equals(10, chart.axisPaddingT);
		Assert.equals(0, chart.axisPaddingB);
	}

	function testSortPoints() {
		var chart = new Chart();
		chart.points = new Points();
		chart.setPoints({
			x_points: [2, 1, 3],
			y_points: [1, 2, 3]
		});
		chart.sortPoints();
		Assert.equals(3, chart.max_x);
		Assert.equals(1, chart.min_x);
	}

	function testGroups() {
		var chart = new Chart();
		chart.points = new Points();
		chart.setPoints({
			x_points: [2, 1, 3],
			y_points: [1, 2, 3],
			groups: ["A", "A", "B"]
		});
		Assert.equals(2, chart.countGroups);
		Assert.equals(1, chart.point_groups.get("B"));
	}

	function testCalcAxisDists() {
		var dists = ChartTools.calcAxisDists(0, 100, 0.6);

		Assert.equals(60, dists.pos_dist);
		Assert.equals(40, dists.neg_dist);
	}
}
