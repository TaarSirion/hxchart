package hxchart.tests;

import hxchart.basics.axis.Axis.AxisInfo;
import haxe.Exception;
import hxchart.basics.data.Data2D;
import hxchart.basics.colors.ColorPalettes;
import hxchart.basics.axis.StringTickInfo;
import hxchart.basics.axis.TickInfo;
import hxchart.basics.axis.NumericTickInfo;
import hxchart.basics.axis.Axis.AxisTypes;
import hxchart.basics.plot.Chart.TrailTypes;
import utest.Assert;
import haxe.ui.containers.Absolute;
import hxchart.basics.trails.Scatter;
import utest.Test;

class TestScatter extends Test {
	var scatter:Scatter;
	var parent:Absolute;

	public function setup() {
		parent = new Absolute();
		parent.width = 100;
		parent.height = 100;
		var xaxis:AxisInfo = {
			type: linear,
			id: "xaxis"
		};
		xaxis.setAxisInfo([2, 0, 1]);
		var yaxis:AxisInfo = {
			type: linear,
			id: "yaxis"
		};
		yaxis.setAxisInfo([1, 2, 3]);
		scatter = new Scatter({
			data: {
				values: ["x" => [2, 0, 1], "y" => [1, 2, 3], "groups" => ["1", "1", "1"]]
			},
			axisInfo: [xaxis, yaxis],
			type: TrailTypes.scatter,
			style: {
				colorPalette: ColorPalettes.defaultColors(1),
				groups: ["1" => 0]
			}
		}, parent, "chart", "axis", {});
	}

	function testSetData() {
		scatter.setData({
			values: ["x" => [1, 2], "y" => [1, 2], "groups" => ["1", "1"]]
		}, {
			colorPalette: ColorPalettes.defaultColors(1),
			groups: ["1" => 0]
		});
		Assert.equals(2, scatter.dataByGroup[0][0].size);
		Assert.equals(1, scatter.dataByGroup[0][0].alpha);
		Assert.equals(1, scatter.dataByGroup[0][0].borderAlpha);
		Assert.equals(1, scatter.dataByGroup[0][0].borderThickness);

		scatter.setData({
			values: ["x" => [1, 2], "y" => [1, 2], "groups" => ["1", "1"]]
		}, {
			colorPalette: ColorPalettes.defaultColors(1),
			size: 3,
			alpha: 0.5,
			borderStyle: {
				thickness: 2,
				alpha: 0.3
			},
			groups: ["1" => 0]
		});
		Assert.equals(3, scatter.dataByGroup[0][0].size);
		Assert.equals(0.5, scatter.dataByGroup[0][0].alpha);
		Assert.equals(0.3, scatter.dataByGroup[0][0].borderAlpha);
		Assert.equals(2, scatter.dataByGroup[0][0].borderThickness);

		scatter.setData({
			values: ["x" => [1, 2], "y" => [1, 2], "groups" => ["1", "1"]]
		}, {
			size: 2,
			colorPalette: ColorPalettes.defaultColors(1),
			groups: ["1" => 0]
		});
		Assert.equals(1, scatter.dataByGroup[0][0].values.x);
		Assert.equals(1, scatter.dataByGroup[0][0].values.y);

		scatter.setData(scatter.chartInfo.data, scatter.chartInfo.style);
		Assert.equals(2, scatter.dataByGroup[0][0].values.x);
		Assert.equals(1, scatter.dataByGroup[0][0].values.y);
		Assert.equals(3, scatter.dataByGroup[0].length);
		Assert.equals(0, scatter.dataByGroup[0][2].color);
	}

	function testSortData() {
		scatter.setData(scatter.chartInfo.data, scatter.chartInfo.style);
		Assert.equals(0, scatter.minX);
		Assert.equals(2, scatter.maxX);
		Assert.equals(1, scatter.minY);
		Assert.equals(3, scatter.maxY);
	}

	@:depends(testSetData)
	function testPositionAxes() {
		scatter.setData(scatter.chartInfo.data, scatter.chartInfo.style);
		scatter.positionAxes(scatter.chartInfo.axisInfo, scatter.dataByGroup, {});
		Assert.equals(2, scatter.axes.length);
		Assert.equals(90, scatter.axes[0].axisLength);
		Assert.equals(5, scatter.axes[0].startPoint.x);
		Assert.equals(-10, scatter.axes[0].startPoint.y);
	}

	@:depends(testPositionAxes)
	function testPositionData() {
		scatter.setData(scatter.chartInfo.data, scatter.chartInfo.style);
		scatter.positionAxes(scatter.chartInfo.axisInfo, scatter.dataByGroup, {});
		scatter.positionData({
			colorPalette: ColorPalettes.defaultColors(1),
			groups: ["1" => 0]
		});
		Assert.notNull(parent.findComponent("chart"));
		scatter.axes = [];
		Assert.raises(function() {
			scatter.positionData({
				colorPalette: ColorPalettes.defaultColors(1),
				groups: ["1" => 0]
			});
		}, Exception);
	}
}
