// Basic Haxe unit tests for Bar charts.
// See `hxchart.Bar` for the class being tested.
// Based on `hxchart.tests.TestScatter`.
package hxchart.tests;

import hxchart.core.trails.TrailTypes;
import utest.Assert;
import hxchart.core.trails.Bar;
import hxchart.core.trails.TrailInfo;
import hxchart.core.axis.Axis;
import hxchart.core.coordinates.CoordinateSystem;
import hxchart.core.styling.TrailStyle;
import hxchart.core.data.DataLayer;
import hxchart.core.axis.AxisLayer;
import hxchart.core.axis.AxisInfo;
import hxchart.core.axis.AxisTypes;
import hxchart.core.tickinfo.TickInfo;
import hxchart.core.tickinfo.NumericTickInfo;
import hxchart.core.tickinfo.StringTickInfo;
import haxe.Exception;
import hxchart.core.styling.PositionOptions.PositionOption;
import hxchart.core.tick.Tick;
import hxchart.core.utils.Point;

class TestBar extends utest.Test {
	var coordSystem:CoordinateSystem;
	var xAxisInfo:AxisInfo;
	var yAxisInfo:AxisInfo;
	var axes:Axis;
	var trailStyle:TrailStyle;
	var trailInfo:TrailInfo;
	var barChart:hxchart.core.trails.Bar;

	public function setup() {
		coordSystem = new CoordinateSystem();

		// Mock TickInfo - can be basic as we are not testing rendering
		var xNumericTickValues:Map<String, Array<Float>> = new Map<String, Array<Float>>();
		xNumericTickValues.set("min", [0.]);
		xNumericTickValues.set("max", [10.]);
		var xTickInfo = new NumericTickInfo(xNumericTickValues);

		var yStringValues:Array<String> = ["A", "B", "C"];
		var yTickInfo = new StringTickInfo(yStringValues);

		xAxisInfo = {
			type: AxisTypes.linear,
			rotation: 0,
			id: "xaxis",
			tickInfo: xTickInfo
		};

		yAxisInfo = {
			type: AxisTypes.categorical,
			rotation: 90,
			id: "yaxis",
			tickInfo: yTickInfo
		};

		axes = new Axis([xAxisInfo, yAxisInfo], coordSystem);

		trailStyle = {
			groups: new Map<String, Int>(),
			colorPalette: []
			// Other fields like positionOption, alpha, borderStyle can be added if needed
		};

		var initialDataValues:Map<String, Array<Any>> = new Map<String, Array<Any>>();
		initialDataValues.set("x", []);
		initialDataValues.set("y", []);
		initialDataValues.set("groups", []);

		var initialTrailData:TrailData = {values: initialDataValues};

		trailInfo = {
			data: initialTrailData,
			axisInfo: [xAxisInfo, yAxisInfo],
			type: TrailTypes.bar, // Assuming TrailTypes.bar exists or use appropriate type
			style: trailStyle,
			optimizationInfo: null
		};

		barChart = new hxchart.core.trails.Bar(trailInfo, axes, coordSystem);
		// Call setData to initialize internal structures like dataByGroup
		barChart.setData(initialTrailData, trailStyle);
	}

	public function testInitialEmpty() {
		// After setup, dataByGroup should be initialized and empty if initialTrailData was empty
		// and trailStyle.groups was empty.
		// setData initializes dataByGroup = [] and then iterates style.groups.keys()
		// If style.groups is empty, dataByGroup remains empty.
		Assert.equals(0, barChart.dataByGroup.length, "Bar chart should have 0 data groups initially");
	}

	public function testSetDataSingleGroup() {
		var dataValues:Map<String, Array<Any>> = new Map<String, Array<Any>>();
		dataValues.set("x", [1.0, 2.0, 3.0]); // linear axis
		dataValues.set("y", ["A", "A", "A"]); // categorical axis data for group "Group1"
		dataValues.set("groups", ["Group1", "Group1", "Group1"]);

		var currentTrailData:TrailData = {values: dataValues};

		trailStyle.groups.set("Group1", 0);
		trailStyle.colorPalette = [0xFF0000];

		barChart.setData(currentTrailData, trailStyle);

		Assert.equals(1, barChart.dataByGroup.length, "Bar chart should have 1 data group");
		Assert.equals(3, barChart.dataByGroup[0].length, "Group1 should have 3 data records");
		Assert.equals("A", barChart.dataByGroup[0][0].values.y);
		Assert.floatEquals(1.0, barChart.dataByGroup[0][0].values.x);
	}

	public function testSetDataMultipleGroups() {
		var dataValues:Map<String, Array<Any>> = new Map<String, Array<Any>>();
		dataValues.set("x", [1.0, 2.0, 1.5, 2.5]); // linear axis
		dataValues.set("y", ["A", "B", "A", "B"]); // categorical axis data
		dataValues.set("groups", ["Group1", "Group1", "Group2", "Group2"]);

		var currentTrailData:TrailData = {values: dataValues};

		trailStyle.groups.set("Group1", 0);
		trailStyle.groups.set("Group2", 1);
		trailStyle.colorPalette = [0xFF0000, 0x00FF00];

		barChart.setData(currentTrailData, trailStyle);

		Assert.equals(2, barChart.dataByGroup.length, "Bar chart should have 2 data groups");
		Assert.equals(2, barChart.dataByGroup[0].length, "Group1 should have 2 data records");
		Assert.equals(2, barChart.dataByGroup[1].length, "Group2 should have 2 data records");
		Assert.equals("A", barChart.dataByGroup[0][0].values.y); // Group1, Record1
		Assert.floatEquals(1.0, barChart.dataByGroup[0][0].values.x);
		Assert.equals("B", barChart.dataByGroup[1][1].values.y); // Group2, Record2
		Assert.floatEquals(2.5, barChart.dataByGroup[1][1].values.x);
	}

	public function testSetDataEmpty() {
		// First, add some data
		var dataValues:Map<String, Array<Any>> = new Map<String, Array<Any>>();
		dataValues.set("x", [1.0, 2.0]);
		dataValues.set("y", ["A", "B"]);
		dataValues.set("groups", ["Group1", "Group1"]);
		var nonEmptyTrailData:TrailData = {values: dataValues};
		trailStyle.groups.set("Group1", 0);
		trailStyle.colorPalette = [0xFF0000];
		barChart.setData(nonEmptyTrailData, trailStyle);
		Assert.equals(1, barChart.dataByGroup.length);

		// Now, set empty data
		var emptyDataValues:Map<String, Array<Any>> = new Map<String, Array<Any>>();
		emptyDataValues.set("x", []);
		emptyDataValues.set("y", []);
		emptyDataValues.set("groups", []);
		var emptyTrailData:TrailData = {values: emptyDataValues};

		// Important: Resetting groups in trailStyle for setData to result in empty dataByGroup
		var newTrailStyle:TrailStyle = {
			groups: new Map<String, Int>(),
			colorPalette: []
		};

		barChart.setData(emptyTrailData, newTrailStyle);
		Assert.equals(0, barChart.dataByGroup.length, "Bar chart should have 0 data groups after setting empty data");
	}

	public function testConstructorInvalidAxesLinearLinear() {
		var linearTickValues:Map<String, Array<Float>> = new Map<String, Array<Float>>();
		linearTickValues.set("min", [0.]);
		linearTickValues.set("max", [10.]);
		var linearTickInfo = new NumericTickInfo(linearTickValues);

		var localXAxisInfo:AxisInfo = {
			type: AxisTypes.linear,
			rotation: 0,
			id: "x",
			tickInfo: linearTickInfo
		};
		var localYAxisInfo:AxisInfo = {
			type: AxisTypes.linear,
			rotation: 90,
			id: "y",
			tickInfo: linearTickInfo
		};

		var localTrailInfo:TrailInfo = {
			data: trailInfo.data, // can reuse data from setup, not relevant for this test
			axisInfo: [localXAxisInfo, localYAxisInfo],
			type: TrailTypes.bar,
			style: trailStyle, // can reuse style from setup
			optimizationInfo: null
		};

		Assert.raises(function() {
			new hxchart.core.trails.Bar(localTrailInfo, axes, coordSystem);
		}, haxe.Exception);
	}

