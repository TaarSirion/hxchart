package hxchart.basics.trails;

import hxchart.basics.utils.Statistics;
import hxchart.basics.plot.Chart.OptimizationType;
import hxchart.basics.quadtree.OptimGrid;
import hxchart.basics.quadtree.Quadtree;
import hxchart.basics.axis.AxisTools;
import hxchart.basics.utils.ChartTools;
import haxe.Timer;
import hxchart.basics.plot.Chart.TrailStyle;
import hxchart.basics.ticks.Ticks;
import haxe.Exception;
import hxchart.basics.ticks.Ticks.CompassOrientation;
import hxchart.basics.axis.StringTickInfo;
import haxe.ui.components.Canvas;
import hxchart.basics.axis.Axis;
import hxchart.basics.axis.TickInfo;
import haxe.ui.geom.Point;
import haxe.ui.containers.Absolute;
import hxchart.basics.axis.NumericTickInfo;
import haxe.ui.util.Color;
import hxchart.basics.data.Data2D;
import hxchart.basics.plot.Chart.TrailInfo;
import hxchart.basics.data.DataLayer;
import hxchart.basics.axis.AxisLayer;

class Scatter implements AxisLayer implements DataLayer {
	public var id:String;
	public var axisID:String;
	public var axes:Array<Axis>;

	public var data:Array<Data2D> = [];
	public var groups:Map<String, Int>;
	@:allow(hxchart.tests)
	public var colors:Array<Color> = [];
	@:allow(hxchart.tests)
	public var alphas:Array<Float> = [];
	@:allow(hxchart.tests)
	public var sizes:Array<Float> = [];
	@:allow(hxchart.tests)
	public var borderAlphas:Array<Float> = [];
	@:allow(hxchart.tests)
	public var borderThickness:Array<Float> = [];
	@:allow(hxchart.tests)
	public var borderColors:Array<Color> = [];

	public var dataLayer:Absolute;
	public var dataCanvas:Canvas;

	var quadTree:Quadtree;
	var optimGrid:OptimGrid;
	var gridStep:Float = 1;
	var useOptimization:Bool;

	@:allow(hxchart.tests)
	private var chartInfo:TrailInfo;

	public var colorPalette:Array<Int>;

	public var parent:Absolute;

	public function new(chartInfo:TrailInfo, parent:Absolute, id:String, axisID:String) {
		this.parent = parent;
		dataCanvas = new Canvas();
		dataCanvas.id = id;
		dataCanvas.percentHeight = 100;
		dataCanvas.percentWidth = 100;
		this.id = id;
		this.axisID = axisID;
		this.chartInfo = chartInfo;
		if (chartInfo.optimizationInfo != null && chartInfo.optimizationInfo.reduceVia != null) {
			useOptimization = true;
			switch (chartInfo.optimizationInfo.reduceVia) {
				case OptimizationType.optimGrid:
					if (chartInfo.optimizationInfo.gridStep != null) {
						gridStep = chartInfo.optimizationInfo.gridStep;
					}
					optimGrid = new OptimGrid(parent.width, parent.height, gridStep);
				case OptimizationType.quadTree:
					quadTree = new Quadtree(new Region(0, parent.width, 0, parent.height));
			}
		}
	}

	public function validateChart() {
		var canvasComponent = parent.findComponent(id);
		if (canvasComponent != null) {
			dataCanvas = canvasComponent;
		}
		setData(chartInfo.data, chartInfo.style);
		positionAxes(chartInfo.axisInfo, data, chartInfo.style);
	}

