package hxchart.core.trails;

import hxchart.core.axis.AxisInfo;
import hxchart.core.styling.PositionOptions.PositionOption;
import hxchart.core.styling.TrailStyle;
import hxchart.core.axis.Axis;
import haxe.Exception;
import hxchart.core.utils.Point;
import hxchart.core.coordinates.CoordinateSystem;
import hxchart.core.data.DataLayer;
import hxchart.core.axis.AxisLayer;
import hxchart.core.coordinates.TrailCalcs;

using hxchart.core.utils.ArrayTools;
using Lambda;

typedef BarDataRec = {
	coord:Point,
	width:Float,
	height:Float,
	values:{
		x:Any, y:Any, ?acc:Float
	},
	borderAlpha:Float,
	borderColor:Int,
	borderWidth:Float,
	color:Int,
	alpha:Float,
	allowed:Bool
}

class Bar implements AxisLayer implements DataLayer {
	public var coordSystem:CoordinateSystem;

	public var data:Array<Any>;
	public var colors:Array<Int>;
	public var axes:Axis;

	public var trailInfo:TrailInfo;

	public var dataByGroup:Array<Array<BarDataRec>> = [];

	public function new(trailInfo:TrailInfo, axes:Axis, coordSystem:CoordinateSystem) {
		if (trailInfo.axisInfo[0].type == linear && trailInfo.axisInfo[1].type == linear) {
			throw new Exception("It is not possible to use two 'linear' axes for a bar-chart. Please change one of them to 'categorical'.");
		}
		if (trailInfo.axisInfo[0].type == categorical && trailInfo.axisInfo[1].type == categorical) {
			throw new Exception("It is not possible to use two 'categorical' axes for a bar-chart. Please change one of them to 'linear'.");
		}

		this.coordSystem = coordSystem;

		if (axes != null) {
			this.axes = axes;
		}
		this.trailInfo = trailInfo;
	}