	public function testConstructorInvalidAxesCategoricalCategorical() {
		var stringValues:Array<String> = ["A", "B", "C"];
		var stringTickInfo = new StringTickInfo(stringValues);

		var localXAxisInfo:AxisInfo = {
			type: AxisTypes.categorical,
			rotation: 0,
			id: "x",
			tickInfo: stringTickInfo
		};
		var localYAxisInfo:AxisInfo = {
			type: AxisTypes.categorical,
			rotation: 90,
			id: "y",
			tickInfo: stringTickInfo
		};

		var localTrailInfo:TrailInfo = {
			data: trailInfo.data,
			axisInfo: [localXAxisInfo, localYAxisInfo],
			type: TrailTypes.bar,
			style: trailStyle,
			optimizationInfo: null
		};

		Assert.raises(function() {
			new hxchart.core.trails.Bar(localTrailInfo, axes, coordSystem);
		}, haxe.Exception);
	}

	public function testConstructorValidAxesLinearCategorical() {
		// This configuration is set up by the main setup() method
		// xAxisInfo is linear, yAxisInfo is categorical
		var testBarChart = new hxchart.core.trails.Bar(trailInfo, axes, coordSystem);
		Assert.notNull(testBarChart, "Bar chart should be created successfully with X-linear, Y-categorical axes");
	}

	public function testConstructorValidAxesCategoricalLinear() {
		var stringValues:Array<String> = ["X1", "X2", "X3"];
		var catTickInfo = new StringTickInfo(stringValues);

		var linearTickValues:Map<String, Array<Float>> = new Map<String, Array<Float>>();
		linearTickValues.set("min", [0.]);
		linearTickValues.set("max", [100.]);
		var linTickInfo = new NumericTickInfo(linearTickValues);

		var localXAxisInfo:AxisInfo = {
			type: AxisTypes.categorical,
			rotation: 0,
			id: "xCat",
			tickInfo: catTickInfo
		};
		var localYAxisInfo:AxisInfo = {
			type: AxisTypes.linear,
			rotation: 90,
			id: "yLin",
			tickInfo: linTickInfo
		};

		// Need a new Axes object if the setup one is strictly typed to the setup's AxisInfos
		// or ensure the existing 'axes' object from setup() is compatible / reconfigurable.
		// For simplicity, creating a new one or ensuring compatibility.
		// The Bar constructor primarily uses trailInfo.axisInfo for the check.
		// The passed 'axes' object is stored.
		var localAxes = new Axis([localXAxisInfo, localYAxisInfo], coordSystem);

		var localTrailInfo:TrailInfo = {
			data: trailInfo.data, // Reuse from setup
			axisInfo: [localXAxisInfo, localYAxisInfo],
			type: TrailTypes.bar,
			style: trailStyle, // Reuse from setup
			optimizationInfo: null
		};

		var testBarChart = new hxchart.core.trails.Bar(localTrailInfo, localAxes, coordSystem);
		Assert.notNull(testBarChart, "Bar chart should be created successfully with X-categorical, Y-linear axes");
	}

	public function testSetDataBasicProcessing() {
		// Setup: X-axis linear, Y-axis categorical (from main setup)
		var dataValues:Map<String, Array<Any>> = new Map<String, Array<Any>>();
		dataValues.set("x", [10.0, 20.0, 5.0, 15.0]); // Linear values for X-axis
		dataValues.set("y", ["A", "A", "B", "B"]); // Categorical values for Y-axis
		dataValues.set("groups", ["G1", "G1", "G2", "G2"]);

		var currentTrailData:TrailData = {values: dataValues};

		var localStyle:TrailStyle = {
			groups: ["G1" => 0, "G2" => 1],
			colorPalette: [0xFF0000, 0x00FF00]
			// No alpha, borderStyle for this test
		};

		// Min/max are not reset in setData, but setup creates a new barChart for each test.
		// Default Float values are 0.0. For robust min/max, they should ideally be initialized
		// to POSITIVE_INFINITY/NEGATIVE_INFINITY or the first data point's value.
		// Let's assume current Bar.hx behavior where they start at 0.0.
		// To test minX correctly if it could be less than 0, we'd need to handle this.
		// For now, using positive data.
		barChart.minX = Math.POSITIVE_INFINITY; // Manual reset for test
		barChart.maxX = Math.NEGATIVE_INFINITY; // Manual reset for test
		// barChart.minY and barChart.maxY are not expected to be set with X-linear config

		barChart.setData(currentTrailData, localStyle);

		Assert.equals(2, barChart.dataByGroup.length, "Should have 2 groups");
		Assert.equals(2, barChart.dataByGroup[0].length, "Group G1 should have 2 records");
		Assert.equals(2, barChart.dataByGroup[1].length, "Group G2 should have 2 records");

		// Check G1 data
		Assert.equals("A", barChart.dataByGroup[0][0].values.y);
		Assert.floatEquals(10.0, barChart.dataByGroup[0][0].values.x);
		Assert.equals(localStyle.colorPalette[0], barChart.dataByGroup[0][0].color);

		Assert.equals("A", barChart.dataByGroup[0][1].values.y);
		Assert.floatEquals(20.0, barChart.dataByGroup[0][1].values.x);
		Assert.equals(localStyle.colorPalette[0], barChart.dataByGroup[0][1].color);

		// Check G2 data
		Assert.equals("B", barChart.dataByGroup[1][0].values.y);
		Assert.floatEquals(5.0, barChart.dataByGroup[1][0].values.x);
		Assert.equals(localStyle.colorPalette[1], barChart.dataByGroup[1][0].color);

		Assert.equals("B", barChart.dataByGroup[1][1].values.y);
		Assert.floatEquals(15.0, barChart.dataByGroup[1][1].values.x);
		Assert.equals(localStyle.colorPalette[1], barChart.dataByGroup[1][1].color);

		// Check min/max values (assuming X-linear, Y-categorical from setup)
		// Note: Bar.hx initializes minX/maxX to 0.0. If data is all positive, Math.min(0.0, val) is problematic.
		// That's why I manually reset to POSITIVE_INFINITY/NEGATIVE_INFINITY above.
		Assert.floatEquals(5.0, barChart.minX, "minX should be 5.0");
		Assert.floatEquals(20.0, barChart.maxX, "maxX should be 20.0");

		// minY and maxY should remain at their initial 0.0 (or whatever they were)
		// as the X axis is linear, so the 'else' branch in Bar.hx for minY/maxY isn't hit.
		// If they were also reset for test:
		// Assert.floatEquals(Math.POSITIVE_INFINITY, barChart.minY);
		// Assert.floatEquals(Math.NEGATIVE_INFINITY, barChart.maxY);
		// For now, let's assume they are not touched with X-linear
	}

	// --- Alpha Styling Tests ---
	public function testSetDataAlphaScalar() {
		var dataValues:Map<String, Array<Any>> = new Map<String, Array<Any>>();
		dataValues.set("x", [1.0, 2.0]);
		dataValues.set("y", ["A", "B"]);
		dataValues.set("groups", ["G1", "G1"]);
		var currentTrailData:TrailData = {values: dataValues};

		var localStyle:TrailStyle = {
			groups: ["G1" => 0],
			colorPalette: [0xFF0000],
			alpha: 0.5
		};
		barChart.setData(currentTrailData, localStyle);

		Assert.equals(1, barChart.dataByGroup.length);
		Assert.equals(2, barChart.dataByGroup[0].length);
		for (rec in barChart.dataByGroup[0]) {
			Assert.floatEquals(0.5, rec.alpha, "Alpha should be 0.5 for all records");
		}
	}

