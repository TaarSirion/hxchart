package hxchart.basics.trails;

import hxchart.basics.events.EventLayer.EventHandler;
import hxchart.basics.plot.Chart.OptimizationType;
import hxchart.basics.quadtree.OptimGrid;
import hxchart.basics.quadtree.Quadtree;
import hxchart.basics.axis.AxisTools;
import hxchart.basics.utils.ChartTools;
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
import hxchart.basics.plot.Chart.TrailInfo;
import hxchart.basics.data.DataLayer;
import hxchart.basics.axis.AxisLayer;

typedef ScatterDataPoint = {
	coord:Point,
	values:{
		x:Any, y:Any
	},
	size:Float,
	alpha:Float,
	color:Color,
	borderAlpha:Float,
	borderColor:Color,
	borderThickness:Float,
	allowed:Bool
}

class Scatter implements AxisLayer implements DataLayer {
	public var id:String;
	public var axisID:String;
	public var axes:Array<Axis>;

	public var dataByGroup:Array<Array<ScatterDataPoint>> = [];
	public var data:Array<Any>;
	public var dataLayer:Absolute;
	public var dataCanvas:Canvas;

	var dataSize:Int;

	var quadTree:Quadtree;
	var optimGrid:OptimGrid;
	var gridStep:Float = 1;
	var useOptimization:Bool;

	@:allow(hxchart.tests)
	private var chartInfo:TrailInfo;

	public var colorPalette:Array<Int>;

	public var parent:Absolute;
	public var eventHandler:EventHandler;
	public var hoverLayer:Canvas;
	public var clickLayer:Canvas;

	public function new(chartInfo:TrailInfo, parent:Absolute, id:String, axisID:String, eventHandler:EventHandler) {
		this.parent = parent;
		this.eventHandler = eventHandler;
		hoverLayer = new Canvas();
		hoverLayer.id = id + "_hover";
		hoverLayer.percentHeight = 100;
		hoverLayer.percentWidth = 100;
		clickLayer = new Canvas();
		clickLayer.id = id + "_click";
		clickLayer.percentHeight = 100;
		clickLayer.percentWidth = 100;
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
		var canvasComponent = parent.findComponent(id + "_hover");
		if (canvasComponent != null) {
			hoverLayer = canvasComponent;
		}
		var canvasComponent = parent.findComponent(id + "_click");
		if (canvasComponent != null) {
			clickLayer = canvasComponent;
		}
		setData(chartInfo.data, chartInfo.style);
		positionAxes(chartInfo.axisInfo, dataByGroup, chartInfo.style);
	}

	@:allow(hxchart.tests)
	var minX:Float = Math.POSITIVE_INFINITY;
	@:allow(hxchart.tests)
	var maxX:Float = Math.NEGATIVE_INFINITY;
	@:allow(hxchart.tests)
	var minY:Float = Math.POSITIVE_INFINITY;
	@:allow(hxchart.tests)
	var maxY:Float = Math.NEGATIVE_INFINITY;

