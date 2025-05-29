package hxchart.core.trails;

import hxchart.core.axis.AxisInfo;
import hxchart.core.tickinfo.NumericTickInfo;
import hxchart.core.styling.PositionOptions.PositionOption;
import hxchart.core.data.Data2D;
import hxchart.core.styling.TrailStyle;
import hxchart.core.chart.ChartStatus;
import hxchart.core.axis.Axis;
import haxe.Exception;
import hxchart.core.utils.Point;
import hxchart.core.utils.CoordinateSystem;
import hxchart.core.data.DataLayer;
import hxchart.core.axis.AxisLayer;

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
	public var axisID:String;

	public var dataByGroup:Array<Array<BarDataRec>> = [];

	public function new(trailInfo:TrailInfo, axes:Axis, id:String, axisID:String) {
		if (trailInfo.axisInfo[0].type == linear && trailInfo.axisInfo[1].type == linear) {
			throw new Exception("It is not possible to use two 'linear' axes for a bar-chart. Please change one of them to 'categorical'.");
		}
		if (trailInfo.axisInfo[0].type == categorical && trailInfo.axisInfo[1].type == categorical) {
			throw new Exception("It is not possible to use two 'categorical' axes for a bar-chart. Please change one of them to 'linear'.");
		}

		valueGroups = [];
		xValues = [];
		yValues = [];

		if (axes != null) {
			this.axes = axes;
		}
		this.axisID = axisID;
		this.trailInfo = trailInfo;
	}

	public function validateChart(status:ChartStatus) {
		switch status {
			case start:
				setData(trailInfo.data, trailInfo.style);
			case redraw:
		}
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
					y: y[i],
					acc: x[i] is String ? y[i] : x[i]
				},
				alpha: 1,
				borderAlpha: 1,
				borderColor: 0x000000,
				borderWidth: 1,
				color: style.colorPalette[groupIndex],
				allowed: true
			});
		}

		if (style.alpha is Float || style.alpha is Int) {
			var alpha = cast(style.alpha, Float);
			for (group in dataByGroup) {
				for (dataRec in group) {
					dataRec.alpha = alpha;
				}
			}
		} else if (style.alpha is Array) {
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
				if (style.borderStyle.color is Int) {
					var color = cast(style.borderStyle.color, Int);
					for (group in dataByGroup) {
						for (dataRec in group) {
							dataRec.borderColor = color;
						}
					}
				} else if (style.borderStyle.color is Array) {
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

			if (style.borderStyle.alpha is Float || style.borderStyle.alpha is Int) {
				var alpha = cast(style.borderStyle.alpha, Float);
				for (group in dataByGroup) {
					for (dataRec in group) {
						dataRec.borderAlpha = alpha;
					}
				}
			} else if (style.borderStyle.alpha is Array) {
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

			if (style.borderStyle.thickness is Float || style.borderStyle.thickness is Int) {
				var thickness = cast(style.borderStyle.thickness, Float);
				for (group in dataByGroup) {
					for (dataRec in group) {
						dataRec.borderWidth = thickness;
					}
				}
			} else if (style.borderStyle.thickness is Array) {
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

	public function positionData(style:TrailStyle):Void {
		var spacePerXTick = (axes.axesInfo[0].length / (axes.ticksPerInfo[0].length - 1)) * 2 / 3;
		var spacePerYTick = (axes.axesInfo[1].length / (axes.ticksPerInfo[1].length - 1)) * 2 / 3;
		var spacePerGroupX = spacePerXTick / dataByGroup.length;
		var spacePerGroupY = spacePerYTick / dataByGroup.length;

		var maxGroupValues = dataByGroup.map(g -> g.length).fold((item, result) -> Math.max(item, result), 0);
		var maxGroup = dataByGroup.filter(g -> g.length == maxGroupValues)[0];
		for (group in dataByGroup) {
			if (group.length == maxGroupValues) {
				continue;
			}
			if (maxGroup[0].values.x is String) {
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
				if (dataRec.values.x is String) {
					var tick = axes.ticksPerInfo[0].filter(x -> {
						return x.text == dataRec.values.x;
					})[0];
					var y:Float = dataRec.values.y;
					var min:Float = 0;
					var max:Float = 0;
					var minIndex:Int = 0;
					var maxIndex:Int = 0;
					if (y >= 0) {
						min = 0;
						minIndex = axes.axesInfo[1].tickInfo.zeroIndex;
						max = Std.parseFloat(axes.ticksPerInfo[1][axes.ticksPerInfo[1].length - 1].text);
						maxIndex = axes.ticksPerInfo[1].length - 1;
					} else {
						max = 0;
						maxIndex = axes.axesInfo[1].tickInfo.zeroIndex;
						min = Std.parseFloat(axes.ticksPerInfo[1][0].text);
						minIndex = 0;
					}
					var tickTop = axes.ticksPerInfo[1][maxIndex].top;
					var tickBottom = axes.ticksPerInfo[1][minIndex].top;
					var xCoord = tick.left - (spacePerXTick / 2);
					var yCoord = tickBottom - (tickBottom - tickTop) * (y - min) / (max - min);
					dataRec.width = spacePerXTick;
					dataRec.height = y > 0 ? tickBottom - yCoord : yCoord - tickTop;
					switch ([style.positionOption, dataByGroup.length > 1, prevGroup.length > 0]) {
						case [PositionOption.stacked, true, true]:
							yCoord = calcStackedBarY(dataRec, prevGroup, y, tickBottom, tickTop, min, max);
						case [PositionOption.layered(v), true, false]:
							dataRec.width = spacePerGroupX;
						case [PositionOption.layered(v), true, true]:
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
							yCoord = calcStackedBarY(dataRec, prevGroup, y, tickBottom, tickTop, min, max);
						case [_, true, true]: // default to stacked for multiple groups
							yCoord = calcStackedBarY(dataRec, prevGroup, y, tickBottom, tickTop, min, max);
						case _:
					}
					dataRec.coord = new Point(xCoord, yCoord);
				} else {
					var tick = axes.ticksPerInfo[1].filter(x -> {
						return x.text == dataRec.values.y;
					})[0];
					var x:Float = dataRec.values.x;
					var min:Float = 0;
					var max:Float = 0;
					var minIndex:Int = 0;
					var maxIndex:Int = 0;
					if (x >= 0) {
						min = 0;
						minIndex = axes.axesInfo[0].tickInfo.zeroIndex;
						max = Std.parseFloat(axes.ticksPerInfo[0][axes.ticksPerInfo[0].length - 1].text);
						maxIndex = axes.ticksPerInfo[0].length - 1;
					} else {
						max = 0;
						maxIndex = axes.axesInfo[0].tickInfo.zeroIndex;
						min = Std.parseFloat(axes.ticksPerInfo[0][0].text);
						minIndex = 0;
					}
					var tickLeft = axes.ticksPerInfo[0][minIndex].left;
					var tickRight = axes.ticksPerInfo[0][maxIndex].left;
					var xCoord = tickLeft;
					var widthCoord = (tickRight - tickLeft) * (x - min) / (max - min) + tickLeft;
					dataRec.width = widthCoord - xCoord;
					var yCoord = tick.top - (spacePerYTick / 2);
					dataRec.height = spacePerYTick;
					switch ([style.positionOption, dataByGroup.length > 1, prevGroup.length > 0]) {
						case [PositionOption.stacked, true, true]:
							xCoord = calcStackedBarX(dataRec, prevGroup, x, tickLeft, tickRight, min, max);
						case [PositionOption.layered(v), true, false]:
							dataRec.height = spacePerGroupY;
						case [PositionOption.layered(v), true, true]:
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
							xCoord = calcStackedBarX(dataRec, prevGroup, x, tickLeft, tickRight, min, max);
						case [_, true, true]: // default to stacked for multiple groups
							xCoord = calcStackedBarX(dataRec, prevGroup, x, tickLeft, tickRight, min, max);
						case _:
					}
					dataRec.coord = new Point(xCoord, yCoord);
				}
			}
		}
	};

	function calcStackedBarY(dataRec:BarDataRec, prevGroup:Array<BarDataRec>, y:Float, tickBottom:Float, tickTop:Float, min:Float, max:Float) {
		var prevDataRec = prevGroup.filter(d -> {
			d.values.x == dataRec.values.x;
		});
		y = cast(dataRec.values.y, Float) + prevDataRec[0].values.acc;
		dataRec.values.acc = y;
		var yCoord = tickBottom - (tickBottom - tickTop) * (y - min) / (max - min);
		var bottom = prevDataRec[0].coord.y;
		dataRec.height = y >= 0 ? bottom - yCoord : yCoord - bottom;
		return yCoord;
	}

	function calcStackedBarX(dataRec:BarDataRec, prevGroup:Array<BarDataRec>, x:Float, tickLeft:Float, tickRight:Float, min:Float, max:Float) {
		var prevDataRec = prevGroup.filter(d -> {
			d.values.y == dataRec.values.y;
		});
		x = cast(dataRec.values.x, Float) + prevDataRec[0].values.acc;
		dataRec.values.acc = x;
		var xCoord = prevDataRec[0].coord.x + prevDataRec[0].width;
		var widthCoord = (tickRight - tickLeft) * (x - min) / (max - min) + tickLeft;
		dataRec.width = widthCoord - xCoord;
		return xCoord;
	}

	public function positionAxes(axisInfo:Array<AxisInfo>, data:Array<Any>, style:TrailStyle):Void {
		if (axes != null) {
			axes.positionStartPoint();
			axes.setTicks(true);
			positionData(style);
			return;
		}
		axes = new Axis(axisID, axisInfo);
		axes.positionStartPoint();
		axes.setTicks(false);
		positionData(style);
	};
}