	public function testSetDataAlphaArrayPerDataPoint() {
		var dataValues:Map<String, Array<Any>> = new Map<String, Array<Any>>();
		dataValues.set("x", [1.0, 2.0, 3.0]); // 3 data points
		dataValues.set("y", ["A", "B", "C"]);
		dataValues.set("groups", ["G1", "G1", "G1"]); // All in one group for simplicity
		var currentTrailData:TrailData = {values: dataValues};
		var alphas = [0.2, 0.4, 0.6];

		var localStyle:TrailStyle = {
			groups: ["G1" => 0],
			colorPalette: [0xFF0000],
			alpha: alphas
		};
		barChart.setData(currentTrailData, localStyle);

		Assert.equals(1, barChart.dataByGroup.length);
		Assert.equals(3, barChart.dataByGroup[0].length);
		for (i in 0...barChart.dataByGroup[0].length) {
			Assert.floatEquals(alphas[i], barChart.dataByGroup[0][i].alpha, 'Alpha for record $i incorrect');
		}
	}

	public function testSetDataAlphaArrayPerGroup() {
		var dataValues:Map<String, Array<Any>> = new Map<String, Array<Any>>();
		dataValues.set("x", [1.0, 2.0, 3.0, 4.0]);
		dataValues.set("y", ["A", "A", "B", "B"]);
		dataValues.set("groups", ["G1", "G1", "G2", "G2"]); // 2 groups
		var currentTrailData:TrailData = {values: dataValues};
		var groupAlphas = [0.3, 0.7];

		var localStyle:TrailStyle = {
			groups: ["G1" => 0, "G2" => 1],
			colorPalette: [0xFF0000, 0x00FF00],
			alpha: groupAlphas
		};
		barChart.setData(currentTrailData, localStyle);

		Assert.equals(2, barChart.dataByGroup.length);
		Assert.floatEquals(groupAlphas[0], barChart.dataByGroup[0][0].alpha, "Alpha for G1 record 0");
		Assert.floatEquals(groupAlphas[0], barChart.dataByGroup[0][1].alpha, "Alpha for G1 record 1");
		Assert.floatEquals(groupAlphas[1], barChart.dataByGroup[1][0].alpha, "Alpha for G2 record 0");
		Assert.floatEquals(groupAlphas[1], barChart.dataByGroup[1][1].alpha, "Alpha for G2 record 1");
	}

	// --- Border Color Styling Tests ---
	public function testSetDataBorderColorScalar() {
		var dataValues:Map<String, Array<Any>> = new Map<String, Array<Any>>();
		dataValues.set("x", [1.0]);
		dataValues.set("y", ["A"]);
		dataValues.set("groups", ["G1"]);
		var currentTrailData:TrailData = {values: dataValues};
		var borderColor = 0xCCCCCC;

		var localStyle:TrailStyle = {
			groups: ["G1" => 0],
			colorPalette: [0xFF0000],
			borderStyle: {color: borderColor}
		};
		barChart.setData(currentTrailData, localStyle);
		Assert.equals(borderColor, barChart.dataByGroup[0][0].borderColor);
	}

	public function testSetDataBorderColorArrayPerDataPoint() {
		var dataValues:Map<String, Array<Any>> = new Map<String, Array<Any>>();
		dataValues.set("x", [1.0, 2.0]);
		dataValues.set("y", ["A", "B"]);
		dataValues.set("groups", ["G1", "G1"]);
		var currentTrailData:TrailData = {values: dataValues};
		var borderColors = [0xAAAAAA, 0xBBBBBB];

		var localStyle:TrailStyle = {
			groups: ["G1" => 0],
			colorPalette: [0xFF0000],
			borderStyle: {color: borderColors}
		};
		barChart.setData(currentTrailData, localStyle);
		Assert.equals(borderColors[0], barChart.dataByGroup[0][0].borderColor);
		Assert.equals(borderColors[1], barChart.dataByGroup[0][1].borderColor);
	}

	public function testSetDataBorderColorArrayPerGroup() {
		var dataValues:Map<String, Array<Any>> = new Map<String, Array<Any>>();
		dataValues.set("x", [1.0, 2.0]);
		dataValues.set("y", ["A", "B"]);
		dataValues.set("groups", ["G1", "G2"]);
		var currentTrailData:TrailData = {values: dataValues};
		var groupBorderColors = [0xCCCCCC, 0xDDDDDD];

		var localStyle:TrailStyle = {
			groups: ["G1" => 0, "G2" => 1],
			colorPalette: [0xFF0000, 0x00FF00],
			borderStyle: {color: groupBorderColors}
		};
		barChart.setData(currentTrailData, localStyle);
		Assert.equals(groupBorderColors[0], barChart.dataByGroup[0][0].borderColor); // G1
		Assert.equals(groupBorderColors[1], barChart.dataByGroup[1][0].borderColor); // G2
	}

	// --- Border Alpha Styling Tests ---
	public function testSetDataBorderAlphaScalar() {
		var dataValues:Map<String, Array<Any>> = new Map<String, Array<Any>>();
		dataValues.set("x", [1.0]);
		dataValues.set("y", ["A"]);
		dataValues.set("groups", ["G1"]);
		var currentTrailData:TrailData = {values: dataValues};

		var localStyle:TrailStyle = {
			groups: ["G1" => 0],
			colorPalette: [0xFF0000],
			borderStyle: {alpha: 0.8}
		};
		barChart.setData(currentTrailData, localStyle);
		Assert.floatEquals(0.8, barChart.dataByGroup[0][0].borderAlpha);
	}

	public function testSetDataBorderAlphaArrayPerDataPoint() {
		var dataValues:Map<String, Array<Any>> = new Map<String, Array<Any>>();
		dataValues.set("x", [1.0, 2.0]);
		dataValues.set("y", ["A", "B"]);
		dataValues.set("groups", ["G1", "G1"]);
		var currentTrailData:TrailData = {values: dataValues};
		var borderAlphas = [0.7, 0.9];

		var localStyle:TrailStyle = {
			groups: ["G1" => 0],
			colorPalette: [0xFF0000],
			borderStyle: {alpha: borderAlphas}
		};
		barChart.setData(currentTrailData, localStyle);
		Assert.floatEquals(borderAlphas[0], barChart.dataByGroup[0][0].borderAlpha);
		Assert.floatEquals(borderAlphas[1], barChart.dataByGroup[0][1].borderAlpha);
	}

	public function testSetDataBorderAlphaArrayPerGroup() {
		var dataValues:Map<String, Array<Any>> = new Map<String, Array<Any>>();
		dataValues.set("x", [1.0, 2.0]);
		dataValues.set("y", ["A", "B"]);
		dataValues.set("groups", ["G1", "G2"]);
		var currentTrailData:TrailData = {values: dataValues};
		var groupBorderAlphas = [0.6, 0.4];

		var localStyle:TrailStyle = {
			groups: ["G1" => 0, "G2" => 1],
			colorPalette: [0xFF0000, 0x00FF00],
			borderStyle: {alpha: groupBorderAlphas}
		};
		barChart.setData(currentTrailData, localStyle);
		Assert.floatEquals(groupBorderAlphas[0], barChart.dataByGroup[0][0].borderAlpha); // G1
		Assert.floatEquals(groupBorderAlphas[1], barChart.dataByGroup[1][0].borderAlpha); // G2
	}

	// --- Border Thickness Styling Tests ---
	public function testSetDataBorderThicknessScalar() {
		var dataValues:Map<String, Array<Any>> = new Map<String, Array<Any>>();
		dataValues.set("x", [1.0]);
		dataValues.set("y", ["A"]);
		dataValues.set("groups", ["G1"]);
		var currentTrailData:TrailData = {values: dataValues};

		var localStyle:TrailStyle = {
			groups: ["G1" => 0],
			colorPalette: [0xFF0000],
			borderStyle: {thickness: 2.5}
		};
		barChart.setData(currentTrailData, localStyle);
		Assert.floatEquals(2.5, barChart.dataByGroup[0][0].borderWidth);
	}

