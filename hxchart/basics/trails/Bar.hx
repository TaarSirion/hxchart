package hxchart.basics.trails;

import hxchart.basics.plot.Chart.PositionOption;
import hxchart.basics.ticks.Ticks;
import hxchart.basics.utils.ChartTools;
import hxchart.basics.ticks.Ticks.CompassOrientation;
import haxe.ui.geom.Point;
import hxchart.basics.axis.AxisTools;
import hxchart.basics.axis.StringTickInfo;
import hxchart.basics.axis.NumericTickInfo;
import hxchart.basics.axis.TickInfo;
import haxe.Exception;
import hxchart.basics.plot.Chart.TrailStyle;
import hxchart.basics.axis.Axis;
import haxe.ui.util.Color;
import haxe.ui.components.Canvas;
import hxchart.basics.data.Data2D;
import haxe.ui.containers.Absolute;
import hxchart.basics.plot.Chart.TrailInfo;
import hxchart.basics.data.DataLayer;
import hxchart.basics.axis.AxisLayer;

using hxchart.basics.utils.Statistics;

typedef BarDataRec = {
	coord:Point,
	width:Float,
	height:Float,
	values:{
		x:Any, y:Any
	},
	allowed:Bool
}

class Bar implements AxisLayer implements DataLayer {
	public var id:String;
	public var data:Array<Any>;
	public var parent:Absolute;
	public var dataCanvas:Canvas;
	public var colors:Array<Color>;
	public var axes:Axis;

	public var trailInfo:TrailInfo;
	public var axisID:String;

	public var dataByGroup:Array<Array<BarDataRec>> = [];

	public function new(trailInfo:TrailInfo, parent:Absolute, id:String, axisID:String) {
		if (trailInfo.axisInfo[0].type == linear && trailInfo.axisInfo[1].type == linear) {
			throw new Exception("It is not possible to use two 'linear' axes for a bar-chart. Please change one of them to 'categorical'.");
		}
		if (trailInfo.axisInfo[0].type == categorical && trailInfo.axisInfo[1].type == categorical) {
			throw new Exception("It is not possible to use two 'categorical' axes for a bar-chart. Please change one of them to 'linear'.");
		}

		valueGroups = [];
		xValues = [];
		yValues = [];

		this.parent = parent;
		dataCanvas = new Canvas();
		dataCanvas.id = id;
		dataCanvas.percentHeight = 100;
		dataCanvas.percentWidth = 100;
		this.id = id;
		this.axisID = axisID;
		this.trailInfo = trailInfo;
	}

	public function validateChart() {
		setData(trailInfo.data, trailInfo.style);
		positionAxes(trailInfo.axisInfo, data, trailInfo.style);
	}

	var minX:Float;
	var maxX:Float;
	var minY:Float;
	var maxY:Float;

	public function setData(newData:TrailData, style:TrailStyle) {
		data = [];
		colors = [];
		dataByGroup = [];

		var x = newData.values.get("x");
		var y = newData.values.get("y");
		var groupsArr = newData.values.get("groups");
		var uniqueGroupsNum = 0;
		dataByGroup = [];
		for (key in style.groups.keys()) {
			uniqueGroupsNum++;
			dataByGroup.push([]);
		}

		if (x[0] is String) {
			isXCategoric = true;
		}

		for (i in 0...x.length) {
			var group = groupsArr[i];
			var groupIndex = style.groups.get(group);
			if (x[i] is Float) {
				maxX = Math.max(maxX, x[i]);
				minX = Math.min(minX, x[i]);
			} else {
				maxY = Math.max(maxY, y[i]);
				minY = Math.min(minY, y[i]);
			}
			dataByGroup[groupIndex].push({
				coord: new Point(0, 0),
				width: 0,
				height: 0,
				values: {
					x: x[i],
					y: y[i]
				},
				allowed: false
			});
		}

		// var x = newData.values.get("x");
		// var y = newData.values.get("y");
		// var groupsArr = newData.values.get("groups");
		// for (i in 0...x.length) {
		// 	var group = groupsArr[i];
		// 	var point = new Data2D(x[i], y[i], style.groups.get(group));
		// 	colors.push(style.colorPalette[style.groups.get(group)]);
		// 	data.push(point);
		// }
		// groupNum = 0;
		// for (key in style.groups.keys()) {
		// 	groupNum++;
		// }
		// sortData(style);
	};

