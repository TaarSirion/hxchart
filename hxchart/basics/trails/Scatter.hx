package hxchart.basics.trails;

import hxchart.basics.plot.Chart.PositionOption;
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
	public var axes:Axis;

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
	public var chartInfo:TrailInfo;

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

	public function positionAxes(axisInfo:Array<AxisInfo>, data:Array<Any>, style:TrailStyle) {
		if (axes != null) {
			positionData(style);
			return;
		}
		axes = new Axis(axisID, axisInfo);
		// axes.id = axisID;
		axes.width = parent.width;
		axes.height = parent.height;
		axes.positionStartPoint();
		axes.setTicks(false);
		positionData(chartInfo.style);
		AxisTools.replaceAxisInParent(axes, parent);
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

		// Hover event handling
		eventHandler.hoverHandlers.push(function(e) {
			hoverLayer.componentGraphics.clear();
			if (chartInfo.events != null && chartInfo.events.onHover != null) {
				for (group in dataByGroup) {
					for (dataPoint in group) {
						if (!dataPoint.allowed) {
							continue;
						}
						if (inPointRadius(new Point(e.localX, e.localY), new Point(dataPoint.coord.x + parent.left, dataPoint.coord.y + parent.top),
							dataPoint.size + dataPoint.borderThickness)) {
							var selectInfo = chartInfo.events.onHover({
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
					if (inPointRadius(new Point(e.localX, e.localY), new Point(dataPoint.coord.x + parent.left, dataPoint.coord.y + parent.top),
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
							var selectInfo = chartInfo.events.onHover({
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
		trace("PLOT");
		// Drawing
		dataCanvas.componentGraphics.clear();
		if (chartInfo.type == line) {
			dataCanvas.componentGraphics.clear();
			for (group in dataByGroup) {
				var start = group[0].coord;
				var last = start;
				if (style.positionOption == filled) {
					dataCanvas.componentGraphics.fillStyle(group[0].color, 0.5);
				} else {
					dataCanvas.componentGraphics.fillStyle(0x000000, 0);
				}
				trace("group ", start, last);
				dataCanvas.componentGraphics.strokeStyle(group[0].color, group[0].size, group[0].alpha);
				#if !(haxeui_heaps)
				dataCanvas.componentGraphics.beginPath();
				#end
				dataCanvas.componentGraphics.moveTo(last.x, last.y);
				for (i => dataPoint in group) {
					if (!dataPoint.allowed) {
						continue;
					}
					trace(dataPoint.coord);
					dataCanvas.componentGraphics.lineTo(dataPoint.coord.x, dataPoint.coord.y);
					last = dataPoint.coord;
				}
				if (style.positionOption == filled) {
					dataCanvas.componentGraphics.lineTo(last.x, axes.ticksPerInfo[1][axes.axesInfo[1].tickInfo.zeroIndex].top);
					dataCanvas.componentGraphics.lineTo(start.x, axes.ticksPerInfo[1][axes.axesInfo[1].tickInfo.zeroIndex].top);
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

	public function calcXCoord(xValue:Dynamic, ticks:Array<Ticks>) {
		if (Std.isOfType(xValue, String)) {
			var ticksFiltered = ticks.filter(x -> {
				return x.text == xValue;
			});
			if (ticksFiltered == null || ticksFiltered.length == 0) {
				return null;
			}
			return ticksFiltered[0].left;
		}
		var largerTicks = ticks.filter(tick -> Std.parseFloat(tick.text) >= xValue);
		var xMax = Std.parseFloat(largerTicks[0].text);
		var maxIndex = ticks.indexOf(largerTicks[0]);
		var minIndex = maxIndex == 0 ? 0 : maxIndex - 1;
		var xMin = Std.parseFloat(ticks[minIndex].text);
		if (xMax == xMin) {
			return ticks[minIndex].left;
		}
		var tickLeft = ticks[minIndex].left;
		var tickRight = largerTicks[0].left;
		var x = (tickRight - tickLeft) * (xValue - xMin) / (xMax - xMin) + tickLeft;
		return x;
	}

	public function calcYCoord(yValue:Dynamic, ticks:Array<Ticks>) {
		if (Std.isOfType(yValue, String)) {
			var ticksFiltered = ticks.filter(x -> {
				return x.text == yValue;
			});
			if (ticksFiltered == null || ticksFiltered.length == 0) {
				return null;
			}
			return ticksFiltered[0].top;
		}
		var largerTicks = ticks.filter(tick -> Std.parseFloat(tick.text) >= yValue);
		var yMax = Std.parseFloat(largerTicks[0].text);
		var maxIndex = ticks.indexOf(largerTicks[0]);
		var minIndex = maxIndex == 0 ? 0 : maxIndex - 1;
		var yMin = Std.parseFloat(ticks[minIndex].text);
		if (yMin == yMax) {
			return ticks[minIndex].top;
		}
		var tickBottom = ticks[minIndex].top;
		var tickTop = largerTicks[0].top;
		var y = tickBottom - (tickBottom - tickTop) * (yValue - yMin) / (yMax - yMin);
		return y;
	}

	private function inPointRadius(mouseCoords:Point, pointCenter:Point, size:Float) {
		var dist = Math.pow(pointCenter.x - mouseCoords.x, 2) + Math.pow(pointCenter.y - mouseCoords.y, 2);
		return dist <= Math.pow(size, 2);
	}
}
