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
		positionAxes(trailInfo.axisInfo, data);
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
		sortData();
	};

	var minX:Float;
	var minY:Float;
	var maxX:Float;
	var maxY:Float;

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

	public function positionData(style:TrailStyle):Void {
		if (axes.length < 2) {
			throw new Exception("Too few axes for drawing data.");
		}
		if (axes[0].tickInfo == null || axes[1].tickInfo == null) {
			throw new Exception("Two tickinfos are needed for positioning the data correctly!");
		}
		var xCoordMin = axes[0].ticks[0].left;
		var xCoordMax = axes[0].ticks[axes[0].ticks.length - 1].left;
		var ratio = 1.0;
		if (Std.isOfType(axes[0].tickInfo, NumericTickInfo)) {
			var tickInfo:NumericTickInfo = cast(axes[0].tickInfo, NumericTickInfo);
			ratio = 1 - tickInfo.negNum / (tickInfo.tickNum - 1);
		}
		var xDist = ChartTools.calcAxisDists(xCoordMin, xCoordMax, ratio);
		var yCoordMin = axes[1].ticks[0].top;
		var yCoordMax = axes[1].ticks[axes[1].ticks.length - 1].top;
		ratio = 1.0;
		if (Std.isOfType(axes[1].tickInfo, NumericTickInfo)) {
			var tickInfo:NumericTickInfo = cast(axes[1].tickInfo, NumericTickInfo);
			ratio = 1 - tickInfo.negNum / (tickInfo.tickNum - 1);
		}
		var yDist = ChartTools.calcAxisDists(yCoordMax, yCoordMin, ratio);
		for (i => dataPoint in data) {
			var x = calcXCoords(dataPoint.xValue, axes[0].ticks, axes[0].ticks[axes[0].tickInfo.zeroIndex].left, xDist);
			var y = calcYCoords(dataPoint.yValue, axes[1].ticks, axes[1].ticks[axes[1].tickInfo.zeroIndex].top, yDist);
			dataCanvas.componentGraphics.strokeStyle(colors[i], 1);
			if (x == null || y == null) {
				continue;
			}
			dataCanvas.componentGraphics.rectangle(x[0], y[0], x[1], y[1]);
		}
		var canvasComponent = parent.findComponent(id);
		if (canvasComponent == null) {
			parent.addComponent(dataCanvas);
		} else {
			parent.removeComponent(canvasComponent);
			parent.addComponent(dataCanvas);
		}
	};

	function calcXCoords(value:Dynamic, ticks:Array<Ticks>, zeroPos:Float, dist:AxisDist):Array<Float> {
		if (Std.isOfType(value, String)) {
			var ticksFiltered = ticks.filter(x -> {
				return x.text == value;
			});
			if (ticksFiltered == null || ticksFiltered.length == 0) {
				return null;
			}
			return [ticksFiltered[0].left - 5, 10];
		}
		var xMax = Std.parseFloat(ticks[ticks.length - 1].text);
		var xMin = Std.parseFloat(ticks[0].text);
		var x_ratio = value / xMax;
		var x = zeroPos + dist.pos_dist * x_ratio;
		if (value < 0) {
			x_ratio = value / xMin;
			x = zeroPos - dist.neg_dist * x_ratio;
		}
		return [0, x];
	}

	function calcYCoords(value:Dynamic, ticks:Array<Ticks>, zeroPos:Float, dist:AxisDist):Array<Float> {
		if (Std.isOfType(value, String)) {
			var ticksFiltered = ticks.filter(y -> {
				return y.text == value;
			});
			if (ticksFiltered == null || ticksFiltered.length == 0) {
				return null;
			}
			return [ticksFiltered[0].top + 5, 10];
		}
		var yMax = Std.parseFloat(ticks[ticks.length - 1].text);
		var yMin = Std.parseFloat(ticks[0].text);
		var y_ratio = value / yMax;
		var y = zeroPos - dist.pos_dist * y_ratio;
		if (value < 0) {
			y_ratio = value / yMin;
			y = zeroPos + dist.neg_dist * y_ratio;
		}
		return [y, zeroPos - y];
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

	public function positionAxes(axisInfo:Array<AxisInfo>, data:Array<Data2D>):Void {
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

		axes[0].width = xAxisLength;
		axes[0].height = yAxisLength;
		axes[1].width = xAxisLength;
		axes[1].height = yAxisLength;
		// This is necessary to allow the ticks to be calculated
		axes[0].startPoint = new Point(0, 40);
		axes[1].startPoint = new Point(40, yAxisLength);
		// Real positioning
		axes[0].startPoint = new Point(0, axes[1].ticks[axes[1].tickInfo.zeroIndex].top);
		axes[1].startPoint = new Point(axes[0].ticks[axes[0].tickInfo.zeroIndex].left, yAxisLength);
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