	var isXCategoric:Bool = false;
	var valueGroups:Array<Dynamic>;
	var xValues:Array<Dynamic>;
	var yValues:Array<Dynamic>;
	var groupNum:Int;

	function sortData(style:TrailStyle) {
		xValues = data.map(x -> {
			var val:Data2D = x;
			return val.xValue;
		});
		yValues = data.map(x -> {
			var val:Data2D = x;
			return val.yValue;
		});

		if (Std.isOfType(xValues[0], Float)) {
			var a = xValues.copy();
			a.sort(Reflect.compare);
			minX = a[0];
			maxX = a[a.length - 1];
		} else {
			isXCategoric = true;
			valueGroups = xValues.unique();
		}
		if (Std.isOfType(yValues[0], Float)) {
			var a = yValues.copy();
			a.sort(Reflect.compare);
			minY = a[0];
			maxY = a[a.length - 1];
		} else {
			valueGroups = yValues.unique();
		}
		if (style.positionOption == PositionOption.stacked) {
			if (isXCategoric) {
				for (v in valueGroups) {
					var indexes = xValues.position(v);
					var sum = 0;
					for (i in indexes) {
						var val = yValues[i];
						sum += val;
					}
					maxY = Math.max(maxY, sum);
				}
			} else {
				for (v in valueGroups) {
					var indexes = yValues.position(v);
					var sum = 0;
					for (i in indexes) {
						var val = xValues[i];
						sum += val;
					}
					maxX = Math.max(maxX, sum);
				}
			}
		}
	}

	function setAxisDist(min, max, info:AxisInfo) {
		var ratio = 1.0;
		if (Std.isOfType(info.tickInfo, NumericTickInfo)) {
			var tickInfo:NumericTickInfo = cast(info.tickInfo, NumericTickInfo);
			ratio = 1 - tickInfo.negNum / (tickInfo.tickNum - 1);
		}
		return ChartTools.calcAxisDists(min, max, ratio);
	}

