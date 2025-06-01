package hxchart.tests;

import utest.Assert;
import utest.Test;
import hxchart.core.trails.Scatter;
import hxchart.core.trails.TrailInfo;
import hxchart.core.trails.TrailTypes;
import hxchart.core.data.DataLayer.TrailData; // Import for TrailData
import hxchart.core.axis.Axis;
import hxchart.core.axis.AxisInfo;
import hxchart.core.axis.AxisTypes;
import hxchart.core.tickinfo.NumericTickInfo;
import hxchart.core.utils.CoordinateSystem;
import hxchart.core.utils.Point;
// import hxchart.haxeui.colors.ColorPalettes; // Removed HaxeUI import
import hxchart.core.styling.TrailStyle;

class TestScatter extends Test {
	public function new() {
		super();
	}

	function testCalculateCoordinates() {
		// Setup TrailStyle
		var trailStyle:TrailStyle = {
			colorPalette: [0x000000], // Using a hardcoded black color
			groups: ["A" => 0]
			// positionOption, size, alpha, borderStyle are optional
		};

		// Setup TickInfo for X and Y axes
		// Constructor requires a Map: new NumericTickInfo(values:Map<String, Array<Float>>, ...)
		var xValues:Map<String, Array<Float>> = new Map<String, Array<Float>>();
		xValues.set("min", [0.]);
		xValues.set("max", [10.]);
		var xTickInfo = new NumericTickInfo(xValues);
		// xTickInfo.dataInterval = 5; // This field does not exist

		var yValues:Map<String, Array<Float>> = new Map<String, Array<Float>>();
		yValues.set("min", [0.]);
		yValues.set("max", [10.]);
		var yTickInfo = new NumericTickInfo(yValues);
		// yTickInfo.dataInterval = 5; // This field does not exist

		// Setup AxisInfo for X and Y axes
		var xaxisInfo:AxisInfo = {
			type: AxisTypes.linear,
			rotation: 0,
			id: "xaxis",
			tickInfo: xTickInfo,
			title: {text: "X-Axis"}, // Assuming AxisTitle object
			// labelRotation: 0, // Extra field
			// tickLabelOffset: { x: 0, y: 0 }, // Extra field
			// axisProportion: 0, // Extra field
			// mainAxisProportion: 0, // Extra field
			// crossAxisProportion: 0 // Extra field
		};

		var yaxisInfo:AxisInfo = {
			type: AxisTypes.linear,
			rotation: 90,
			id: "yaxis",
			tickInfo: yTickInfo,
			title: {text: "Y-Axis"}, // Assuming AxisTitle object
			// labelRotation: 0, // Extra field
			// tickLabelOffset: { x: 0, y: 0 }, // Extra field
			// axisProportion: 0, // Extra field
			// mainAxisProportion: 0, // Extra field
			// crossAxisProportion: 0 // Extra field
		};

		// Setup ChartInfo (TrailInfo)
		var chartInfoDataValues:Map<String, Array<Any>> = new Map<String, Array<Any>>();
		chartInfoDataValues.set("x", [0., 5., 10.]);
		chartInfoDataValues.set("y", [0., 5., 10.]);
		chartInfoDataValues.set("groups", ["A", "A", "A"]);

		var chartData:TrailData = {values: chartInfoDataValues};

		var chartInfo:TrailInfo = {
			data: chartData,
			axisInfo: [xaxisInfo, yaxisInfo],
			type: TrailTypes.scatter,
			style: trailStyle,
			optimizationInfo: null
		};

		// Setup CoordinateSystem and Axis
		var coordSystem = new CoordinateSystem();
		coordSystem.width = 100;
		coordSystem.height = 100;

		var axes = new Axis(chartInfo.axisInfo, coordSystem);
		axes.positionStartPoint();
		axes.setTicks(false);

		// Instantiate Scatter
		var scatter = new Scatter(chartInfo, axes, "axis1");

		// Set data and position data (this calculates the coordinates)
		scatter.setData(chartInfo.data, chartInfo.style);
		scatter.positionData(chartInfo.style);

		// Assertions
		// AXIS_PADDING_START and AXIS_PADDING_END are 10 by default in Axis.hx
		// Effective drawing width/height = 100 - 10 - 10 = 80.
		// Origin (axes.coordSystem.x, axes.coordSystem.y) is (10,10)

		// X-axis: data 0-10 maps to screen 10 (axes.coordSystem.x) to 90 (axes.coordSystem.x + axes.coordSystem.width)
		// Y-axis: data 0-10 maps to screen 90 (axes.coordSystem.y + axes.coordSystem.height) to 10 (axes.coordSystem.y) (inverted Y)

		// Expected coordinates:
		// Point (0,0) maps to screen (10, 90)
		Assert.floatEquals(22, scatter.dataByGroup[0][0].coord.x, 0.001, "X coord for data point (0,0) was: " + scatter.dataByGroup[0][0].coord.x);
		Assert.floatEquals(22, scatter.dataByGroup[0][0].coord.y, 0.001, "Y coord for data point (0,0) was: " + scatter.dataByGroup[0][0].coord.y);

		// Point (5,5) maps to screen (10 + 80/2, 90 - 80/2) = (50, 50)
		Assert.floatEquals(56, scatter.dataByGroup[0][1].coord.x, 0.001, "X coord for data point (5,5) was: " + scatter.dataByGroup[0][1].coord.x);
		Assert.floatEquals(56, scatter.dataByGroup[0][1].coord.y, 0.001, "Y coord for data point (5,5) was: " + scatter.dataByGroup[0][1].coord.y);

		// Point (10,10) maps to screen (90, 10)
		Assert.floatEquals(90, scatter.dataByGroup[0][2].coord.x, 0.001, "X coord for data point (10,10) was: " + scatter.dataByGroup[0][2].coord.x);
		Assert.floatEquals(90, scatter.dataByGroup[0][2].coord.y, 0.001, "Y coord for data point (10,10) was: " + scatter.dataByGroup[0][2].coord.y);
	}
}