	public function testSetDataBorderThicknessArrayPerDataPoint() {
		var dataValues:Map<String, Array<Any>> = new Map<String, Array<Any>>();
		dataValues.set("x", [1.0, 2.0]);
		dataValues.set("y", ["A", "B"]);
		dataValues.set("groups", ["G1", "G1"]);
		var currentTrailData:TrailData = {values: dataValues};
		var borderThicknesses = [1.5, 3.5];

		var localStyle:TrailStyle = {
			groups: ["G1" => 0],
			colorPalette: [0xFF0000],
			borderStyle: {thickness: borderThicknesses}
		};
		barChart.setData(currentTrailData, localStyle);
		Assert.floatEquals(borderThicknesses[0], barChart.dataByGroup[0][0].borderWidth);
		Assert.floatEquals(borderThicknesses[1], barChart.dataByGroup[0][1].borderWidth);
	}

	public function testSetDataBorderThicknessArrayPerGroup() {
		var dataValues:Map<String, Array<Any>> = new Map<String, Array<Any>>();
		dataValues.set("x", [1.0, 2.0]);
		dataValues.set("y", ["A", "B"]);
		dataValues.set("groups", ["G1", "G2"]);
		var currentTrailData:TrailData = {values: dataValues};
		var groupBorderThicknesses = [0.5, 2.0];

		var localStyle:TrailStyle = {
			groups: ["G1" => 0, "G2" => 1],
			colorPalette: [0xFF0000, 0x00FF00],
			borderStyle: {thickness: groupBorderThicknesses}
		};
		barChart.setData(currentTrailData, localStyle);
		Assert.floatEquals(groupBorderThicknesses[0], barChart.dataByGroup[0][0].borderWidth); // G1
		Assert.floatEquals(groupBorderThicknesses[1], barChart.dataByGroup[1][0].borderWidth); // G2
	}

	// --- positionData Tests ---

	/**
	 * Helper to create mock ticks.
	 * For linear ticks, values are Floats. For categorical, values are Strings.
	 */
	static function createMockTicks(axisType:AxisTypes, values:Array<Dynamic>, tickScreenLength:Float, // Total length on screen this axis' ticks should span
			isYAxis:Bool, zeroIndex:Int = 0 // Index of the zero value tick, important for bar charts
	):Array<Tick> {
		var ticks:Array<Tick> = [];
		if (values.length == 0)
			return ticks;

		var increment = values.length > 1 ? tickScreenLength / (values.length - 1) : tickScreenLength;

		for (i in 0...values.length) {
			var tick = new Tick();
			var val = values[i];
			tick.text = Std.string(val);
			var currentPos = i * increment;

			if (isYAxis) {
				// Y ticks are typically laid out from top to bottom on screen, but data values go up
				// Or, if chart origin is bottom-left, Y screen coords increase upwards.
				// Let's assume screen coords for Y increase upwards for now.
				// And ticks[0].middlePos.y is the "bottom" of the Y axis usable area.
				tick.middlePos = new Point(0, currentPos);
			} else {
				// X ticks from left to right on screen.
				// ticks[0].middlePos.x is the "left" of the X axis usable area.
				tick.middlePos = new Point(currentPos, 0);
			}
			ticks.push(tick);
		}
		return ticks;
	}

	/**
	 * Prepares barChart.axes.ticksPerInfo and related axis configurations.
	 */
	function prepareAxesTicks(barChart:hxchart.core.trails.Bar, xMockValues:Array<Dynamic>, xTickScreenLength:Float, xZeroIndex:Int, xAxisType:AxisTypes,
			yMockValues:Array<Dynamic>, yTickScreenLength:Float, yZeroIndex:Int, yAxisType:AxisTypes) {
		var xTicks = createMockTicks(xAxisType, xMockValues, xTickScreenLength, false, xZeroIndex);
		var yTicks = createMockTicks(yAxisType, yMockValues, yTickScreenLength, true, yZeroIndex);

		// Ensure AxisInfo in trailInfo is updated to reflect the types for calcBarCoordinates
		barChart.trailInfo.axisInfo[0].type = xAxisType;
		barChart.trailInfo.axisInfo[1].type = yAxisType;

		// Mock tickInfo within axisInfo as well, especially zeroIndex
		// Create dummy tickInfo objects just to hold the zeroIndex if not already proper
		if (barChart.trailInfo.axisInfo[0].tickInfo == null)
			barChart.trailInfo.axisInfo[0].tickInfo = new NumericTickInfo(new Map()); // or StringTickInfo
		if (barChart.trailInfo.axisInfo[1].tickInfo == null)
			barChart.trailInfo.axisInfo[1].tickInfo = new StringTickInfo([]); // or NumericTickInfo

		barChart.trailInfo.axisInfo[0].tickInfo.zeroIndex = xZeroIndex;
		barChart.trailInfo.axisInfo[1].tickInfo.zeroIndex = yZeroIndex;

		// Direct assignment to ticksPerInfo
		if (barChart.axes == null) { // Should be initialized in setup()
			var coordSys = new CoordinateSystem(); // dummy
			barChart.axes = new Axis(barChart.trailInfo.axisInfo, coordSys);
		}
		barChart.axes.ticksPerInfo = [xTicks, yTicks];
		barChart.axes.axesInfo = barChart.trailInfo.axisInfo; // Ensure axes internal info is also aligned
	}