	public function positionData(style:TrailStyle):Void {
		// if (axes.length < 2) {
		// 	throw new Exception("Too few axes for drawing data.");
		// }
		// if (axes[0].tickInfo == null || axes[1].tickInfo == null) {
		// 	throw new Exception("Two tickinfos are needed for positioning the data correctly!");
		// }
		var axis = axes;
		var xDist = setAxisDist(axes.ticksPerInfo[0][0].left, axes.ticksPerInfo[0][axes.ticksPerInfo[0].length - 1].left, axes.axesInfo[0]);
		var yDist = setAxisDist(axes.ticksPerInfo[1][axes.ticksPerInfo[1].length - 1].top, axes.ticksPerInfo[1][0].top, axes.axesInfo[1]);
		var yZeroPos = axes.zeroPoint.x;
		var xZeroPos = axes.zeroPoint.y;

		var spacePerXTick = (axis.axesInfo[0].length / (axis.ticksPerInfo[0].length - 1)) * 2 / 3;
		var spacePerYTick = (axis.axesInfo[1].length / (axis.ticksPerInfo[1].length - 1)) * 2 / 3;
		var spacePerGroupX = spacePerXTick / dataByGroup.length;
		var spacePerGroupY = spacePerYTick / dataByGroup.length;
		var prevGroup:Array<BarDataRec> = [];
		for (i => group in dataByGroup) {
			if (i > 0) {
				prevGroup = dataByGroup[i - 1];
			}
			for (dataRec in group) {
				if (dataRec.values.x is String) {
					var tick = axis.ticksPerInfo[0].filter(x -> {
						return x.text == dataRec.values.x;
					})[0];
					var y:Float = dataRec.values.y;
					var min:Float = 0;
					var max:Float = 0;
					var minIndex:Int = 0;
					var maxIndex:Int = 0;
					if (y > 0) {
						min = 0;
						minIndex = axis.axesInfo[1].tickInfo.zeroIndex;
						max = Std.parseFloat(axis.ticksPerInfo[1][axis.ticksPerInfo[1].length - 1].text);
						maxIndex = axis.ticksPerInfo[1].length - 1;
					} else {
						max = 0;
						maxIndex = axis.axesInfo[1].tickInfo.zeroIndex;
						min = Std.parseFloat(axis.ticksPerInfo[1][0].text);
						minIndex = 0;
					}
					var tickTop = axis.ticksPerInfo[1][maxIndex].top;
					var tickBottom = axis.ticksPerInfo[1][minIndex].top;
					var yCoord = tickBottom - (tickBottom - tickTop) * (y - min) / (max - min);
					var xCoord = tick.left - (spacePerXTick / 2);
					dataRec.width = spacePerXTick;
					dataRec.height = y > 0 ? tickBottom - yCoord : yCoord - tickTop;
					switch (style.positionOption) {
						case PositionOption.stacked:
							var prevDataRec = prevGroup.filter(d -> {
								d.values.x == dataRec.values.x;
							})[0];
							yCoord = prevDataRec.coord.y - yCoord;
						case PositionOption.layered:
							dataRec.width = spacePerGroupX;
							var prevDataRec = prevGroup.filter(d -> {
								d.values.x == dataRec.values.x;
							})[0];
						// xCoord =
						case null:
						case _:
					}
					dataRec.coord = new Point(xCoord, yCoord);
				} else {
					var tick = axis.ticksPerInfo[1].filter(x -> {
						return x.text == dataRec.values.y;
					})[0];
					var x:Float = dataRec.values.x;
					var min:Float = 0;
					var max:Float = 0;
					var minIndex:Int = 0;
					var maxIndex:Int = 0;
					if (x > 0) {
						min = 0;
						minIndex = axis.axesInfo[0].tickInfo.zeroIndex;
						max = Std.parseFloat(axis.ticksPerInfo[0][axis.ticksPerInfo[0].length - 1].text);
						maxIndex = axis.ticksPerInfo[0].length - 1;
					} else {
						max = 0;
						maxIndex = axis.axesInfo[0].tickInfo.zeroIndex;
						min = Std.parseFloat(axis.ticksPerInfo[0][0].text);
						minIndex = 0;
					}
					var tickLeft = axis.ticksPerInfo[0][minIndex].left;
					var tickRight = axis.ticksPerInfo[0][maxIndex].left;
					var xCoord = (tickRight - tickLeft) * (x - min) / (max - min) + tickLeft;
					var yCoord = tick.top - (spacePerYTick / 2);
					dataRec.width = tickRight - tickLeft;
					dataRec.height = spacePerYTick;
					switch (style.positionOption) {
						case PositionOption.stacked:
							var prevDataRec = prevGroup.filter(d -> {
								d.values.y == dataRec.values.y;
							})[0];
							xCoord = prevDataRec.coord.x + xCoord;
						case PositionOption.layered:
						case null:
						case _:
					}
					dataRec.coord = new Point(xCoord, yCoord);
				}
			}
		}

		// for (valueGroup in valueGroups) {
		// 	var indexes = [];
		// 	var previousValue:Float = 0;
		// 	if (isXCategoric) {
		// 		indexes = xValues.position(valueGroup);
		// 		previousValue = yZeroPos;
		// 	} else {
		// 		indexes = yValues.position(valueGroup);
		// 		previousValue = xZeroPos;
		// 	}

		// 	for (i in indexes) {
		// 		var dataPoint:Data2D = data[i];
		// 		// if (isXCategoric) {
		// 		// 	var top = calcCoordinate();
		// 		// 	var bottom = calcCoordinate();
		// 		// }
		// 		// var x = calcCoordinate(dataPoint.xValue, dataPoint.group, axes.ticksPerInfo[0], xZeroPos, xDist, style, previousValue, false);
		// 		// var y = calcCoordinate(dataPoint.yValue, dataPoint.group, axes.ticksPerInfo[1], yZeroPos, yDist, style, previousValue, true);
		// 		dataCanvas.componentGraphics.fillStyle(colors[i], 1);
		// 		// if (x == null || y == null) {
		// 		// 	continue;
		// 		// }
		// 		// if (isXCategoric) {
		// 		// 	previousValue = y[0];
		// 		// } else {
		// 		// 	previousValue = x[0] + x[1];
		// 		// }

		// 		dataCanvas.componentGraphics.rectangle(x[0], y[0], x[1], y[1]);
		// 	}
		// }
		for (i => group in dataByGroup) {
			for (dataRec in group) {
				dataCanvas.componentGraphics.fillStyle(0x000000, 1);
				dataCanvas.componentGraphics.rectangle(dataRec.coord.x, dataRec.coord.y, dataRec.width, dataRec.height);
			}
		}
		var canvasComponent = parent.findComponent(id);
		if (canvasComponent == null) {
			parent.addComponent(dataCanvas);
		} else {
			parent.removeComponent(canvasComponent);
			parent.addComponent(dataCanvas);
		}
	};