	public function setData(newData:TrailData, style:TrailStyle) {
		var x = newData.values.get("x");
		var y = newData.values.get("y");
		var groupsArr = newData.values.get("groups");
		var uniqueGroupsNum = 0;
		for (key in style.groups.keys()) {
			uniqueGroupsNum++;
		}

		data.resize(x.length);
		colors.resize(x.length);
		sizes.resize(x.length);
		alphas.resize(x.length);
		borderColors.resize(x.length);
		borderAlphas.resize(x.length);
		borderThickness.resize(x.length);

		for (i in 0...x.length) {
			var group = groupsArr[i];
			var point = new Data2D(x[i], y[i], style.groups.get(group));
			colors[i] = style.colorPalette[style.groups.get(group)];
			borderColors[i] = colors[i];
			data[i] = point;
			sizes[i] = 2;
			alphas[i] = 1;
			borderAlphas[i] = 1;
			borderThickness[i] = 1;
		}

		if (style.size is Float || style.size is Int) {
			var size = cast(style.size, Float);
			sizes = Statistics.repeat(size, sizes.length);
		} else if (style.size is Array) {
			var size:Array<Float> = style.size;
			sizes = size.copy();
			if (size.length == uniqueGroupsNum) {
				for (i in 0...groupsArr.length) {
					sizes[i] = size[style.groups.get(groupsArr[i])];
				}
			}
		}

		if (style.alpha is Float || style.alpha is Int) {
			var alpha = cast(style.alpha, Float);
			alphas = Statistics.repeat(alpha, alphas.length);
		} else if (style.alpha is Array) {
			var alpha:Array<Float> = style.alpha;
			alphas = alpha.copy();
			if (alpha.length == uniqueGroupsNum) {
				for (i in 0...groupsArr.length) {
					alphas[i] = alpha[style.groups.get(groupsArr[i])];
				}
			}
		}

		if (style.borderStyle != null) {
			if (style.borderStyle.color != null) {
				if (style.borderStyle.color is Int) {
					var color = cast(style.borderStyle.color, Int);
					borderColors = Statistics.repeat(color, borderColors.length);
				} else if (style.borderStyle.color is Array) {
					var color:Array<Int> = style.borderStyle.color;
					borderColors = color.copy();
					if (color.length == uniqueGroupsNum) {
						for (i in 0...groupsArr.length) {
							borderColors[i] = color[style.groups.get(groupsArr[i])];
						}
					}
				}
			}

			if (style.borderStyle.alpha is Float || style.borderStyle.alpha is Int) {
				var alpha = cast(style.borderStyle.alpha, Float);
				borderAlphas = Statistics.repeat(alpha, borderAlphas.length);
			} else if (style.borderStyle.alpha is Array) {
				var alpha:Array<Float> = style.borderStyle.alpha;
				borderAlphas = alpha.copy();
				if (alpha.length == uniqueGroupsNum) {
					for (i in 0...groupsArr.length) {
						borderAlphas[i] = alpha[style.groups.get(groupsArr[i])];
					}
				}
			}

			if (style.borderStyle.thickness is Float || style.borderStyle.thickness is Int) {
				var thickness = cast(style.borderStyle.thickness, Float);
				borderThickness = Statistics.repeat(thickness, borderThickness.length);
			} else if (style.borderStyle.thickness is Array) {
				var thickness:Array<Float> = style.borderStyle.thickness;
				borderThickness = thickness.copy();
				if (thickness.length == uniqueGroupsNum) {
					for (i in 0...groupsArr.length) {
						borderThickness[i] = thickness[style.groups.get(groupsArr[i])];
					}
				}
			}
		}
		sortData();
	}

	@:allow(hxchart.tests)
	var minX:Float;
	@:allow(hxchart.tests)
	var maxX:Float;
	@:allow(hxchart.tests)
	var minY:Float;
	@:allow(hxchart.tests)
	var maxY:Float;

	@:allow(hxchart.tests)
	function sortData() {
		var xVals = data.map(x -> {
			return x.xValue;
		});
		var yVals = data.map(x -> {
			return x.yValue;
		});
		if (Std.isOfType(xVals[0], Float)) {
			xVals.sort(Reflect.compare);
			minX = xVals[0];
			maxX = xVals[xVals.length - 1];
		}
		if (Std.isOfType(yVals[0], Float)) {
			yVals.sort(Reflect.compare);
			minY = yVals[0];
			maxY = yVals[yVals.length - 1];
		}
	}

	@:allow(hxchart.tests)
	function setTickInfo(type:AxisTypes, infoValues:Array<Dynamic>, dataValues:Array<Dynamic>, dataMin:Float, dataMax:Float) {
		var tickInfo:TickInfo = null;
		switch (type) {
			case linear:
				var min:Float = dataMin;
				var max:Float = dataMax;
				if (infoValues != null && infoValues.length >= 2) {
					min = infoValues[0];
					max = infoValues[1];
				}
				tickInfo = new NumericTickInfo(min, max);
			case categorical:
				var values:Array<String> = [];
				if (infoValues == null || infoValues.length == 0) {
					for (val in dataValues) {
						values.push(val);
					}
				} else {
					for (val in infoValues) {
						values.push(val);
					}
				}
				tickInfo = new StringTickInfo(values);
		}
		return tickInfo;
	}