	public function setData(newData:TrailData, style:TrailStyle) {
		var x = newData.values.get("x");
		var y = newData.values.get("y");
		dataSize = x.length;
		var groupsArr = newData.values.get("groups");
		var uniqueGroupsNum = 0;
		dataByGroup = [];
		for (key in style.groups.keys()) {
			uniqueGroupsNum++;
			dataByGroup.push([]);
		}

		for (i in 0...x.length) {
			var group = groupsArr[i];
			var groupIndex = style.groups.get(group);
			maxX = Math.max(maxX, x[i]);
			minX = Math.min(minX, x[i]);
			maxY = Math.max(maxY, y[i]);
			minY = Math.min(minY, y[i]);
			dataByGroup[groupIndex].push({
				coord: new Point(0, 0),
				values: {
					x: x[i],
					y: y[i]
				},
				size: 2,
				color: style.colorPalette[groupIndex],
				alpha: 1,
				borderColor: style.colorPalette[groupIndex],
				borderThickness: 1,
				borderAlpha: 1,
				allowed: false
			});
		}
		if (style.size is Float || style.size is Int) {
			var size = cast(style.size, Float);
			for (group in dataByGroup) {
				for (dataPoint in group) {
					dataPoint.size = size;
				}
			}
		} else if (style.size is Array) {
			var size:Array<Float> = style.size;
			if (size.length == x.length) {
				var i = 0;
				for (group in dataByGroup) {
					for (dataPoint in group) {
						dataPoint.size = size[i];
						i++;
					}
				}
			} else if (size.length == uniqueGroupsNum) {
				for (i in 0...uniqueGroupsNum) {
					var groupSize = size[i];
					for (dataPoint in dataByGroup[i]) {
						dataPoint.size = groupSize;
					}
				}
			}
		}

		if (style.alpha is Float || style.alpha is Int) {
			var alpha = cast(style.alpha, Float);
			for (group in dataByGroup) {
				for (dataPoint in group) {
					dataPoint.alpha = alpha;
				}
			}
		} else if (style.alpha is Array) {
			var alpha:Array<Float> = style.alpha;
			if (alpha.length == x.length) {
				var i = 0;
				for (group in dataByGroup) {
					for (dataPoint in group) {
						dataPoint.alpha = alpha[i];
						i++;
					}
				}
			} else if (alpha.length == uniqueGroupsNum) {
				for (i in 0...uniqueGroupsNum) {
					var groupAlpha = alpha[i];
					for (dataPoint in dataByGroup[i]) {
						dataPoint.alpha = groupAlpha;
					}
				}
			}
		}

		if (style.borderStyle != null) {
			if (style.borderStyle.color != null) {
				if (style.borderStyle.color is Int) {
					var color = cast(style.borderStyle.color, Int);
					for (group in dataByGroup) {
						for (dataPoint in group) {
							dataPoint.borderColor = color;
						}
					}
				} else if (style.borderStyle.color is Array) {
					var color:Array<Int> = style.borderStyle.color;
					if (color.length == x.length) {
						var i = 0;
						for (group in dataByGroup) {
							for (dataPoint in group) {
								dataPoint.borderColor = color[i];
								i++;
							}
						}
					} else if (color.length == uniqueGroupsNum) {
						for (i in 0...uniqueGroupsNum) {
							var groupColor = color[i];
							for (dataPoint in dataByGroup[i]) {
								dataPoint.borderColor = groupColor;
							}
						}
					}
				}
			}

			if (style.borderStyle.alpha is Float || style.borderStyle.alpha is Int) {
				var alpha = cast(style.borderStyle.alpha, Float);
				for (group in dataByGroup) {
					for (dataPoint in group) {
						dataPoint.borderAlpha = alpha;
					}
				}
			} else if (style.borderStyle.alpha is Array) {
				var alpha:Array<Float> = style.borderStyle.alpha;
				if (alpha.length == x.length) {
					var i = 0;
					for (group in dataByGroup) {
						for (dataPoint in group) {
							dataPoint.borderAlpha = alpha[i];
							i++;
						}
					}
				} else if (alpha.length == uniqueGroupsNum) {
					for (i in 0...uniqueGroupsNum) {
						var groupAlpha = alpha[i];
						for (dataPoint in dataByGroup[i]) {
							dataPoint.borderAlpha = groupAlpha;
						}
					}
				}
			}

			if (style.borderStyle.thickness is Float || style.borderStyle.thickness is Int) {
				var thickness = cast(style.borderStyle.thickness, Float);
				for (group in dataByGroup) {
					for (dataPoint in group) {
						dataPoint.borderThickness = thickness;
					}
				}
			} else if (style.borderStyle.thickness is Array) {
				var thickness:Array<Float> = style.borderStyle.thickness;
				if (thickness.length == x.length) {
					var i = 0;
					for (group in dataByGroup) {
						for (dataPoint in group) {
							dataPoint.borderThickness = thickness[i];
							i++;
						}
					}
				} else if (thickness.length == uniqueGroupsNum) {
					for (i in 0...uniqueGroupsNum) {
						var groupThickness = thickness[i];
						for (dataPoint in dataByGroup[i]) {
							dataPoint.borderThickness = groupThickness;
						}
					}
				}
			}
		}
	}

