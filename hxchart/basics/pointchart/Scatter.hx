package hxchart.basics.pointchart;

import hxchart.basics.pointchart.ChartTools.AxisDist;
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
import hxchart.basics.colors.ColorPalettes;
import haxe.ui.util.Color;
import hxchart.basics.data.Data2D;
import hxchart.basics.plot.Plot.AxisInfo;
import hxchart.basics.plot.Plot.ChartInfo;
import hxchart.basics.data.DataLayer;
import hxchart.basics.axis.AxisLayer;

class Scatter implements AxisLayer implements DataLayer {
	public var id:String;
	public var tickInfos:Array<TickInfo>;
	public var axes:Array<Axis>;

	public function styleAxes():Void {};

	public var data:Array<Data2D>;
	public var groups:Map<String, Int>;
	public var colors:Array<Color>;
	public var dataLayer:Absolute;
	public var dataCanvas:Canvas;

	public var colorPalette:Array<Int>;

	public var parent:Absolute;

	public function new(chartInfo:ChartInfo, parent:Absolute, id:String) {
		this.parent = parent;
		colors = [];
		data = [];
		dataCanvas = new Canvas();
		dataCanvas.id = id;
		dataCanvas.percentHeight = 100;
		dataCanvas.percentWidth = 100;
		this.id = id;
		setData(chartInfo.data);
		positionAxes(chartInfo.axisInfo, data);
		positionData(tickInfos, axes);
	}

	public function setData(newData:AddDataType) {
		if (newData.groups == null) {
			newData.groups = [];
			for (i in 0...newData.xValues.length) {
				newData.groups.push("1");
			}
		}
		var j = 0;
		groups = new Map();
		for (i => val in newData.groups) {
			if (newData.groups.indexOf(val) == i) {
				groups.set(val, j);
				j++;
			}
		}
		var countGroups = j;
		if (colorPalette == null) {
			colorPalette = ColorPalettes.defaultColors(countGroups);
		}
		for (i in 0...newData.xValues.length) {
			var point = new Data2D(newData.xValues[i], newData.yValues[i], groups.get(newData.groups[i]));
			colors.push(colorPalette[point.group]);
			data.push(point);
		}
		sortData();
	}

	var minX:Float;
	var maxX:Float;
	var minY:Float;
	var maxY:Float;

	function sortData() {
		var xVals = data.map(x -> {
			return x.xValue;
		});
		var yVals = data.map(x -> {
			return x.yValue;
		});
		if (xVals[0] is Float) {
			xVals.sort(Reflect.compare);
			minX = xVals[0];
			maxX = xVals[xVals.length - 1];
		}
		if (yVals[0] is Float) {
			yVals.sort(Reflect.compare);
			minY = yVals[0];
			maxY = yVals[yVals.length - 1];
		}
	}

	function setTickInfo(type:AxisTypes, infoValues:Array<Dynamic>, dataValues:Array<Dynamic>, dataMin:Float, dataMax:Float) {
		switch (type) {
			case linear:
				var min:Float = dataMin;
				var max:Float = dataMax;
				if (infoValues != null && infoValues.length >= 2) {
					min = infoValues[0];
					max = infoValues[1];
				}
				tickInfos.push(new NumericTickInfo(min, max));
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
				tickInfos.push(new StringTickInfo(values));
		}
	}

	public function positionAxes(axisInfo:Array<AxisInfo>, data:Array<Data2D>) {
		tickInfos = [];
		axes = [];
		setTickInfo(axisInfo[0].type, axisInfo[0].values, data.map(x -> {
			return x.xValue;
		}), minX, maxX);
		setTickInfo(axisInfo[1].type, axisInfo[1].values, data.map(x -> {
			return x.yValue;
		}), minY, maxY);
		var yAxisLength = parent.height - parent.paddingTop - parent.paddingBottom;
		var xAxisLength = parent.width - parent.paddingLeft - parent.paddingRight;
		axes.push(new Axis(new Point(0, 0), 0, xAxisLength, tickInfos[0], "xaxis"));
		axes[0].width = xAxisLength;
		axes[0].height = yAxisLength;
		axes.push(new Axis(new Point(0, 0), 270, yAxisLength, tickInfos[1], "yaxis"));
		axes[1].width = xAxisLength;
		axes[1].height = yAxisLength;
		// This is necessary to allow the ticks to be calculated
		axes[0].startPoint = new haxe.ui.geom.Point(0, 40);
		axes[1].startPoint = new haxe.ui.geom.Point(40, yAxisLength);
		// Real positioning
		axes[0].startPoint = new haxe.ui.geom.Point(0, axes[1].ticks[tickInfos[1].zeroIndex].top);
		axes[1].startPoint = new haxe.ui.geom.Point(axes[0].ticks[tickInfos[0].zeroIndex].left, yAxisLength);
		axes[1].showZeroTick = false;
		axes[0].zeroTickPosition = CompassOrientation.SW;
		var xComponent:Absolute = parent.findComponent("xaxis");
		if (xComponent == null) {
			parent.addComponent(axes[0]);
		} else {
			parent.removeComponent(xComponent);
			parent.addComponent(axes[0]);
		}
		var yComponent:Absolute = parent.findComponent("yaxis");
		if (yComponent == null) {
			parent.addComponent(axes[1]);
		} else {
			parent.removeComponent(yComponent);
			parent.addComponent(axes[1]);
		}
	}