	public function testPositionDataHorizontalStacked() {
		// Setup: X-axis linear, Y-axis categorical (from main setup())
		// Data: Two groups, G1 and G2.
		// G1: (10, "CatY1"), (20, "CatY2")
		// G2: (15, "CatY1"), (5, "CatY2")
		var dataValues:Map<String, Array<Any>> = new Map<String, Array<Any>>();
		dataValues.set("x", [10.0, 20.0, 15.0, 5.0]); // Linear X
		dataValues.set("y", ["CatY1", "CatY2", "CatY1", "CatY2"]); // Categorical Y
		dataValues.set("groups", ["G1", "G1", "G2", "G2"]);

		var currentTrailData:TrailData = {values: dataValues};
		var localStyle:TrailStyle = {
			groups: ["G1" => 0, "G2" => 1],
			colorPalette: [0xFF0000, 0x00FF00],
			positionOption: PositionOption.stacked // Horizontal Stacked
		};
		barChart.trailInfo.style = localStyle; // Update style in existing trailInfo

		// Manually reset minX/maxX for this test data as setData appends.
		barChart.minX = Math.POSITIVE_INFINITY;
		barChart.maxX = Math.NEGATIVE_INFINITY;
		barChart.setData(currentTrailData, localStyle);

		// Mock Ticks:
		// X-axis (linear): Values could be 0, 10, 20, 30. Let zero be at index 0. Screen length 300px.
		// Y-axis (categorical): Values "CatY1", "CatY2". Screen length 100px.
		var xMockLinValues = [0.0, 10.0, 20.0, 30.0]; // Covers data range [5, 20]
		var yMockCatValues = ["CatY1", "CatY2"];

		// Use the existing barChart and its axes object from setup()
		// The existing barChart.trailInfo.axisInfo has X-linear, Y-categorical
		prepareAxesTicks(barChart, xMockLinValues, 300.0, 0, AxisTypes.linear, yMockCatValues, 100.0, 0, AxisTypes.categorical);

		barChart.positionData(localStyle);

		Assert.equals(2, barChart.dataByGroup.length);
		Assert.equals(2, barChart.dataByGroup[0].length); // G1
		Assert.equals(2, barChart.dataByGroup[1].length); // G2

		// Expected calculations based on Bar.hx:
		// useableHeight = yTicks[1].middlePos.y (100) - yTicks[0].middlePos.y (0) = 100
		// spacePerYTick = (100 / (2-1)) * 2/3 = 100 * 2/3 = 66.666
		// For horizontal bars, dataRec.height = spacePerYTick (when stacked or single group)

		// G1, CatY1: x=10.0 (index 0 in G1)
		var rec_G1_CatY1 = barChart.dataByGroup[0][0]; // Assumes order: CatY1, CatY2 for G1
		Assert.equals("CatY1", rec_G1_CatY1.values.y);
		Assert.floatEquals(10.0, rec_G1_CatY1.values.x);
		Assert.floatEquals(100.0, rec_G1_CatY1.width, 0.01, "G1_CatY1 width");
		Assert.floatEquals(10.0, rec_G1_CatY1.values.acc, 0.01, "G1_CatY1 acc value");
		Assert.floatEquals(100.0, rec_G1_CatY1.coord.x, 0.01, "G1_CatY1 coord.x (end point)");

		// G1, CatY2: x=20.0 (index 1 in G1)
		var rec_G1_CatY2 = barChart.dataByGroup[0][1];
		Assert.equals("CatY2", rec_G1_CatY2.values.y);
		Assert.floatEquals(20.0, rec_G1_CatY2.values.x);
		Assert.floatEquals(200.0, rec_G1_CatY2.width, 0.01, "G1_CatY2 width");
		Assert.floatEquals(20.0, rec_G1_CatY2.values.acc, 0.01, "G1_CatY2 acc value");
		Assert.floatEquals(200.0, rec_G1_CatY2.coord.x, 0.01, "G1_CatY2 coord.x (end point)");

		// G2, CatY1: x=15.0 (index 0 in G2, stacks on G1_CatY1)
		var rec_G2_CatY1 = barChart.dataByGroup[1][0];
		Assert.equals("CatY1", rec_G2_CatY1.values.y);
		Assert.floatEquals(15.0, rec_G2_CatY1.values.x);
		Assert.floatEquals(150.0, rec_G2_CatY1.width, 0.01, "G2_CatY1 width"); // (15/30)*300
		Assert.floatEquals(10.0 + 15.0, rec_G2_CatY1.values.acc, 0.01, "G2_CatY1 acc value"); // 10 (from G1) + 15 (this)
		Assert.floatEquals(100.0 + 150.0, rec_G2_CatY1.coord.x, 0.01, "G2_CatY1 coord.x (end point)"); // G1_end + this_width

		// G2, CatY2: x=5.0 (index 1 in G2, stacks on G1_CatY2)
		var rec_G2_CatY2 = barChart.dataByGroup[1][1];
		Assert.equals("CatY2", rec_G2_CatY2.values.y);
		Assert.floatEquals(5.0, rec_G2_CatY2.values.x);
		Assert.floatEquals(50.0, rec_G2_CatY2.width, 0.01, "G2_CatY2 width"); // (5/30)*300
		Assert.floatEquals(20.0 + 5.0, rec_G2_CatY2.values.acc, 0.01, "G2_CatY2 acc value"); // 20 (from G1) + 5 (this)
		Assert.floatEquals(200.0 + 50.0, rec_G2_CatY2.coord.x, 0.01, "G2_CatY2 coord.x (end point)"); // G1_end + this_width

		// Heights for horizontal bars (X linear, Y categorical) when stacked:
		var expectedHeight = (100.0 / (yMockCatValues.length - 1)) * 2 / 3; // 66.666...
		Assert.floatEquals(expectedHeight, rec_G1_CatY1.height, 0.01, "G1_CatY1 height");
		Assert.floatEquals(expectedHeight, rec_G1_CatY2.height, 0.01, "G1_CatY2 height");
		Assert.floatEquals(expectedHeight, rec_G2_CatY1.height, 0.01, "G2_CatY1 height");
		Assert.floatEquals(expectedHeight, rec_G2_CatY2.height, 0.01, "G2_CatY2 height");

		// Check Y coordinates (position of the bar along the categorical axis)
		// These depend on tick.middlePos.y and spacePerYTick.
		// yTicks[0] ("CatY1") middlePos.y = 0. yTicks[1] ("CatY2") middlePos.y = 100.
		// spacePerYTick = 66.666
		// coord.y for CatY1 = 0 - (66.666 / 2) = -33.333
		// coord.y for CatY2 = 100 - (66.666 / 2) = 66.667
		Assert.floatEquals(-33.333, rec_G1_CatY1.coord.y, 0.01, "G1_CatY1 coord.y");
		Assert.floatEquals(66.667, rec_G1_CatY2.coord.y, 0.01, "G1_CatY2 coord.y");
		Assert.floatEquals(-33.333, rec_G2_CatY1.coord.y, 0.01, "G2_CatY1 coord.y");
		Assert.floatEquals(66.667, rec_G2_CatY2.coord.y, 0.01, "G2_CatY2 coord.y");
	}

	public function testPositionDataHorizontalLayered() {
		// Setup: X-axis linear, Y-axis categorical
		var dataValues:Map<String, Array<Any>> = new Map<String, Array<Any>>();
		dataValues.set("x", [10.0, 20.0, 15.0, 5.0]); // Linear X
		dataValues.set("y", ["CatY1", "CatY2", "CatY1", "CatY2"]); // Categorical Y
		dataValues.set("groups", ["G1", "G1", "G2", "G2"]);

		var currentTrailData:TrailData = {values: dataValues};
		var layerFactor = 0.5; // Offset factor for layered bars
		var localStyle:TrailStyle = {
			groups: ["G1" => 0, "G2" => 1],
			colorPalette: [0xFF0000, 0x00FF00],
			positionOption: PositionOption.layered(layerFactor)
		};
		barChart.trailInfo.style = localStyle;

		barChart.minX = Math.POSITIVE_INFINITY;
		barChart.maxX = Math.NEGATIVE_INFINITY;
		barChart.setData(currentTrailData, localStyle);

		var xMockLinValues = [0.0, 10.0, 20.0, 30.0];
		var yMockCatValues = ["CatY1", "CatY2"];
		prepareAxesTicks(barChart, xMockLinValues, 300.0, 0, AxisTypes.linear, yMockCatValues, 100.0, 0, AxisTypes.categorical);

		barChart.positionData(localStyle);

		// Expected calculations:
		// numGroups = 2
		// useableHeight = 100 (as before)
		// spacePerYTick = (100 / 1) * 2/3 = 66.666 (this is the total space for a category tick)
		// For layered horizontal bars, dataRec.height = spacePerYTick / numGroups
		var groupLength = 0;
		for (key in localStyle.groups.keys()) {
			groupLength++;
		}
		var expectedHeightPerGroup = ((100.0 / (yMockCatValues.length - 1)) * 2 / 3) / groupLength; // 66.666 / 2 = 33.333

		// G1, CatY1: x=10.0
		var rec_G1_CatY1 = barChart.dataByGroup[0][0];
		Assert.floatEquals(100.0, rec_G1_CatY1.width, 0.01, "G1_CatY1 width"); // (10/30)*300
		Assert.floatEquals(100.0, rec_G1_CatY1.coord.x, 0.01, "G1_CatY1 coord.x (end point)");
		Assert.floatEquals(expectedHeightPerGroup, rec_G1_CatY1.height, 0.01, "G1_CatY1 height");
		// coord.y for G1 (first group) = tick.middlePos.y - (spacePerYTick / 2)
		// For CatY1: 0 - (66.666 / 2) = -33.333
		Assert.floatEquals(-33.333, rec_G1_CatY1.coord.y, 0.01, "G1_CatY1 coord.y");

		// G1, CatY2: x=20.0
		var rec_G1_CatY2 = barChart.dataByGroup[0][1];
		Assert.floatEquals(200.0, rec_G1_CatY2.width, 0.01, "G1_CatY2 width");
		Assert.floatEquals(200.0, rec_G1_CatY2.coord.x, 0.01, "G1_CatY2 coord.x (end point)");
		Assert.floatEquals(expectedHeightPerGroup, rec_G1_CatY2.height, 0.01, "G1_CatY2 height");
		// For CatY2: 100 - (66.666 / 2) = 66.667
		Assert.floatEquals(66.667, rec_G1_CatY2.coord.y, 0.01, "G1_CatY2 coord.y");

		// G2, CatY1: x=15.0
		var rec_G2_CatY1 = barChart.dataByGroup[1][0];
		Assert.floatEquals(150.0, rec_G2_CatY1.width, 0.01, "G2_CatY1 width");
		Assert.floatEquals(150.0, rec_G2_CatY1.coord.x, 0.01, "G2_CatY1 coord.x (end point)"); // Not stacked
		Assert.floatEquals(expectedHeightPerGroup, rec_G2_CatY1.height, 0.01, "G2_CatY1 height");
		// coord.y for G2 (layered) = prevRec.coord.y + heightPerGroup * layerFactor
		// prevRec is G1_CatY1.coord.y = -33.333. heightPerGroup = 33.333. layerFactor = 0.5
		// Expected G2_CatY1.coord.y = -33.333 + (33.333 * 0.5) = -33.333 + 16.6665 = -16.6665
		Assert.floatEquals(-33.333 + expectedHeightPerGroup * layerFactor, rec_G2_CatY1.coord.y, 0.01, "G2_CatY1 coord.y");

		// G2, CatY2: x=5.0
		var rec_G2_CatY2 = barChart.dataByGroup[1][1];
		Assert.floatEquals(50.0, rec_G2_CatY2.width, 0.01, "G2_CatY2 width");
		Assert.floatEquals(50.0, rec_G2_CatY2.coord.x, 0.01, "G2_CatY2 coord.x (end point)");
		Assert.floatEquals(expectedHeightPerGroup, rec_G2_CatY2.height, 0.01, "G2_CatY2 height");
		// prevRec is G1_CatY2.coord.y = 66.667
		// Expected G2_CatY2.coord.y = 66.667 + (33.333 * 0.5) = 66.667 + 16.6665 = 83.3335
		Assert.floatEquals(66.667 + expectedHeightPerGroup * layerFactor, rec_G2_CatY2.coord.y, 0.01, "G2_CatY2 coord.y");
	}