	public function positionAxes(axisInfo:Array<AxisInfo>, data:Array<Data2D>, style:TrailStyle) {
		axes = [null, null];
		if (axisInfo[0].axis != null) {
			axes[0] = axisInfo[0].axis;
		}
		if (axisInfo[1].axis != null) {
			axes[1] = axisInfo[1].axis;
		}
		if (axes[0] != null && axes[1] != null) {
			positionData(style);
			return;
		}

		var yAxisLength = parent.height * 0.9;
		var xAxisLength = parent.width * 0.9;
		var isPreviousXAxis = false;
		var isPreviousYAxis = false;
		if (axes[0] == null) {
			var xTickInfo = setTickInfo(axisInfo[0].type, axisInfo[0].values, data.map(x -> {
				return x.xValue;
			}), minX, maxX);
			axes[0] = new Axis(new Point(0, 0), 0, xAxisLength, xTickInfo, "x" + axisID);
		} else {
			isPreviousXAxis = true;
		}
		if (axes[1] == null) {
			var yTickInfo = setTickInfo(axisInfo[1].type, axisInfo[1].values, data.map(x -> {
				return x.yValue;
			}), minY, maxY);
			axes[1] = new Axis(new Point(0, 0), 270, yAxisLength, yTickInfo, "y" + axisID);
		} else {
			isPreviousYAxis = true;
		}
		axes[0].percentWidth = 100;
		axes[0].percentHeight = 100;
		axes[1].percentWidth = 100;
		axes[1].percentHeight = 100;

		axes[0].linkedAxes = new Map();
		axes[0].linkedAxes.set("y", axes[1]);
		axes[1].linkedAxes = new Map();
		axes[1].linkedAxes.set("x", axes[0]);

		axes[0].centerStartPoint(parent.width, parent.height);
		axes[1].centerStartPoint(parent.width, parent.height);
		axes[1].showZeroTick = false;
		axes[0].zeroTickPosition = CompassOrientation.SW;
		// Positioning data before axes, so that axes are drawn on top of data.
		positionData(chartInfo.style);
		if (isPreviousXAxis) {
			AxisTools.addAxisToParent(axes[0], parent);
		} else {
			AxisTools.replaceAxisInParent(axes[0], parent);
		}
		if (isPreviousYAxis) {
			AxisTools.addAxisToParent(axes[1], parent);
		} else {
			AxisTools.replaceAxisInParent(axes[1], parent);
		}
	}