	public function validateChart() {
		setData(trailInfo.data, trailInfo.style);
		positionAxes(trailInfo.axisInfo, trailInfo.style);
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

		for (i in 0...x.length) {
			var group = groupsArr[i];
			var groupIndex = style.groups.get(group);
			if (Std.isOfType(x[i], Float)) {
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
					y: y[i],
					acc: Std.isOfType(x[i], String) ? y[i] : x[i]
				},
				alpha: 1,
				borderAlpha: 1,
				borderColor: 0x000000,
				borderWidth: 1,
				color: style.colorPalette[groupIndex],
				allowed: true
			});
		}

		if (Std.isOfType(style.alpha, Float) || Std.isOfType(style.alpha, Int)) {
			var alpha = cast(style.alpha, Float);
			for (group in dataByGroup) {
				for (dataRec in group) {
					dataRec.alpha = alpha;
				}
			}
		} else if (Std.isOfType(style.alpha, Array)) {
			var alpha:Array<Float> = style.alpha;
			if (alpha.length == x.length) {
				var i = 0;
				for (group in dataByGroup) {
					for (dataRec in group) {
						dataRec.alpha = alpha[i];
						i++;
					}
				}
			} else if (alpha.length == uniqueGroupsNum) {
				for (i in 0...uniqueGroupsNum) {
					var groupAlpha = alpha[i];
					for (dataRec in dataByGroup[i]) {
						dataRec.alpha = groupAlpha;
					}
				}
			}
		}

		if (style.borderStyle != null) {
			if (style.borderStyle.color != null) {
				if (Std.isOfType(style.borderStyle.color, Int)) {
					var color = cast(style.borderStyle.color, Int);
					for (group in dataByGroup) {
						for (dataRec in group) {
							dataRec.borderColor = color;
						}
					}
				} else if (Std.isOfType(style.borderStyle.color, Array)) {
					var color:Array<Int> = style.borderStyle.color;
					if (color.length == x.length) {
						var i = 0;
						for (group in dataByGroup) {
							for (dataRec in group) {
								dataRec.borderColor = color[i];
								i++;
							}
						}
					} else if (color.length == uniqueGroupsNum) {
						for (i in 0...uniqueGroupsNum) {
							var groupColor = color[i];
							for (dataRec in dataByGroup[i]) {
								dataRec.borderColor = groupColor;
							}
						}
					}
				}
			}

			if (Std.isOfType(style.borderStyle.alpha, Float) || Std.isOfType(style.borderStyle.alpha, Int)) {
				var alpha = cast(style.borderStyle.alpha, Float);
				for (group in dataByGroup) {
					for (dataRec in group) {
						dataRec.borderAlpha = alpha;
					}
				}
			} else if (Std.isOfType(style.borderStyle.alpha, Array)) {
				var alpha:Array<Float> = style.borderStyle.alpha;
				if (alpha.length == x.length) {
					var i = 0;
					for (group in dataByGroup) {
						for (dataRec in group) {
							dataRec.borderAlpha = alpha[i];
							i++;
						}
					}
				} else if (alpha.length == uniqueGroupsNum) {
					for (i in 0...uniqueGroupsNum) {
						var groupAlpha = alpha[i];
						for (dataRec in dataByGroup[i]) {
							dataRec.borderAlpha = groupAlpha;
						}
					}
				}
			}

			if (Std.isOfType(style.borderStyle.thickness, Float) || Std.isOfType(style.borderStyle.thickness, Int)) {
				var thickness = cast(style.borderStyle.thickness, Float);
				for (group in dataByGroup) {
					for (dataRec in group) {
						dataRec.borderWidth = thickness;
					}
				}
			} else if (Std.isOfType(style.borderStyle.thickness, Array)) {
				var thickness:Array<Float> = style.borderStyle.thickness;
				if (thickness.length == x.length) {
					var i = 0;
					for (group in dataByGroup) {
						for (dataRec in group) {
							dataRec.borderWidth = thickness[i];
							i++;
						}
					}
				} else if (thickness.length == uniqueGroupsNum) {
					for (i in 0...uniqueGroupsNum) {
						var groupThickness = thickness[i];
						for (dataRec in dataByGroup[i]) {
							dataRec.borderWidth = groupThickness;
						}
					}
				}
			}
		}
	};

	public function positionData(style:TrailStyle):Void {
		var useableWidth = axes.ticksPerInfo[0][axes.ticksPerInfo[0].length - 1].middlePos.x - axes.ticksPerInfo[0][0].middlePos.x;
		var useableHeight = axes.ticksPerInfo[1][axes.ticksPerInfo[1].length - 1].middlePos.y - axes.ticksPerInfo[1][0].middlePos.y;
		var spacePerXTick = (useableWidth / (axes.ticksPerInfo[0].length - 1)) * 2 / 3;
		var spacePerYTick = (useableHeight / (axes.ticksPerInfo[1].length - 1)) * 2 / 3;
		var spacePerGroupX = spacePerXTick / dataByGroup.length;
		var spacePerGroupY = spacePerYTick / dataByGroup.length;

		var maxGroupValues = dataByGroup.map(g -> g.length).fold((item, result) -> Math.max(item, result), 0);
		var maxGroup = dataByGroup.filter(g -> g.length == maxGroupValues)[0];
		for (group in dataByGroup) {
			if (group.length == maxGroupValues) {
				continue;
			}
			if (Std.isOfType(maxGroup[0].values.x, String)) {
				for (dataRec in maxGroup) {
					var dataRecInGroup = group.filter(d -> {
						return d.values.x == dataRec.values.x;
					});
					if (dataRecInGroup.length > 0) {
						continue;
					}
					group.push({
						coord: new Point(0, 0),
						width: 0,
						height: 0,
						values: {
							x: dataRec.values.x,
							y: 0,
							acc: 0
						},
						alpha: 1,
						borderAlpha: 1,
						borderColor: 0x000000,
						borderWidth: 1,
						color: 0x000000,
						allowed: false
					});
				}
			} else {
				for (dataRec in maxGroup) {
					var dataRecInGroup = group.filter(d -> {
						return d.values.y == dataRec.values.y;
					});
					if (dataRecInGroup.length > 0) {
						continue;
					}
					group.push({
						coord: new Point(0, 0),
						width: 0,
						height: 0,
						values: {
							y: dataRec.values.y,
							x: 0,
							acc: 0
						},
						alpha: 1,
						borderAlpha: 1,
						borderColor: 0x000000,
						borderWidth: 1,
						color: 0x000000,
						allowed: false
					});
				}
			}
		}
		var prevGroup:Array<BarDataRec> = [];
		for (i => group in dataByGroup) {
			if (i > 0) {
				prevGroup = dataByGroup[i - 1];
			}
			for (dataRec in group) {
				if (Std.isOfType(dataRec.values.x, String)) {
					var tick = axes.ticksPerInfo[0].filter(x -> {
						return x.text == dataRec.values.x;
					})[0];
					var xCoord = tick.middlePos.x - (spacePerXTick / 2);
					var yCoord = tick.middlePos.y;
					dataRec.width = spacePerXTick;
					switch ([style.positionOption, dataByGroup.length > 1, prevGroup.length > 0]) {
						case [PositionOption.stacked, true, true]:
							yCoord = calcStackedBarY(dataRec, prevGroup);
						case [PositionOption.layered(v), true, false]: // positioning for 1st layered bar
							dataRec.width = spacePerGroupX;
							yCoord = calcLayeredBarY(dataRec);
						case [PositionOption.layered(v), true, true]: // positioning for other layered bars
							yCoord = calcLayeredBarY(dataRec);
							dataRec.width = spacePerGroupX;
							var prevDataRec = prevGroup.filter(d -> {
								d.values.x == dataRec.values.x;
							})[0];
							if (v >= 1) {
								v = 1;
							} else if (v <= 0) {
								v = 0;
							}
							xCoord = prevDataRec.coord.x + spacePerGroupX * v;
						case [null, true, true]: // default to stacked for multiple groups
							yCoord = calcStackedBarY(dataRec, prevGroup);
						case [_, true, true]: // default to stacked for multiple groups
							yCoord = calcStackedBarY(dataRec, prevGroup);
						case _:
							yCoord = calcStackedBarY(dataRec, prevGroup);
					}
					dataRec.coord = new Point(xCoord, yCoord);
				} else {
					var tick = axes.ticksPerInfo[1].filter(x -> {
						return x.text == dataRec.values.y;
					})[0];
					var xCoord = tick.middlePos.x;
					var yCoord = tick.middlePos.y - (spacePerYTick / 2);
					dataRec.height = spacePerYTick;
					switch ([style.positionOption, dataByGroup.length > 1, prevGroup.length > 0]) {
						case [PositionOption.stacked, true, true]:
							xCoord = calcStackedBarX(dataRec, prevGroup);
						case [PositionOption.layered(v), true, false]: // positioning for 1st layered bar
							dataRec.height = spacePerGroupY;
							xCoord = calcLayeredBarX(dataRec);
						case [PositionOption.layered(v), true, true]: // positioning for other layered bars
							xCoord = calcLayeredBarX(dataRec);
							dataRec.height = spacePerGroupY;
							var prevDataRec = prevGroup.filter(d -> {
								d.values.y == dataRec.values.y;
							})[0];
							if (v >= 1) {
								v = 1;
							} else if (v <= 0) {
								v = 0;
							}
							yCoord = prevDataRec.coord.y + spacePerGroupY * v;
						case [null, true, true]: // default to stacked for multiple groups
							xCoord = calcStackedBarX(dataRec, prevGroup);
						case [_, true, true]: // default to stacked for multiple groups
							xCoord = calcStackedBarX(dataRec, prevGroup);
						case _:
							xCoord = calcStackedBarX(dataRec, prevGroup);
					}
					dataRec.coord = new Point(xCoord, yCoord);
				}
			}
		}
	};

	function calcStackedBarY(dataRec:BarDataRec, prevGroup:Array<BarDataRec>) {
		var prevDataRec = prevGroup.filter(d -> {
			d.values.x == dataRec.values.x;
		});
		var y = cast(dataRec.values.y, Float);
		dataRec.values.acc = y;
		var yCoord = TrailCalcs.calcBarCoordinates(axes.ticksPerInfo[1], y, axes.axesInfo[1].tickInfo.zeroIndex, true);
		var tickBottom = axes.ticksPerInfo[1][axes.axesInfo[1].tickInfo.zeroIndex].middlePos.y;
		if (Math.isNaN(yCoord)) {
			yCoord = tickBottom;
		}
		dataRec.height = yCoord - tickBottom;
		if (prevDataRec.length > 0) {
			var yOld = prevDataRec[0].values.acc;
			dataRec.values.acc = y + yOld;
			var yCoordOld = TrailCalcs.calcBarCoordinates(axes.ticksPerInfo[1], yOld, axes.axesInfo[1].tickInfo.zeroIndex, true);
			if (Math.isNaN(yCoordOld)) {
				yCoordOld = tickBottom;
			}
			yCoord = yCoordOld + dataRec.height;
		}

		return yCoord;
	}

	function calcStackedBarX(dataRec:BarDataRec, prevGroup:Array<BarDataRec>) {
		var prevDataRec = prevGroup.filter(d -> {
			d.values.y == dataRec.values.y;
		});
		var x = cast(dataRec.values.x, Float);
		dataRec.values.acc = x;
		var xCoord = TrailCalcs.calcBarCoordinates(axes.ticksPerInfo[0], x, axes.axesInfo[0].tickInfo.zeroIndex, false);
		var tickLeft = axes.ticksPerInfo[0][axes.axesInfo[0].tickInfo.zeroIndex].middlePos.x;
		if (Math.isNaN(xCoord)) {
			xCoord = tickLeft;
		}
		dataRec.width = xCoord - tickLeft;
		if (prevDataRec.length > 0) {
			var xOld = prevDataRec[0].values.acc;
			dataRec.values.acc = x + xOld;
			var xCoordOld = TrailCalcs.calcBarCoordinates(axes.ticksPerInfo[0], xOld, axes.axesInfo[0].tickInfo.zeroIndex, false);
			if (Math.isNaN(xCoordOld)) {
				xCoordOld = tickLeft;
			}
			xCoord = xCoordOld + dataRec.width;
		}
		return xCoord;
	}

	function calcLayeredBarX(dataRec:BarDataRec) {
		var xCoord = TrailCalcs.calcBarCoordinates(axes.ticksPerInfo[0], dataRec.values.x, axes.axesInfo[0].tickInfo.zeroIndex, false);
		var tickLeft = axes.ticksPerInfo[0][axes.axesInfo[0].tickInfo.zeroIndex].middlePos.x;
		if (Math.isNaN(xCoord)) {
			xCoord = tickLeft;
		}
		dataRec.width = xCoord - tickLeft;
		return xCoord;
	}

	function calcLayeredBarY(dataRec:BarDataRec) {
		var yCoord = TrailCalcs.calcBarCoordinates(axes.ticksPerInfo[1], dataRec.values.y, axes.axesInfo[1].tickInfo.zeroIndex, true);
		var tickBottom = axes.ticksPerInfo[0][axes.axesInfo[1].tickInfo.zeroIndex].middlePos.y;
		if (Math.isNaN(yCoord)) {
			yCoord = tickBottom;
		}
		dataRec.height = yCoord - tickBottom;
		return yCoord;
	}

	public function positionAxes(axisInfo:Array<AxisInfo>, style:TrailStyle):Void {
		if (axes != null) {
			axes.positionStartPoint();
			axes.setTicks(true);
			positionData(style);
			return;
		}
		axes = new Axis(axisInfo, coordSystem);
		axes.positionStartPoint();
		axes.setTicks(false);
		positionData(style);
	};
}