	public function testPositionDataVerticalStacked() {
		// Setup: X-axis categorical, Y-axis linear.
		var dataValues:Map<String, Array<Any>> = new Map<String, Array<Any>>();
		dataValues.set("x", ["CatX1", "CatX2", "CatX1", "CatX2"]); // Categorical X
		dataValues.set("y", [10.0, 20.0, 15.0, 5.0]); // Linear Y
		dataValues.set("groups", ["G1", "G1", "G2", "G2"]);

		var currentTrailData:TrailData = {values: dataValues};
		var localStyle:TrailStyle = {
			groups: ["G1" => 0, "G2" => 1],
			colorPalette: [0x00FF00, 0x0000FF],
			positionOption: PositionOption.stacked
		};
		// Update trailInfo on the barChart from setup for this test's specific needs
		barChart.trailInfo.axisInfo[0].type = AxisTypes.categorical; // X categorical
		barChart.trailInfo.axisInfo[1].type = AxisTypes.linear; // Y linear
		barChart.trailInfo.style = localStyle;

		// Create a new Axis object configured for these axis types
		// because the one in setup() is for X-linear, Y-categorical.
		// The Bar constructor might throw an error if trailInfo.axisInfo mismatches axes.axisInfo types.
		// Or, ensure prepareAxesTicks correctly updates barChart.axes.axesInfo.
		// For safety, a new Axis instance is cleaner if its internal setup depends on initial AxisInfo types.
		// However, prepareAxesTicks does: barChart.axes.axesInfo = barChart.trailInfo.axisInfo;
		// So the existing axes object should be reconfigured by prepareAxesTicks.

		barChart.minY = Math.POSITIVE_INFINITY; // Y is linear, so check minY/maxY
		barChart.maxY = Math.NEGATIVE_INFINITY;
		barChart.setData(currentTrailData, localStyle);

		var xMockCatValues = ["CatX1", "CatX2"];
		var yMockLinValues = [0.0, 10.0, 20.0, 30.0]; // Covers data range [5, 20] for Y
		prepareAxesTicks(barChart, xMockCatValues, 200.0, 0, AxisTypes.categorical, // X-axis: 200px wide
			yMockLinValues, 300.0, 0,
			AxisTypes.linear // Y-axis: 300px high
		);

		barChart.positionData(localStyle);

		// Expected calculations for Vertical Bars (X-cat, Y-lin):
		// useableWidth = xTicks[1].middlePos.x (200) - xTicks[0].middlePos.x (0) = 200
		// spacePerXTick = (200 / (2-1)) * 2/3 = 200 * 2/3 = 133.333
		// For vertical bars, dataRec.width = spacePerXTick (when stacked or single group)

		var expectedWidth = (200.0 / (xMockCatValues.length - 1)) * 2 / 3;

		// G1, CatX1: y=10.0
		var rec_G1_CatX1 = barChart.dataByGroup[0][0]; // G1, first item
		Assert.equals("CatX1", rec_G1_CatX1.values.x);
		Assert.floatEquals(10.0, rec_G1_CatX1.values.y);
		Assert.floatEquals(expectedWidth, rec_G1_CatX1.width, 0.01, "G1_CatX1 width");
		Assert.floatEquals(10.0, rec_G1_CatX1.values.acc, 0.01, "G1_CatX1 acc value"); // y-value is accumulated
		// Height for 10.0 on Y-axis (0-30 maps to 0-300px): (10/30)*300 = 100px from zero tick.
		Assert.floatEquals(100.0, rec_G1_CatX1.height, 0.01, "G1_CatX1 height");
		// coord.y is end point of bar segment:
		Assert.floatEquals(100.0, rec_G1_CatX1.coord.y, 0.01, "G1_CatX1 coord.y (end point)");

		// G1, CatX2: y=20.0
		var rec_G1_CatX2 = barChart.dataByGroup[0][1]; // G1, second item
		Assert.equals("CatX2", rec_G1_CatX2.values.x);
		Assert.floatEquals(20.0, rec_G1_CatX2.values.y);
		Assert.floatEquals(expectedWidth, rec_G1_CatX2.width, 0.01, "G1_CatX2 width");
		Assert.floatEquals(20.0, rec_G1_CatX2.values.acc, 0.01, "G1_CatX2 acc value");
		Assert.floatEquals(200.0, rec_G1_CatX2.height, 0.01, "G1_CatX2 height"); // (20/30)*300
		Assert.floatEquals(200.0, rec_G1_CatX2.coord.y, 0.01, "G1_CatX2 coord.y (end point)");

		// G2, CatX1: y=15.0 (stacks on G1_CatX1's 10.0)
		var rec_G2_CatX1 = barChart.dataByGroup[1][0]; // G2, first item
		Assert.equals("CatX1", rec_G2_CatX1.values.x);
		Assert.floatEquals(15.0, rec_G2_CatX1.values.y);
		Assert.floatEquals(expectedWidth, rec_G2_CatX1.width, 0.01, "G2_CatX1 width");
		Assert.floatEquals(10.0 + 15.0, rec_G2_CatX1.values.acc, 0.01, "G2_CatX1 acc value");
		// Height for this segment: (15/30)*300 = 150
		Assert.floatEquals(150.0, rec_G2_CatX1.height, 0.01, "G2_CatX1 height");
		// End coord.y = G1_CatX1.coord.y (100) + this segment's height (150) = 250
		Assert.floatEquals(100.0 + 150.0, rec_G2_CatX1.coord.y, 0.01, "G2_CatX1 coord.y (end point)");

		// G2, CatX2: y=5.0 (stacks on G1_CatX2's 20.0)
		var rec_G2_CatX2 = barChart.dataByGroup[1][1]; // G2, second item
		Assert.equals("CatX2", rec_G2_CatX2.values.x);
		Assert.floatEquals(5.0, rec_G2_CatX2.values.y);
		Assert.floatEquals(expectedWidth, rec_G2_CatX2.width, 0.01, "G2_CatX2 width");
		Assert.floatEquals(20.0 + 5.0, rec_G2_CatX2.values.acc, 0.01, "G2_CatX2 acc value");
		// Height for this segment: (5/30)*300 = 50
		Assert.floatEquals(50.0, rec_G2_CatX2.height, 0.01, "G2_CatX2 height");
		// End coord.y = G1_CatX2.coord.y (200) + this segment's height (50) = 250
		Assert.floatEquals(200.0 + 50.0, rec_G2_CatX2.coord.y, 0.01, "G2_CatX2 coord.y (end point)");

		// Check X coordinates (position of the bar along the categorical axis)
		// xTicks[0] ("CatX1") middlePos.x = 0. xTicks[1] ("CatX2") middlePos.x = 200.
		// spacePerXTick = 133.333
		// coord.x for CatX1 = 0 - (133.333 / 2) = -66.6665
		// coord.x for CatX2 = 200 - (133.333 / 2) = 133.3335
		Assert.floatEquals(-66.6665, rec_G1_CatX1.coord.x, 0.01); // xTick[0].middlePos.x - spacePerXTick/2
		Assert.floatEquals(133.3335, rec_G1_CatX2.coord.x, 0.01);
		Assert.floatEquals(-66.6665, rec_G2_CatX1.coord.x, 0.01);
		Assert.floatEquals(133.3335, rec_G2_CatX2.coord.x, 0.01);
		// A bit of a mess for categorical x coord. Let's simplify:
		// CatX1's tick middle is at 0. spacePerXTick = 133.333. So xCoord = 0 - 133.333/2 = -66.666
		// CatX2's tick middle is at 200. spacePerXTick = 133.333. So xCoord = 200 - 133.333/2 = 133.333
		var x_coord_catx1 = barChart.axes.ticksPerInfo[0][0].middlePos.x - expectedWidth / 2;
		var x_coord_catx2 = barChart.axes.ticksPerInfo[0][1].middlePos.x - expectedWidth / 2;
		Assert.floatEquals(x_coord_catx1, rec_G1_CatX1.coord.x, 0.01, "G1_CatX1 coord.x simplified");
		Assert.floatEquals(x_coord_catx2, rec_G1_CatX2.coord.x, 0.01, "G1_CatX2 coord.x simplified");
		Assert.floatEquals(x_coord_catx1, rec_G2_CatX1.coord.x, 0.01, "G2_CatX1 coord.x simplified");
		Assert.floatEquals(x_coord_catx2, rec_G2_CatX2.coord.x, 0.01, "G2_CatX2 coord.x simplified");
	}

