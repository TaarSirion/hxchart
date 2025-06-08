package hxchart.core.trails;

import hxchart.core.coordinates.TrailCalcs;
import hxchart.core.axis.AxisInfo;
import hxchart.core.styling.TrailStyle;
import hxchart.core.axis.Axis;
import hxchart.core.coordinates.CoordinateSystem;
import hxchart.core.tick.Tick;
import hxchart.core.optimization.OptimGrid;
import hxchart.core.optimization.Quadtree;
import hxchart.core.optimization.OptimizationType;
import hxchart.core.utils.Point;
import hxchart.core.data.DataLayer;
import hxchart.core.axis.AxisLayer;

typedef ScatterDataPoint = {
	coord:Point,
	values:{
		x:Any, y:Any
	},
	size:Float,
	alpha:Float,
	color:Int,
	borderAlpha:Float,
	borderColor:Int,
	borderThickness:Float,
	allowed:Bool
}

class Scatter implements AxisLayer implements DataLayer {
	public var coordSystem:CoordinateSystem;
	public var axes:Axis;

	public var dataByGroup:Array<Array<ScatterDataPoint>> = [];
	public var data:Array<Any>;

	var dataSize:Int;

	var quadTree:Quadtree;
	var optimGrid:OptimGrid;
	var gridStep:Float = 1;
	var useOptimization:Bool;
	var keepHoverOn:Bool = false;

	@:allow(hxchart.tests)
	public var chartInfo:TrailInfo;

	public var colorPalette:Array<Int>;

	public function new(chartInfo:TrailInfo, axes:Axis, coordSystem:CoordinateSystem) {
		this.coordSystem = coordSystem;
		this.chartInfo = chartInfo;
		if (axes != null) {
			this.axes = axes;
		}
		if (chartInfo.optimizationInfo != null && chartInfo.optimizationInfo.reduceVia != null) {
			useOptimization = true;
			switch (chartInfo.optimizationInfo.reduceVia) {
				case OptimizationType.optimGrid:
					if (chartInfo.optimizationInfo.gridStep != null) {
						gridStep = chartInfo.optimizationInfo.gridStep;
					}
					optimGrid = new OptimGrid(coordSystem.end.x - coordSystem.start.x, coordSystem.end.y - coordSystem.start.y, gridStep);
				case OptimizationType.quadTree:
					quadTree = new Quadtree(new Region(0, coordSystem.end.x - coordSystem.start.x, 0, coordSystem.end.y - coordSystem.start.y));
			}
		}
	}

	public function validateChart() {
		setData(chartInfo.data, chartInfo.style);
		positionAxes(chartInfo.axisInfo, chartInfo.style);
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
		if (Std.isOfType(style.size, Float) || Std.isOfType(style.size, Int)) {
			var size = cast(style.size, Float);
			for (group in dataByGroup) {
				for (dataPoint in group) {
					dataPoint.size = size;
				}
			}
		} else if (Std.isOfType(style.size, Array)) {
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

		if (Std.isOfType(style.alpha, Float) || Std.isOfType(style.alpha, Int)) {
			var alpha = cast(style.alpha, Float);
			for (group in dataByGroup) {
				for (dataPoint in group) {
					dataPoint.alpha = alpha;
				}
			}
		} else if (Std.isOfType(style.alpha, Array)) {
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
				if (Std.isOfType(style.borderStyle.color, Int)) {
					var color = cast(style.borderStyle.color, Int);
					for (group in dataByGroup) {
						for (dataPoint in group) {
							dataPoint.borderColor = color;
						}
					}
				} else if (Std.isOfType(style.borderStyle.color, Array)) {
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

			if (Std.isOfType(style.borderStyle.alpha, Float) || Std.isOfType(style.borderStyle.alpha, Int)) {
				var alpha = cast(style.borderStyle.alpha, Float);
				for (group in dataByGroup) {
					for (dataPoint in group) {
						dataPoint.borderAlpha = alpha;
					}
				}
			} else if (Std.isOfType(style.borderStyle.alpha, Array)) {
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

			if (Std.isOfType(style.borderStyle.thickness, Float) || Std.isOfType(style.borderStyle.thickness, Int)) {
				var thickness = cast(style.borderStyle.thickness, Float);
				for (group in dataByGroup) {
					for (dataPoint in group) {
						dataPoint.borderThickness = thickness;
					}
				}
			} else if (Std.isOfType(style.borderStyle.thickness, Array)) {
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

	public function positionAxes(axisInfo:Array<AxisInfo>, style:TrailStyle) {
		if (axes != null) {
			axes.positionStartPoint();
			axes.setTicks(true);
			positionData(style);
			return;
		}
		axes = new Axis(axisInfo, coordSystem);
		axes.positionStartPoint();
		axes.setTicks(false);
		positionData(chartInfo.style);
	}

	public function positionData(style:TrailStyle) {
		if (axes.ticksPerInfo[0].length == 0) {
			return;
		}

		// Coordinates calculation
		for (group in dataByGroup) {
			for (dataPoint in group) {
				var x = calcXCoord(dataPoint.values.x, axes.ticksPerInfo[0]);
				var y = calcYCoord(dataPoint.values.y, axes.ticksPerInfo[1]);
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
	}

	public function calcXCoord(xValue:Dynamic, ticks:Array<Tick>) {
		if (Std.isOfType(xValue, String)) {
			var pos = TrailCalcs.getCategoricPosFromTick(xValue, ticks);
			if (pos == null) {
				return null;
			}
			return pos.x;
		}
		return TrailCalcs.calcScatterCoordinates(ticks, xValue, false);
	}

	public function calcYCoord(yValue:Dynamic, ticks:Array<Tick>) {
		if (Std.isOfType(yValue, String)) {
			var pos = TrailCalcs.getCategoricPosFromTick(yValue, ticks);
			if (pos == null) {
				return null;
			}
			return pos.y;
		}
		return TrailCalcs.calcScatterCoordinates(ticks, yValue, true);
	}
}