	@:allow(hxchart.tests)
	function setTickInfo(type:AxisTypes, infoValues:Array<Any>, dataValues:Array<Any>, dataMin:Float, dataMax:Float) {
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

	public function positionAxes(axisInfo:Array<AxisInfo>, data:Array<Any>, style:TrailStyle) {
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
			var xValues = [];
			for (any in data) {
				var group:Array<ScatterDataPoint> = any;
				xValues = xValues.concat(group.map(dataPoint -> {
					return dataPoint.values.x;
				}));
			}
			var xTickInfo = setTickInfo(axisInfo[0].type, axisInfo[0].values, xValues, minX, maxX);
			axes[0] = new Axis(new Point(0, 0), 0, xAxisLength, xTickInfo, "x" + axisID);
		} else {
			isPreviousXAxis = true;
		}
		if (axes[1] == null) {
			var yValues = [];
			for (any in data) {
				var group:Array<ScatterDataPoint> = any;
				yValues = yValues.concat(group.map(dataPoint -> {
					return dataPoint.values.y;
				}));
			}
			var yTickInfo = setTickInfo(axisInfo[1].type, axisInfo[1].values, yValues, minY, maxY);
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
		for (group in dataByGroup) {
			for (dataPoint in group) {
				var x = calcXCoord(dataPoint.values.x, axes[0].ticks, axes[0].ticks[axes[0].tickInfo.zeroIndex].left, x_dist);
				var y = calcYCoord(dataPoint.values.y, axes[1].ticks, axes[1].ticks[axes[1].tickInfo.zeroIndex].top, y_dist);
				if (x == null || y == null) {
					continue;
				}
				dataPoint.coord = new Point(x, y);
			}
		}

		// Optimization
		if (useOptimization) {
			switch (chartInfo.optimizationInfo.reduceVia) {
				case OptimizationType.optimGrid:
					for (group in dataByGroup) {
						for (dataPoint in group) {
							var xRound = Math.round(dataPoint.coord.x * 1 / gridStep);
							var yRound = Math.round(dataPoint.coord.y * 1 / gridStep);
							if (xRound < optimGrid.grid.length) {
								if (yRound < optimGrid.grid[xRound].length) {
									if (!optimGrid.grid[xRound][yRound]) {
										optimGrid.grid[xRound][yRound] = true;
										dataPoint.allowed = true;
									}
								}
							}
						}
					}
				case OptimizationType.quadTree:
					for (group in dataByGroup) {
						for (dataPoint in group) {
							var xCoord = dataPoint.coord.x;
							var yCoord = dataPoint.coord.y;
							if (quadTree.search(new Region(xCoord - 2, xCoord + 2, yCoord - 2, yCoord + 2), []).length == 0) {
								quadTree.addPoint(new Point(xCoord, yCoord));
								dataPoint.allowed = true;
							}
						}
					}
			}
		} else {
			for (group in dataByGroup) {
				for (dataPoint in group) {
					dataPoint.allowed = true;
				}
			}
		}

		// Hover event handling
		eventHandler.hoverHandlers.push(function(e) {
			hoverLayer.componentGraphics.clear();
			if (chartInfo.events != null && chartInfo.events.onHandle != null) {
				for (group in dataByGroup) {
					for (dataPoint in group) {
						if (!dataPoint.allowed) {
							continue;
						}
						if (inPointRadius(new Point(e.localX, e.localY), new Point(dataPoint.coord.x, dataPoint.coord.y),
							dataPoint.size + dataPoint.borderThickness)) {
							var selectInfo = chartInfo.events.onHandle({
								coords: [dataPoint.coord],
								border: {
									thickness: dataPoint.borderThickness,
									color: dataPoint.borderColor,
									alpha: dataPoint.borderAlpha
								},
								alpha: dataPoint.alpha,
								color: dataPoint.color,
								size: dataPoint.size
							});
							hoverLayer.componentGraphics.strokeStyle(selectInfo.border.color, selectInfo.border.thickness, selectInfo.border.alpha);
							hoverLayer.componentGraphics.fillStyle(selectInfo.color, selectInfo.alpha);
							hoverLayer.componentGraphics.circle(selectInfo.coords[0].x, selectInfo.coords[0].y, selectInfo.size);
						}
					}
				}
				return;
			}
			for (group in dataByGroup) {
				for (dataPoint in group) {
					if (!dataPoint.allowed) {
						continue;
					}
					if (inPointRadius(new Point(e.localX, e.localY), new Point(dataPoint.coord.x, dataPoint.coord.y),
						dataPoint.size + dataPoint.borderThickness)) {
						hoverLayer.componentGraphics.fillStyle(Color.fromString("#ffffff"), 0.5);
						hoverLayer.componentGraphics.circle(dataPoint.coord.x, dataPoint.coord.y, dataPoint.size);
					}
				}
			}
		});

		// Click event handling
		eventHandler.clickHandlers.push(function(e) {
			clickLayer.componentGraphics.clear();
			if (chartInfo.events != null && chartInfo.events.onClick != null) {
				for (group in dataByGroup) {
					for (dataPoint in group) {
						if (!dataPoint.allowed) {
							continue;
						}
						if (inPointRadius(new Point(e.localX, e.localY), new Point(dataPoint.coord.x, dataPoint.coord.y),
							dataPoint.size + dataPoint.borderThickness)) {
							var selectInfo = chartInfo.events.onHandle({
								coords: [dataPoint.coord],
								border: {
									thickness: dataPoint.borderThickness,
									color: dataPoint.borderColor,
									alpha: dataPoint.borderAlpha
								},
								alpha: dataPoint.alpha,
								color: dataPoint.color,
								size: dataPoint.size
							});
							hoverLayer.componentGraphics.strokeStyle(selectInfo.border.color, selectInfo.border.thickness, selectInfo.border.alpha);
							hoverLayer.componentGraphics.fillStyle(selectInfo.color, selectInfo.alpha);
							hoverLayer.componentGraphics.circle(selectInfo.coords[0].x, selectInfo.coords[0].y, selectInfo.size);
						}
					}
				}
				return;
			}
			for (group in dataByGroup) {
				for (dataPoint in group) {
					if (!dataPoint.allowed) {
						continue;
					}
					if (inPointRadius(new Point(e.localX, e.localY), new Point(dataPoint.coord.x, dataPoint.coord.y),
						dataPoint.size + dataPoint.borderThickness)) {
						hoverLayer.componentGraphics.fillStyle(Color.fromString("#ffffff"), 0.5);
						hoverLayer.componentGraphics.circle(dataPoint.coord.x, dataPoint.coord.y, dataPoint.size);
					}
				}
			}
		});

		// Drawing
		dataCanvas.componentGraphics.clear();
		if (chartInfo.type == line) {
			dataCanvas.componentGraphics.clear();
			for (group in dataByGroup) {
				var start = group[0].coord;
				var last = start;
				if (style.positionOption == filled) {
					dataCanvas.componentGraphics.fillStyle(group[0].color, 0.5);
				}
				dataCanvas.componentGraphics.strokeStyle(group[0].color, group[0].size, group[0].size);
				dataCanvas.componentGraphics.moveTo(last.x, last.y);
				#if !(haxeui_heaps)
				dataCanvas.componentGraphics.beginPath();
				#end
				for (dataPoint in group) {
					if (!dataPoint.allowed) {
						continue;
					}
					dataCanvas.componentGraphics.lineTo(dataPoint.coord.x, dataPoint.coord.y);
					last = dataPoint.coord;
				}
				if (style.positionOption == filled) {
					dataCanvas.componentGraphics.lineTo(last.x, axes[1].ticks[axes[1].tickInfo.zeroIndex].top);
					dataCanvas.componentGraphics.lineTo(start.x, axes[1].ticks[axes[1].tickInfo.zeroIndex].top);
					dataCanvas.componentGraphics.lineTo(start.x, start.y);
					#if !(haxeui_heaps)
					dataCanvas.componentGraphics.closePath();
					#end
				}
			}
		} else {
			for (group in dataByGroup) {
				for (dataPoint in group) {
					if (!dataPoint.allowed) {
						continue;
					}
					dataCanvas.componentGraphics.strokeStyle(dataPoint.borderColor, dataPoint.borderThickness, dataPoint.borderAlpha);
					dataCanvas.componentGraphics.fillStyle(dataPoint.color, dataPoint.alpha);
					dataCanvas.componentGraphics.circle(dataPoint.coord.x, dataPoint.coord.y, dataPoint.size);
				}
			}
		}

		var canvasComponent = parent.findComponent(id);
		if (canvasComponent == null) {
			parent.addComponent(dataCanvas);
			parent.addComponent(hoverLayer);
			parent.addComponent(clickLayer);
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

	private function inPointRadius(mouseCoords:Point, pointCenter:Point, size:Float) {
		var dist = Math.pow(pointCenter.x - mouseCoords.x, 2) + Math.pow(pointCenter.y - mouseCoords.y, 2);
		return dist <= Math.pow(size, 2);
	}
}