	function calcCoordinate(value:Dynamic, group:Int, ticks:Array<Ticks>, zeroPos:Float, dist:AxisDist, style:TrailStyle, previousPosition:Float, isY:Bool) {
		if (value is String) {
			var ticksFiltered = ticks.filter(x -> {
				return x.text == value;
			});
			if (ticksFiltered == null || ticksFiltered.length == 0) {
				return null;
			}
			var spacePerTick = (dist.pos_dist / (ticks.length - 1)) * 2 / 3;
			if (style.positionOption == PositionOption.stacked) {
				var pos = (isY ? ticksFiltered[0].top : ticksFiltered[0].left) - (spacePerTick / 2);
				return [pos, spacePerTick];
			}
			var spacePerGroup = spacePerTick / groupNum;

			var overlapEffect = 2.0; // This means basically no effect, everything smaller will make the bars overlap
			if (style.positionOption == PositionOption.layered) {
				overlapEffect = 1.3;
			}

			var groupOffset = groupNum - group * overlapEffect;
			var posOffset = (isY ? ticksFiltered[0].top : ticksFiltered[0].left) - (spacePerGroup / 2) * groupOffset;
			return [posOffset, spacePerGroup];
		}

		var max = Std.parseFloat(ticks[ticks.length - 1].text);
		var min = Std.parseFloat(ticks[0].text);

		// var tickLeft = ticks[0].left;
		// var tickRight = largerTicks[0].left;
		// var x = (tickRight - tickLeft) * (xValue - xMin) / (xMax - xMin) + tickLeft;

		var ratio = value < 0 ? value / min : value / max;
		var pos = zeroPos + (isY ? -1 : 1) * (value < 0 ? -1 * dist.neg_dist : dist.pos_dist) * ratio;
		var finalPos = pos;
		if (style.positionOption == PositionOption.stacked) {
			if (isY) {
				finalPos = previousPosition - dist.pos_dist * ratio;
			} else {
				finalPos = previousPosition;
			}
		}
		return [finalPos, isY ? zeroPos - pos : pos - zeroPos];
	}

	public function positionAxes(axisInfo:Array<AxisInfo>, data:Array<Any>, style:TrailStyle):Void {
		if (axes != null) {
			positionData(style);
			return;
		}
		axes = new Axis(axisID, axisInfo);
		axes.width = parent.width;
		axes.height = parent.height;
		axes.positionStartPoint();
		axes.setTicks(false);
		positionData(style);
		AxisTools.replaceAxisInParent(axes, parent);
	};
}