	public function positionData(tickInfos:Array<TickInfo>, axes:Array<Axis>) {
		if (tickInfos.length < 2 || tickInfos[0] == null || tickInfos[1] == null) {
			throw new Exception("Two tickinfos are needed for positioning the data correctly!");
		}
		if (tickInfos.length != axes.length) {
			throw new Exception("TickInfos and Axes don't have the same length!");
		}
		var x_coord_min = axes[0].ticks[0].left;
		var x_coord_max = axes[0].ticks[axes[0].ticks.length - 1].left;
		var ratio = 1.0;
		if (tickInfos[0] is NumericTickInfo) {
			var tickInfo:NumericTickInfo = cast(tickInfos[0], NumericTickInfo);
			ratio = 1 - tickInfo.negNum / (tickInfo.tickNum - 1);
		}
		var x_dist = ChartTools.calcAxisDists(x_coord_min, x_coord_max, ratio);
		var y_coord_min = axes[1].ticks[0].top;
		var y_coord_max = axes[1].ticks[axes[1].ticks.length - 1].top;
		ratio = 1.0;
		if (tickInfos[1] is NumericTickInfo) {
			var tickInfo:NumericTickInfo = cast(tickInfos[1], NumericTickInfo);
			ratio = 1 - tickInfo.negNum / (tickInfo.tickNum - 1);
		}
		var y_dist = ChartTools.calcAxisDists(y_coord_max, y_coord_min, ratio);
		for (i => dataPoint in data) {
			var x = calcXCoord(dataPoint.xValue, axes[0].ticks, axes[0].ticks[tickInfos[0].zeroIndex].left, x_dist);
			var y = calcYCoord(dataPoint.yValue, axes[1].ticks, axes[1].ticks[tickInfos[1].zeroIndex].top, y_dist);
			dataCanvas.componentGraphics.strokeStyle(colors[i], 1);
			dataCanvas.componentGraphics.circle(x, y, 1);
		}
		var canvasComponent = parent.findComponent(id);
		if (canvasComponent == null) {
			parent.addComponent(dataCanvas);
		} else {
			parent.removeComponent(canvasComponent);
			parent.addComponent(dataCanvas);
		}
		return null;
	}

	public function calcXCoord(xValue:Dynamic, ticks:Array<Ticks>, zeroPos:Float, xDist:AxisDist) {
		if (xValue is String) {
			var ticksFiltered = ticks.filter(x -> {
				return x.text == xValue;
			});
			return ticksFiltered[0].left;
		}
		var xMax = Std.parseFloat(ticks[ticks.length - 1].text);
		var xMin = Std.parseFloat(ticks[0].text);
		var x_ratio = xValue / xMax;
		var x = zeroPos + xDist.pos_dist * x_ratio;
		if (xValue < 0) {
			x_ratio = xValue / xMin;
			x = zeroPos - xDist.neg_dist * x_ratio;
		}
		return x;
	}

	public function calcYCoord(yValue:Dynamic, ticks:Array<Ticks>, zeroPos:Float, yDist:AxisDist) {
		if (yValue is String) {
			var ticksFiltered = ticks.filter(x -> {
				return x.text == yValue;
			});
			return ticksFiltered[0].top;
		}
		var yMax = Std.parseFloat(ticks[ticks.length - 1].text);
		var yMin = Std.parseFloat(ticks[0].text);
		var y_ratio = yValue / yMax;
		var y = zeroPos - yDist.pos_dist * y_ratio;
		if (yValue < 0) {
			y_ratio = yValue / yMin;
			y = zeroPos + yDist.neg_dist * y_ratio;
		}
		return y;
	}
}