	public function positionData(style:TrailStyle) {
		if (axes.length < 2) {
			throw new Exception("Too few axes for drawing data.");
		}
		if (axes[0].tickInfo == null || axes[1].tickInfo == null) {
			throw new Exception("Two tickinfos are needed for positioning the data correctly!");
		}
		var x_coord_min = axes[0].ticks[0].left;
		var x_coord_max = axes[0].ticks[axes[0].ticks.length - 1].left;
		var ratio = 1.0;
		if (Std.isOfType(axes[0].tickInfo, NumericTickInfo)) {
			var tickInfo:NumericTickInfo = cast(axes[0].tickInfo, NumericTickInfo);
			ratio = 1 - tickInfo.negNum / (tickInfo.tickNum - 1);
		}
		var x_dist = ChartTools.calcAxisDists(x_coord_min, x_coord_max, ratio);
		var y_coord_min = axes[1].ticks[0].top;
		var y_coord_max = axes[1].ticks[axes[1].ticks.length - 1].top;
		ratio = 1.0;
		if (Std.isOfType(axes[1].tickInfo, NumericTickInfo)) {
			var tickInfo:NumericTickInfo = cast(axes[1].tickInfo, NumericTickInfo);
			ratio = 1 - tickInfo.negNum / (tickInfo.tickNum - 1);
		}
		var y_dist = ChartTools.calcAxisDists(y_coord_max, y_coord_min, ratio);
		if (x_dist.pos_dist < 0 || y_dist.pos_dist < 0) {
			return;
		}

		// Coordinates calculation
		var xCoords:Array<Float> = [];
		xCoords.resize(data.length);
		var yCoords:Array<Float> = [];
		yCoords.resize(data.length);
		var allowedIndeces = [];
		for (i => dataPoint in data) {
			var x = calcXCoord(dataPoint.xValue, axes[0].ticks, axes[0].ticks[axes[0].tickInfo.zeroIndex].left, x_dist);
			var y = calcYCoord(dataPoint.yValue, axes[1].ticks, axes[1].ticks[axes[1].tickInfo.zeroIndex].top, y_dist);
			if (x == null || y == null) {
				continue;
			}
			xCoords[i] = x;
			yCoords[i] = y;
		}

		// Optimization
		if (useOptimization) {
			switch (chartInfo.optimizationInfo.reduceVia) {
				case OptimizationType.optimGrid:
					for (i => coord in xCoords) {
						var xRound = Math.round(xCoords[i] * 1 / gridStep);
						var yRound = Math.round(yCoords[i] * 1 / gridStep);
						if (xRound < optimGrid.grid.length) {
							if (yRound < optimGrid.grid[xRound].length) {
								if (!optimGrid.grid[xRound][yRound]) {
									optimGrid.grid[xRound][yRound] = true;
									allowedIndeces.push(i);
								}
							}
						}
					}
				case OptimizationType.quadTree:
					for (i => coord in xCoords) {
						if (quadTree.search(new Region(xCoords[i] - 2, xCoords[i] + 2, yCoords[i] - 2, yCoords[i] + 2), []).length == 0) {
							quadTree.addPoint(new Point(xCoords[i], yCoords[i]));
							allowedIndeces.push(i);
						}
					}
			}
		} else {
			for (i => coord in xCoords) {
				allowedIndeces.push(i);
			}
		}

		dataCanvas.componentGraphics.clear();

		// Drawing
		for (i in allowedIndeces) {
			dataCanvas.componentGraphics.strokeStyle(borderColors[i], borderThickness[i], borderAlphas[i]);
			dataCanvas.componentGraphics.fillStyle(colors[i], alphas[i]);

			dataCanvas.componentGraphics.circle(xCoords[i], yCoords[i], sizes[i]);
		}

		var canvasComponent = parent.findComponent(id);
		if (canvasComponent == null) {
			parent.addComponent(dataCanvas);
		}
	}

	public function calcXCoord(xValue:Dynamic, ticks:Array<Ticks>, zeroPos:Float, xDist:AxisDist) {
		if (Std.isOfType(xValue, String)) {
			var ticksFiltered = ticks.filter(x -> {
				return x.text == xValue;
			});
			if (ticksFiltered == null || ticksFiltered.length == 0) {
				return null;
			}
			return ticksFiltered[0].left;
		}
		var xMax = Std.parseFloat(ticks[ticks.length - 1].text);
		var xMin = Std.parseFloat(ticks[0].text);
		var x_ratio:Float = 0.0;
		if (xValue > 0) {
			x_ratio = xValue / xMax;
		}
		var x = zeroPos + xDist.pos_dist * x_ratio;
		if (xValue < 0) {
			x_ratio = xValue / xMin;
			x = zeroPos - xDist.neg_dist * x_ratio;
		}
		return x;
	}

	public function calcYCoord(yValue:Dynamic, ticks:Array<Ticks>, zeroPos:Float, yDist:AxisDist) {
		if (Std.isOfType(yValue, String)) {
			var ticksFiltered = ticks.filter(x -> {
				return x.text == yValue;
			});
			if (ticksFiltered == null || ticksFiltered.length == 0) {
				return null;
			}
			return ticksFiltered[0].top;
		}
		var yMax = Std.parseFloat(ticks[ticks.length - 1].text);
		var yMin = Std.parseFloat(ticks[0].text);
		var y_ratio:Float = 0;
		if (yValue > 0) {
			y_ratio = yValue / yMax;
		}
		var y = zeroPos - yDist.pos_dist * y_ratio;
		if (yValue < 0) {
			y_ratio = yValue / yMin;
			y = zeroPos + yDist.neg_dist * y_ratio;
		}
		return y;
	}
}