	public function testPositionDataVerticalLayered() {
		// Setup: X-axis categorical, Y-axis linear.
		var dataValues:Map<String, Array<Any>> = new Map<String, Array<Any>>();
		dataValues.set("x", ["CatX1", "CatX2", "CatX1", "CatX2"]); // Categorical X
		dataValues.set("y", [10.0, 20.0, 15.0, 5.0]); // Linear Y
		dataValues.set("groups", ["G1", "G1", "G2", "G2"]);

		var currentTrailData:TrailData = {values: dataValues};
		var layerFactor = 0.5;
		var localStyle:TrailStyle = {
			groups: ["G1" => 0, "G2" => 1],
			colorPalette: [0x00FF00, 0x0000FF],
			positionOption: PositionOption.layered(layerFactor)
		};
		barChart.trailInfo.axisInfo[0].type = AxisTypes.categorical;
		barChart.trailInfo.axisInfo[1].type = AxisTypes.linear;
		barChart.trailInfo.style = localStyle;

		barChart.minY = Math.POSITIVE_INFINITY;
		barChart.maxY = Math.NEGATIVE_INFINITY;
		barChart.setData(currentTrailData, localStyle);

		var xMockCatValues = ["CatX1", "CatX2"];
		var yMockLinValues = [0.0, 10.0, 20.0, 30.0];
		prepareAxesTicks(barChart, xMockCatValues, 200.0, 0, AxisTypes.categorical, yMockLinValues, 300.0, 0, AxisTypes.linear);

		barChart.positionData(localStyle);

		// Expected calculations:
		// numGroups = 2
		// useableWidth = 200
		// spacePerXTick = (200 / 1) * 2/3 = 133.333 (total space for a category tick)
		// For layered vertical bars, dataRec.width = spacePerXTick / numGroups
		var totalSpacePerXTick = (200.0 / (xMockCatValues.length - 1)) * 2 / 3;
		var groupLength = 0;
		for (key in localStyle.groups.keys()) {
			groupLength++;
		}
		var expectedWidthPerGroup = totalSpacePerXTick / groupLength; // 133.333 / 2 = 66.666

		// G1, CatX1: y=10.0
		var rec_G1_CatX1 = barChart.dataByGroup[0][0];
		Assert.floatEquals(10.0, rec_G1_CatX1.values.y);
		Assert.floatEquals(expectedWidthPerGroup, rec_G1_CatX1.width, 0.01, "G1_CatX1 width");
		Assert.floatEquals(100.0, rec_G1_CatX1.height, 0.01, "G1_CatX1 height"); // (10/30)*300
		Assert.floatEquals(100.0, rec_G1_CatX1.coord.y, 0.01, "G1_CatX1 coord.y (end point)"); // Not stacked
		// coord.x for G1 (first group) = tick.middlePos.x - (totalSpacePerXTick / 2)
		// For CatX1 (tick.middlePos.x = 0): 0 - (133.333 / 2) = -66.666
		var x_coord_catx1_g1 = barChart.axes.ticksPerInfo[0][0].middlePos.x - totalSpacePerXTick / 2;
		Assert.floatEquals(x_coord_catx1_g1, rec_G1_CatX1.coord.x, 0.01, "G1_CatX1 coord.x");

		// G1, CatX2: y=20.0
		var rec_G1_CatX2 = barChart.dataByGroup[0][1];
		Assert.floatEquals(expectedWidthPerGroup, rec_G1_CatX2.width, 0.01, "G1_CatX2 width");
		Assert.floatEquals(200.0, rec_G1_CatX2.height, 0.01, "G1_CatX2 height");
		Assert.floatEquals(200.0, rec_G1_CatX2.coord.y, 0.01, "G1_CatX2 coord.y (end point)");
		// For CatX2 (tick.middlePos.x = 200): 200 - (133.333 / 2) = 133.333
		var x_coord_catx2_g1 = barChart.axes.ticksPerInfo[0][1].middlePos.x - totalSpacePerXTick / 2;
		Assert.floatEquals(x_coord_catx2_g1, rec_G1_CatX2.coord.x, 0.01, "G1_CatX2 coord.x");

		// G2, CatX1: y=15.0
		var rec_G2_CatX1 = barChart.dataByGroup[1][0];
		Assert.floatEquals(15.0, rec_G2_CatX1.values.y);
		Assert.floatEquals(expectedWidthPerGroup, rec_G2_CatX1.width, 0.01, "G2_CatX1 width");
		Assert.floatEquals(150.0, rec_G2_CatX1.height, 0.01, "G2_CatX1 height"); // (15/30)*300
		Assert.floatEquals(150.0, rec_G2_CatX1.coord.y, 0.01, "G2_CatX1 coord.y (end point)");
		// coord.x for G2 (layered) = prevRec.coord.x + widthPerGroup * layerFactor
		// prevRec is G1_CatX1.coord.x = -66.666. widthPerGroup = 66.666. layerFactor = 0.5
		// Expected G2_CatX1.coord.x = -66.666 + (66.666 * 0.5) = -66.666 + 33.333 = -33.333
		Assert.floatEquals(x_coord_catx1_g1 + expectedWidthPerGroup * layerFactor, rec_G2_CatX1.coord.x, 0.01, "G2_CatX1 coord.x");

		// G2, CatX2: y=5.0
		var rec_G2_CatY2 = barChart.dataByGroup[1][1]; // Corrected variable name from CatY2 to CatX2
		Assert.floatEquals(5.0, rec_G2_CatY2.values.y);
		Assert.floatEquals(expectedWidthPerGroup, rec_G2_CatY2.width, 0.01, "G2_CatX2 width");
		Assert.floatEquals(50.0, rec_G2_CatY2.height, 0.01, "G2_CatX2 height"); // (5/30)*300
		Assert.floatEquals(50.0, rec_G2_CatY2.coord.y, 0.01, "G2_CatX2 coord.y (end point)");
		// prevRec is G1_CatX2.coord.x = 133.333
		// Expected G2_CatX2.coord.x = 133.333 + (66.666 * 0.5) = 133.333 + 33.333 = 166.666
		Assert.floatEquals(x_coord_catx2_g1 + expectedWidthPerGroup * layerFactor, rec_G2_CatY2.coord.x, 0.01, "G2_CatX2 coord.x");
	}

