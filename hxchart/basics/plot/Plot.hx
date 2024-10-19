package hxchart.basics.plot;

import hxchart.basics.colors.ColorPalettes;
import haxe.ui.util.Variant;
import haxe.ui.behaviours.Behaviour;
import hxchart.basics.axis.Axis;
import hxchart.basics.pointchart.Scatter;
import hxchart.basics.data.DataLayer.AddDataType;
import haxe.ui.core.CompositeBuilder;
import haxe.Exception;
import hxchart.basics.axis.Axis.AxisTypes;
import hxchart.basics.data.Data2D;
import hxchart.basics.legend.Legend;
import haxe.ui.containers.Absolute;

enum ChartTypes {
	scatter;
	bar;
	pie;
}

typedef AxisInfo = {
	type:AxisTypes,
	?axis:Axis,
	?values:Array<Dynamic>
}

typedef ChartStyle = {
	colorPalette:Array<Int>,
	groups:Map<String, Int>
}

typedef ChartInfo = {
	data:AddDataType,
	type:ChartTypes,
	?x:String,
	?y:String,
	?style:ChartStyle,
	?axisInfo:Array<AxisInfo>
}

typedef LegendInfo = {
	?title:String,
	?nodeFontSize:Int,
	?useLegend:Bool
}

@:composite(Builder)
class Plot extends Absolute {
	public var chartInfos:Array<ChartInfo>;
	public var legendInfo:LegendInfo;

	public var plotBody:Absolute;
	public var groups:Map<String, Int>;
	public var groupNumber:Int;
	public var axes:Map<String, Array<Axis>>;
	public var legend:Legend;

	public function new(chartInfo:ChartInfo, width:Float, height:Float, ?legendInfo:LegendInfo) {
		super();
		chartInfos = [];
		axes = new Map();
		groups = new Map();
		groupNumber = 0;
		chartInfos.push(chartInfo);
		if (legendInfo == null) {
			legendInfo = {
				useLegend: true,
				nodeFontSize: 12,
				title: "Legend"
			};
		}

		if (legendInfo.useLegend == null || legendInfo.useLegend) {
			this.legend = new Legend();
			legend.legendTitle = "Legend";
			if (legendInfo.title != null) {
				legend.legendTitle = legendInfo.title;
			}
			if (legendInfo.nodeFontSize == null) {
				legendInfo.nodeFontSize = 12;
			}
			this.legendInfo = legendInfo;
			addComponent(legend);
		}

		setData();
	}

	public function setData(reset:Bool = false) {
		if (reset) {
			legend.removeAllComponents();
			legend.childNodes = [];
		}
		for (info in chartInfos) {
			switch (info.type) {
				case scatter:
					if (info.data.values == null && info.data.xValues == null && info.data.yValues == null) {
						throw new Exception("No data available. Please set some data in chartInfo.data.values or chartInfo.data.xValues");
					}
					if (info.x == null && info.data.xValues == null) {
						throw new Exception("Not possible to discern the values for x-axis. Please set chartInfo.x or chartInfo.data.xValues");
					} else if (info.data.xValues == null) {
						info.data.xValues = info.data.values.get(info.x);
					}
					if (info.y == null && info.data.yValues == null) {
						throw new Exception("Not possible to discern the values for y-axis. Please set chartInfo.y or chartInfo.data.yValues");
					} else if (info.data.yValues == null) {
						info.data.yValues = info.data.values.get(info.y);
					}
				case bar:
				case pie:
			}
		}

		for (i => info in chartInfos) {
			if (info.data.groups == null) {
				info.data.groups = [];
				if (info.data.values != null && info.data.values.exists("groups")) {
					info.data.groups = info.data.values.get("groups").map(x -> Std.string(x));
				} else {
					for (j in 0...info.data.xValues.length) {
						info.data.groups.push(Std.string(i + 1));
					}
				}
			}
			for (j => group in info.data.groups) {
				if (!groups.exists(group)) {
					groups.set(group, groupNumber);
					groupNumber++;
				}
			}
		}
		var colors = ColorPalettes.defaultColors(groupNumber);
		var groupIterationIndex = 0;
		for (group in groups.keys()) {
			if (legend.childNodes.contains(group)) {
				continue;
			}
			legend.addNode({
				text: group,
				fontSize: legendInfo.nodeFontSize,
				color: colors[groupIterationIndex]
			});
			groupIterationIndex++;
		}
		for (info in chartInfos) {
			if (reset) {
				info.style = null;
			}
			if (info.style == null) {
				info.style = {
					colorPalette: colors,
					groups: groups
				};
			}
		}
	}

	@:call(AddChart) public function addChart(chartInfo:ChartInfo):Void;
}

@:dox(hide) @:noCompletion
private class AddChart extends Behaviour {
	public override function call(param:Any = null):Variant {
		var plot = cast(_component, Plot);
		var chartInfo:ChartInfo = param;
		plot.chartInfos.push(chartInfo);
		plot.setData(true);
		return null;
	}
}

class Builder extends CompositeBuilder {
	var _plot:Plot;

	public function new(plot:Plot) {
		super(plot);
		_plot = plot;
		_plot.plotBody = new Absolute();
		_plot.plotBody.percentHeight = 100;
		_plot.plotBody.percentWidth = 100;
		_plot.addComponent(_plot.plotBody);
	}

	override function validateComponentData() {
		super.validateComponentData();
		_plot.axes = new Map();
		var axisID = "axis_0";

		for (i => chartInfo in _plot.chartInfos) {
			var chartInfo = Reflect.copy(_plot.chartInfos[i]);
			var chartID = "chart_" + i;
			if (chartInfo.axisInfo != null) {
				axisID = "axis_" + i;
			}
			switch (chartInfo.type) {
				case scatter:
					if (chartInfo.axisInfo != null && chartInfo.axisInfo.length > 2) {
						throw new Exception("Not able to use more than 2 axes for scatterplot!");
					}
					if (_plot.axes.exists(axisID)) {
						chartInfo.axisInfo = [
							{
								type: linear,
								axis: _plot.axes.get(axisID)[0]
							},
							{
								type: linear,
								axis: _plot.axes.get(axisID)[1]
							}
						];
					}
					var scatter = new Scatter(chartInfo, _plot.plotBody, chartID, axisID);
					scatter.validateChart();
					if (!_plot.axes.exists(axisID)) {
						_plot.axes.set(axisID, scatter.axes);
					}
				case bar:
					return;
				case pie:
					return;
			}
		}
	}

	override function validateComponentLayout():Bool {
		super.validateComponentLayout();
		_plot.left = _plot.marginLeft;
		_plot.top = _plot.marginTop;
		_plot.width -= _plot.marginLeft + _plot.marginRight;
		_plot.height -= _plot.marginTop + _plot.marginBottom;

		_plot.plotBody.left = _plot.paddingLeft;
		_plot.plotBody.top = _plot.paddingTop;
		_plot.plotBody.width -= _plot.paddingLeft + _plot.paddingRight;
		_plot.plotBody.height -= _plot.paddingTop + _plot.paddingBottom;

		if (_plot.legend != null) {
			_plot.plotBody.percentWidth = 80;
			_plot.legend.percentWidth = 20;
			_plot.legend.left = _plot.plotBody.width + _plot.legend.marginLeft;
		}
		return true;
	}
}
