package hxchart.tests;

import hxchart.core.tick.Tick;
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
import hxchart.core.coordinates.CoordinateSystem;
import hxchart.core.utils.Point;
import hxchart.core.styling.TrailStyle;

class TestScatter extends Test {
	public function new() {
		super();
	}

	function testCalculateCoordinatesWithTitle() {
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

		var yValues:Map<String, Array<Float>> = new Map<String, Array<Float>>();
		yValues.set("min", [0.]);
		yValues.set("max", [10.]);
		var yTickInfo = new NumericTickInfo(yValues);

		// Setup AxisInfo for X and Y axes
		var xaxisInfo:AxisInfo = {
			type: AxisTypes.linear,
			rotation: 0,
			id: "xaxis",
			tickInfo: xTickInfo,
			title: {text: "X-Axis"}, // Assuming AxisTitle object
		};

		var yaxisInfo:AxisInfo = {
			type: AxisTypes.linear,
			rotation: 90,
			id: "yaxis",
			tickInfo: yTickInfo,
			title: {text: "Y-Axis"}, // Assuming AxisTitle object
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

		var axes = new Axis(chartInfo.axisInfo, coordSystem);
		axes.positionStartPoint();
		axes.setTicks(false);

		// Instantiate Scatter
		var scatter = new Scatter(chartInfo, axes, coordSystem);

		// Set data and position data (this calculates the coordinates)
		scatter.setData(chartInfo.data, chartInfo.style);
		scatter.positionData(chartInfo.style);

		// Assertions
		// coordSystem.width = 100, coordSystem.height = 100.
		// AxisInfo.tickMargin = 10 (default).
		// Axis.titleSpace = 12 (constant in Axis.hx).
		// Both X and Y axes have titles.

		// 1. Initial zeroPoint = (100/2, 100/2) = (50,50).
		// 2. zeroPoint adjusted by tickInfo (0-10 range, 5 ticks, zeroIndex=0, tickMargin=10):
		//    zeroPoint.x = 0 * 100/(5-1) + 0 + 10 = 10.
		//    zeroPoint.y = 0 * 100/(5-1) + 0 + 10 = 10.
		//    Current zeroPoint = (10,10).
		// 3. Title space adjustment (titleSpace=12):
		//    X-axis title: newHeight = 100-12=88. zeroPoint.y = 0+(100-88)+10 = 22. zeroPoint=(10,22).
		//    Y-axis title: newWidth = 100-12=88. zeroPoint.x = 0+(100-88)+10 = 22. zeroPoint=(22,22).
		// 4. Axis start positions and lengths:
		//    X-axis: start=(0+(100-88), 22)=(12,22), length=88.
		//    Y-axis: start=(22, 0+(100-88))=(22,12), length=88.
		// 5. Data mapping area (after tickMargins):
		//    X-axis: from start.x+tickMargin (12+10=22) to start.x+length-tickMargin (12+88-10=90). Effective width: 68.
		//    Y-axis: from start.y+tickMargin (12+10=22) to start.y+length-tickMargin (12+88-10=90). Effective height: 68.
		// Ticks for 0-10 data (0, 2.5, 5, 7.5, 10) map to screen coordinates:
		// X-coords: 22 (for 0), 39 (for 2.5), 56 (for 5), 73 (for 7.5), 90 (for 10).
		// Y-coords: 22 (for 0), 39 (for 2.5), 56 (for 5), 73 (for 7.5), 90 (for 10).

		// Expected screen coordinates for data points:
		// Data (0,0) -> Screen (22, 22)
		// Data (5,5) -> Screen (56, 56)
		// Data (10,10) -> Screen (90, 90)
		// Point (0,0)
		Assert.floatEquals(22, scatter.dataByGroup[0][0].coord.x, 0.001, "X coord for data point (0,0) was: " + scatter.dataByGroup[0][0].coord.x);
		Assert.floatEquals(22, scatter.dataByGroup[0][0].coord.y, 0.001, "Y coord for data point (0,0) was: " + scatter.dataByGroup[0][0].coord.y);

		// Point (5,5)
		Assert.floatEquals(56, scatter.dataByGroup[0][1].coord.x, 0.001, "X coord for data point (5,5) was: " + scatter.dataByGroup[0][1].coord.x);
		Assert.floatEquals(56, scatter.dataByGroup[0][1].coord.y, 0.001, "Y coord for data point (5,5) was: " + scatter.dataByGroup[0][1].coord.y);

		// Point (10,10)
		Assert.floatEquals(90, scatter.dataByGroup[0][2].coord.x, 0.001, "X coord for data point (10,10) was: " + scatter.dataByGroup[0][2].coord.x);
		Assert.floatEquals(90, scatter.dataByGroup[0][2].coord.y, 0.001, "Y coord for data point (10,10) was: " + scatter.dataByGroup[0][2].coord.y);
	}

	function testCalculateCoordinatesNoTitle() {
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

		var yValues:Map<String, Array<Float>> = new Map<String, Array<Float>>();
		yValues.set("min", [0.]);
		yValues.set("max", [10.]);
		var yTickInfo = new NumericTickInfo(yValues);

		// Setup AxisInfo for X and Y axes
		var xaxisInfo:AxisInfo = {
			type: AxisTypes.linear,
			rotation: 0,
			id: "xaxis",
			tickInfo: xTickInfo
		};

		var yaxisInfo:AxisInfo = {
			type: AxisTypes.linear,
			rotation: 90,
			id: "yaxis",
			tickInfo: yTickInfo
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

		var axes = new Axis(chartInfo.axisInfo, coordSystem);
		axes.positionStartPoint();
		axes.setTicks(false);

		// Instantiate Scatter
		var scatter = new Scatter(chartInfo, axes, coordSystem);

		// Set data and position data (this calculates the coordinates)
		scatter.setData(chartInfo.data, chartInfo.style);
		scatter.positionData(chartInfo.style);

		// Point (0,0)
		Assert.floatEquals(10, scatter.dataByGroup[0][0].coord.x, 0.001, "X coord for data point (0,0) was: " + scatter.dataByGroup[0][0].coord.x);
		Assert.floatEquals(10, scatter.dataByGroup[0][0].coord.y, 0.001, "Y coord for data point (0,0) was: " + scatter.dataByGroup[0][0].coord.y);

		// Point (5,5)
		Assert.floatEquals(50, scatter.dataByGroup[0][1].coord.x, 0.001, "X coord for data point (5,5) was: " + scatter.dataByGroup[0][1].coord.x);
		Assert.floatEquals(50, scatter.dataByGroup[0][1].coord.y, 0.001, "Y coord for data point (5,5) was: " + scatter.dataByGroup[0][1].coord.y);

		// Point (10,10)
		Assert.floatEquals(90, scatter.dataByGroup[0][2].coord.x, 0.001, "X coord for data point (10,10) was: " + scatter.dataByGroup[0][2].coord.x);
		Assert.floatEquals(90, scatter.dataByGroup[0][2].coord.y, 0.001, "Y coord for data point (10,10) was: " + scatter.dataByGroup[0][2].coord.y);
	}

	// --- Tests for calcXCoord ---

	function createTick(label:String, pos:Float) {
		var tick = new Tick();
		tick.text = label;
		tick.middlePos = new Point(pos, 0);
		return tick;
	}

	function testCalcXCoord_StringValue_MatchFound() {
		var chartInfo:TrailInfo = {
			data: {
				values: ["x" => ["A", "B", "C"], "y" => [1, 2, 3]]
			},
			type: scatter
		}
		var coordSystem = new CoordinateSystem();
		var scatter = new Scatter(chartInfo, null, coordSystem);

		var ticks:Array<Tick> = [createTick("A", 10), createTick("B", 20)];

		var result = scatter.calcXCoord("A", ticks);
		Assert.notNull(result, "Result should not be null for match found");
		Assert.floatEquals(10, result, 0.001);
	}

	function testCalcXCoord_StringValue_NoMatch() {
		var chartInfo:TrailInfo = {
			data: {
				values: ["x" => ["A", "B", "C"], "y" => [1, 2, 3]]
			},
			type: scatter
		}
		var coordSystem = new CoordinateSystem();
		var scatter = new Scatter(chartInfo, null, coordSystem);
		var ticks:Array<Tick> = [createTick("A", 10), createTick("B", 20)];
		var result = scatter.calcXCoord("C", ticks);
		Assert.isNull(result, "Result should be null for no match");
	}

	function testCalcXCoord_FloatValue_ExactMatch() {
		var chartInfo:TrailInfo = {
			data: {
				values: ["x" => ["A", "B", "C"], "y" => [1, 2, 3]]
			},
			type: scatter
		}
		var coordSystem = new CoordinateSystem();
		var scatter = new Scatter(chartInfo, null, coordSystem);
		var ticks:Array<Tick> = [createTick("0", 0), createTick("5", 50), createTick("10", 100)];
		var result = scatter.calcXCoord(5.0, ticks);
		Assert.notNull(result, "Result should not be null for exact match");
		Assert.floatEquals(50.0, result, 0.001);
	}

	function testCalcXCoord_FloatValue_BetweenTicks() {
		var chartInfo:TrailInfo = {
			data: {
				values: ["x" => ["A", "B", "C"], "y" => [1, 2, 3]]
			},
			type: scatter
		}
		var coordSystem = new CoordinateSystem();
		var scatter = new Scatter(chartInfo, null, coordSystem);
		var ticks1:Array<Tick> = [createTick("0", 0), createTick("10", 100)];

		var result1 = scatter.calcXCoord(5.0, ticks1);
		Assert.notNull(result1, "Result1 should not be null");
		Assert.floatEquals(50.0, result1, 0.001, "Failed for 5.0 between 0 and 10");

		var ticks2:Array<Tick> = [createTick("10", 20), createTick("20", 40)];

		var result2 = scatter.calcXCoord(15.0, ticks2);
		Assert.notNull(result2, "Result2 should not be null");
		Assert.floatEquals(30.0, result2, 0.001, "Failed for 15.0 between 10 and 20");
	}

	function testCalcXCoord_FloatValue_OutsideLower() {
		var chartInfo:TrailInfo = {
			data: {
				values: ["x" => ["A", "B", "C"], "y" => [1, 2, 3]]
			},
			type: scatter
		}
		var coordSystem = new CoordinateSystem();
		var scatter = new Scatter(chartInfo, null, coordSystem);
		var ticks:Array<Tick> = [createTick("10", 100), createTick("20", 200)];

		var result = scatter.calcXCoord(5.0, ticks);
		Assert.notNull(result, "Result should not be null for outside lower");
		// Expected behavior: returns the x-coordinate of the first tick if value is less than all tick values.
		Assert.floatEquals(100.0, result, 0.001);
	}

	function testCalcXCoord_FloatValue_OutsideUpper_MaxTickValue() {
		var chartInfo:TrailInfo = {
			data: {
				values: ["x" => ["A", "B", "C"], "y" => [1, 2, 3]]
			},
			type: scatter
		}
		var coordSystem = new CoordinateSystem();
		var scatter = new Scatter(chartInfo, null, coordSystem);
		var ticks:Array<Tick> = [createTick("0", 0), createTick("10", 100)];

		var result = scatter.calcXCoord(10.0, ticks); // Value is the max tick value
		Assert.notNull(result, "Result should not be null for outside upper (max tick value)");
		Assert.floatEquals(100.0, result, 0.001);
	}

	function testCalcXCoord_FloatValue_SingleTick_ValueLETick() {
		var chartInfo:TrailInfo = {
			data: {
				values: ["x" => ["A", "B", "C"], "y" => [1, 2, 3]]
			},
			type: scatter
		}
		var coordSystem = new CoordinateSystem();
		var scatter = new Scatter(chartInfo, null, coordSystem);
		var ticks:Array<Tick> = [createTick("5", 50)];
		var result1 = scatter.calcXCoord(5.0, ticks);
		Assert.notNull(result1, "Result should not be null for single tick, value equals tick");
		Assert.floatEquals(50.0, result1, 0.001, "Failed for single tick, value equals tick");

		var result2 = scatter.calcXCoord(2.0, ticks);
		Assert.notNull(result2, "Result should not be null for single tick, value less than tick");
		Assert.floatEquals(50.0, result2, 0.001, "Failed for single tick, value less than tick");
	}
}