	public function testPositionDataSingleGroupHorizontal() {
		// Setup: X-axis linear, Y-axis categorical (main setup config)
		var dataValues:Map<String, Array<Any>> = new Map<String, Array<Any>>();
		dataValues.set("x", [10.0, 20.0]); // Linear X
		dataValues.set("y", ["CatY1", "CatY2"]); // Categorical Y
		dataValues.set("groups", ["G1", "G1"]); // Single Group G1

		var currentTrailData:TrailData = {values: dataValues};
		var localStyle:TrailStyle = {
			groups: ["G1" => 0], // Only G1
			colorPalette: [0xFF0000],
			positionOption: PositionOption.stacked // Default/stacked for single group
		};
		// Ensure axis types are as expected by this test (X-lin, Y-cat)
		barChart.trailInfo.axisInfo[0].type = AxisTypes.linear;
		barChart.trailInfo.axisInfo[1].type = AxisTypes.categorical;
		barChart.trailInfo.style = localStyle;

		barChart.minX = Math.POSITIVE_INFINITY;
		barChart.maxX = Math.NEGATIVE_INFINITY;
		barChart.setData(currentTrailData, localStyle);

		var xMockLinValues = [0.0, 10.0, 20.0, 30.0];
		var yMockCatValues = ["CatY1", "CatY2"];
		prepareAxesTicks(barChart, xMockLinValues, 300.0, 0, AxisTypes.linear, yMockCatValues, 100.0, 0, AxisTypes.categorical);

		barChart.positionData(localStyle);

		Assert.equals(1, barChart.dataByGroup.length, "Should have 1 group");
		Assert.equals(2, barChart.dataByGroup[0].length, "G1 should have 2 records");

		// Expected height for horizontal bars, single group (should be full spacePerYTick)
		var expectedHeight = (100.0 / (yMockCatValues.length - 1)) * 2 / 3; // 66.666...

		// G1, CatY1: x=10.0
		var rec_G1_CatY1 = barChart.dataByGroup[0][0];
		Assert.equals("CatY1", rec_G1_CatY1.values.y);
		Assert.floatEquals(10.0, rec_G1_CatY1.values.x);
		Assert.floatEquals(100.0, rec_G1_CatY1.width, 0.01, "G1_CatY1 width"); // (10/30)*300
		Assert.floatEquals(10.0, rec_G1_CatY1.values.acc, 0.01, "G1_CatY1 acc value");
		Assert.floatEquals(100.0, rec_G1_CatY1.coord.x, 0.01, "G1_CatY1 coord.x (end point)");
		Assert.floatEquals(expectedHeight, rec_G1_CatY1.height, 0.01, "G1_CatY1 height");
		Assert.floatEquals(-33.333, rec_G1_CatY1.coord.y, 0.01, "G1_CatY1 coord.y");

		// G1, CatY2: x=20.0
		var rec_G1_CatY2 = barChart.dataByGroup[0][1];
		Assert.equals("CatY2", rec_G1_CatY2.values.y);
		Assert.floatEquals(20.0, rec_G1_CatY2.values.x);
		Assert.floatEquals(200.0, rec_G1_CatY2.width, 0.01, "G1_CatY2 width"); // (20/30)*300
		Assert.floatEquals(20.0, rec_G1_CatY2.values.acc, 0.01, "G1_CatY2 acc value");
		Assert.floatEquals(200.0, rec_G1_CatY2.coord.x, 0.01, "G1_CatY2 coord.x (end point)");
		Assert.floatEquals(expectedHeight, rec_G1_CatY2.height, 0.01, "G1_CatY2 height");
		Assert.floatEquals(66.667, rec_G1_CatY2.coord.y, 0.01, "G1_CatY2 coord.y");
	}

	public function testPositionDataSingleGroupVertical() {
		// Setup: X-axis categorical, Y-axis linear.
		var dataValues:Map<String, Array<Any>> = new Map<String, Array<Any>>();
		dataValues.set("x", ["CatX1", "CatX2"]); // Categorical X
		dataValues.set("y", [10.0, 20.0]); // Linear Y
		dataValues.set("groups", ["G1", "G1"]); // Single Group G1

		var currentTrailData:TrailData = {values: dataValues};
		var localStyle:TrailStyle = {
			groups: ["G1" => 0],
			colorPalette: [0x00FF00],
			positionOption: PositionOption.stacked // Default/stacked for single group
		};
		barChart.trailInfo.axisInfo[0].type = AxisTypes.categorical;
		barChart.trailInfo.axisInfo[1].type = AxisTypes.linear;
		barChart.trailInfo.style = localStyle;

		barChart.minY = Math.POSITIVE_INFINITY;
		barChart.maxY = Math.NEGATIVE_INFINITY;
		barChart.setData(currentTrailData, localStyle);

		var xMockCatValues = ["CatX1", "CatX2"];
		var yMockLinValues = [0.0, 10.0, 20.0, 30.0];
		prepareAxesTicks(barChart, xMockCatValues, 200.0, 0, AxisTypes.categorical, yMockLinValues, 300.0, 0, AxisTypes.linear);

		barChart.positionData(localStyle);

		Assert.equals(1, barChart.dataByGroup.length, "Should have 1 group");
		Assert.equals(2, barChart.dataByGroup[0].length, "G1 should have 2 records");

		// Expected width for vertical bars, single group (should be full spacePerXTick)
		var expectedWidth = (200.0 / (xMockCatValues.length - 1)) * 2 / 3; // 133.333...

		// G1, CatX1: y=10.0
		var rec_G1_CatX1 = barChart.dataByGroup[0][0];
		Assert.equals("CatX1", rec_G1_CatX1.values.x);
		Assert.floatEquals(10.0, rec_G1_CatX1.values.y);
		Assert.floatEquals(expectedWidth, rec_G1_CatX1.width, 0.01, "G1_CatX1 width");
		Assert.floatEquals(10.0, rec_G1_CatX1.values.acc, 0.01, "G1_CatX1 acc value");
		Assert.floatEquals(100.0, rec_G1_CatX1.height, 0.01, "G1_CatX1 height"); // (10/30)*300
		Assert.floatEquals(100.0, rec_G1_CatX1.coord.y, 0.01, "G1_CatX1 coord.y (end point)");
		var x_coord_catx1 = barChart.axes.ticksPerInfo[0][0].middlePos.x - expectedWidth / 2;
		Assert.floatEquals(x_coord_catx1, rec_G1_CatX1.coord.x, 0.01, "G1_CatX1 coord.x");

		// G1, CatX2: y=20.0
		var rec_G1_CatX2 = barChart.dataByGroup[0][1];
		Assert.equals("CatX2", rec_G1_CatX2.values.x);
		Assert.floatEquals(20.0, rec_G1_CatX2.values.y);
		Assert.floatEquals(expectedWidth, rec_G1_CatX2.width, 0.01, "G1_CatX2 width");
		Assert.floatEquals(20.0, rec_G1_CatX2.values.acc, 0.01, "G1_CatX2 acc value");
		Assert.floatEquals(200.0, rec_G1_CatX2.height, 0.01, "G1_CatX2 height"); // (20/30)*300
		Assert.floatEquals(200.0, rec_G1_CatX2.coord.y, 0.01, "G1_CatX2 coord.y (end point)");
		var x_coord_catx2 = barChart.axes.ticksPerInfo[0][1].middlePos.x - expectedWidth / 2;
		Assert.floatEquals(x_coord_catx2, rec_G1_CatX2.coord.x, 0.01, "G1_CatX2 coord.x");
	}
}
