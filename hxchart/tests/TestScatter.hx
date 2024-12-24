package hxchart.tests;

import haxe.Exception;
import hxchart.basics.data.Data2D;
import hxchart.basics.colors.ColorPalettes;
import hxchart.basics.axis.StringTickInfo;
import hxchart.basics.axis.TickInfo;
import hxchart.basics.axis.NumericTickInfo;
import hxchart.basics.axis.Axis.AxisTypes;
import hxchart.basics.plot.Plot.TrailTypes;
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
		scatter = new Scatter({
			data: {
				xValues: [2, 0, 1],
				yValues: [1, 2, 3]
			},
			axisInfo: [
				{
					type: linear
				},
				{
					type: linear
				}
			],
			type: TrailTypes.scatter,
			style: {
				colorPalette: ColorPalettes.defaultColors(1),
				groups: ["1" => 0]
			}
		}, parent, "chart", "axis");
	}

	function testSetData() {
		scatter.setData({
			xValues: [1, 2],
			yValues: [1, 2]
		}, {
			colorPalette: ColorPalettes.defaultColors(1),
			groups: ["1" => 0]
		});
		Assert.equals(1, scatter.data[0].xValue);
		Assert.equals(1, scatter.data[0].yValue);

		scatter.setData(scatter.chartInfo.data, scatter.chartInfo.style);
		Assert.equals(2, scatter.data[0].xValue);
		Assert.equals(1, scatter.data[0].yValue);
		Assert.equals(3, scatter.data.length);
		Assert.equals(3, scatter.colors.length);
		Assert.equals(0, scatter.colors[2]);
	}

	function testSortData() {
		scatter.setData(scatter.chartInfo.data, scatter.chartInfo.style);
		Assert.equals(0, scatter.minX);
		Assert.equals(2, scatter.maxX);
		Assert.equals(1, scatter.minY);
		Assert.equals(3, scatter.maxY);
	}

	function testSetTickInfo() {
		var info = scatter.setTickInfo(AxisTypes.linear, [], [1, 2, 3], 1, 3);
		Assert.isOfType(info, TickInfo);
		Assert.isOfType(info, NumericTickInfo);

		var info = scatter.setTickInfo(AxisTypes.categorical, [], ["1", "2", "3"], null, null);
		Assert.isOfType(info, TickInfo);
		Assert.isOfType(info, StringTickInfo);

		var info = scatter.setTickInfo(AxisTypes.linear, [1, 2], [1, 2, 3], 1, 3);
		Assert.equals("2", info.labels[info.labels.length - 1]);
	}

	@:depends(testSetData, testSetTickInfo)
	function testPositionAxes() {
		scatter.setData(scatter.chartInfo.data, scatter.chartInfo.style);
		scatter.positionAxes(scatter.chartInfo.axisInfo, scatter.data, {});
		Assert.equals(2, scatter.axes.length);
		Assert.equals(90, scatter.axes[0].axisLength);
		Assert.equals(5, scatter.axes[0].startPoint.x);
		Assert.equals(-10, scatter.axes[0].startPoint.y);
	}

	@:depends(testPositionAxes)
	function testPositionData() {
		scatter.setData(scatter.chartInfo.data, scatter.chartInfo.style);
		scatter.positionAxes(scatter.chartInfo.axisInfo, scatter.data, {});
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
