package hxchart.basics.trails;

import hxchart.basics.ticks.Ticks;
import hxchart.basics.utils.ChartTools;
import hxchart.basics.ticks.Ticks.CompassOrientation;
import haxe.ui.geom.Point;
import hxchart.basics.axis.AxisTools;
import hxchart.basics.axis.StringTickInfo;
import hxchart.basics.axis.NumericTickInfo;
import hxchart.basics.axis.TickInfo;
import haxe.Exception;
import hxchart.basics.plot.Plot.AxisInfo;
import hxchart.basics.plot.Plot.TrailStyle;
import hxchart.basics.axis.Axis;
import haxe.ui.util.Color;
import haxe.ui.components.Canvas;
import hxchart.basics.data.Data2D;
import haxe.ui.containers.Absolute;
import hxchart.basics.plot.Plot.TrailInfo;
import hxchart.basics.data.DataLayer;
import hxchart.basics.axis.AxisLayer;

using hxchart.basics.utils.Statistics;

class Bar implements AxisLayer implements DataLayer {
	public var id:String;
	public var data:Array<Data2D>;
	public var parent:Absolute;
	public var dataCanvas:Canvas;
	public var colors:Array<Color>;
	public var axes:Array<Axis>;

	public var trailInfo:TrailInfo;
	public var axisID:String;

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
		positionData(trailInfo.style);
	}

	public function setData(newData:TrailData, style:TrailStyle) {
		data = [];
		colors = [];
		var groupsArr = newData.groups;
		for (i in 0...newData.xValues.length) {
			var group = groupsArr[i];
			var point = new Data2D(newData.xValues[i], newData.yValues[i], style.groups.get(group));
			colors.push(style.colorPalette[style.groups.get(group)]);
			data.push(point);
		}
		groupNum = 0;
		for (key in style.groups.keys()) {
			groupNum++;
		}
		sortData(style);
	};

	var minX:Float;
	var minY:Float;
	var maxX:Float;
	var maxY:Float;
	var isXCategoric:Bool = false;
	var valueGroups:Array<Dynamic>;
	var xValues:Array<Dynamic>;
	var yValues:Array<Dynamic>;
	var groupNum:Int;

	function sortData(style:TrailStyle) {
		xValues = data.map(x -> {
			return x.xValue;
		});
		yValues = data.map(x -> {
			return x.yValue;
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
		if (style.stacked) {
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

	function setAxisDist(min, max, axis) {
		var ratio = 1.0;
		if (Std.isOfType(axis.tickInfo, NumericTickInfo)) {
			var tickInfo:NumericTickInfo = cast(axis.tickInfo, NumericTickInfo);
			ratio = 1 - tickInfo.negNum / (tickInfo.tickNum - 1);
		}
		return ChartTools.calcAxisDists(min, max, ratio);
	}

	public function positionData(style:TrailStyle):Void {
		if (axes.length < 2) {
			throw new Exception("Too few axes for drawing data.");
		}
		if (axes[0].tickInfo == null || axes[1].tickInfo == null) {
			throw new Exception("Two tickinfos are needed for positioning the data correctly!");
		}

		var xDist = setAxisDist(axes[0].ticks[0].left, axes[0].ticks[axes[0].ticks.length - 1].left, axes[0]);
		var yDist = setAxisDist(axes[1].ticks[axes[1].ticks.length - 1].top, axes[1].ticks[0].top, axes[1]);
		var yZeroPos = axes[1].ticks[axes[1].tickInfo.zeroIndex].top;
		var xZeroPos = axes[0].ticks[axes[0].tickInfo.zeroIndex].left;
		for (valueGroup in valueGroups) {
			var indexes = [];
			var previousValue:Float = 0;
			if (isXCategoric) {
				indexes = xValues.position(valueGroup);
				previousValue = yZeroPos;
			} else {
				indexes = yValues.position(valueGroup);
				previousValue = xZeroPos;
			}

			for (i in indexes) {
				var dataPoint = data[i];
				var x = calcCoordinate(dataPoint.xValue, dataPoint.group, axes[0].ticks, xZeroPos, xDist, style, previousValue, false);
				var y = calcCoordinate(dataPoint.yValue, dataPoint.group, axes[1].ticks, yZeroPos, yDist, style, previousValue, true);
				dataCanvas.componentGraphics.fillStyle(colors[i], 1);
				if (x == null || y == null) {
					continue;
				}
				if (isXCategoric) {
					previousValue = y[0];
				} else {
					previousValue = x[0] + x[1];
				}

				dataCanvas.componentGraphics.rectangle(x[0], y[0], x[1], y[1]);
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
		if (Std.isOfType(value, String)) {
			var ticksFiltered = ticks.filter(x -> {
				return x.text == value;
			});
			if (ticksFiltered == null || ticksFiltered.length == 0) {
				return null;
			}
			var spacePerTick = (dist.pos_dist / (ticks.length - 1)) * 2 / 3;
			if (style.stacked) {
				var pos = (isY ? ticksFiltered[0].top : ticksFiltered[0].left) - (spacePerTick / 2);
				return [pos, spacePerTick];
			}
			var spacePerGroup = spacePerTick / groupNum;

			var overlapEffect = 2.0; // This means basically no effect, everything smaller will make the bars overlap
			if (style.layered) {
				overlapEffect = 1.3;
			}

			var groupOffset = groupNum - group * overlapEffect;
			var posOffset = (isY ? ticksFiltered[0].top : ticksFiltered[0].left) - (spacePerGroup / 2) * groupOffset;
			return [posOffset, spacePerGroup];
		}
		var max = Std.parseFloat(ticks[ticks.length - 1].text);
		var min = Std.parseFloat(ticks[0].text);
		var ratio = value < 0 ? value / min : value / max;
		var pos = zeroPos + (isY ? -1 : 1) * (value < 0 ? -1 * dist.neg_dist : dist.pos_dist) * ratio;
		var finalPos = pos;
		if (style.stacked) {
			if (isY) {
				finalPos = previousPosition - dist.pos_dist * ratio;
			} else {
				finalPos = previousPosition;
			}
		}
		return [finalPos, isY ? zeroPos - pos : pos - zeroPos];
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

	public function positionAxes(axisInfo:Array<AxisInfo>, data:Array<Data2D>, style:TrailStyle):Void {
		axes = [null, null];
		if (axisInfo[0].axis != null) {
			axes[0] = axisInfo[0].axis;
		}
		if (axisInfo[1].axis != null) {
			axes[1] = axisInfo[1].axis;
		}
		if (axes[0] != null && axes[1] != null) {
			AxisTools.addAxisToParent(axes[0], parent);
			AxisTools.addAxisToParent(axes[1], parent);
			return;
		}

		var yAxisLength = parent.height - parent.paddingTop - parent.paddingBottom;
		var xAxisLength = parent.width - parent.paddingLeft - parent.paddingRight;
		if (minY >= 0) {
			yAxisLength = parent.height - parent.paddingTop - parent.paddingBottom - 20; // Additional 20 added to height, so it shows ticks correctly
		}
		if (minX >= 0) {
			xAxisLength = parent.width - parent.paddingLeft - parent.paddingRight;
		}

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

		axes[0].width = parent.width;
		axes[0].height = parent.height;
		axes[1].width = parent.width;
		axes[1].height = parent.height;
		// This is necessary to allow the ticks to be calculated
		if (isXCategoric) {
			axes[0].startPoint = new Point(0, 40);
		} else {
			axes[0].startPoint = new Point(20, 40);
		}
		axes[1].startPoint = new Point(40, yAxisLength);
		// Real positioning

		if (isXCategoric) {
			axes[0].startPoint = new Point(0, axes[1].ticks[axes[1].tickInfo.zeroIndex].top);
			axes[1].startPoint = new Point(axes[0].ticks[axes[0].tickInfo.zeroIndex].left, yAxisLength);
		} else {
			axes[0].startPoint = new Point(20, axes[1].ticks[axes[1].tickInfo.zeroIndex].top);
			axes[1].startPoint = new Point(axes[0].ticks[axes[0].tickInfo.zeroIndex].left, yAxisLength);
		}

		axes[1].showZeroTick = false;
		axes[0].zeroTickPosition = CompassOrientation.SW;
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
	};
}
