package hxchart.basics.plot;

import haxe.ui.geom.Point;
import hxchart.basics.trails.Bar;
import haxe.ui.core.Component;
import haxe.ui.geom.Size;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.events.UIEvent;
import hxchart.basics.colors.ColorPalettes;
import haxe.ui.util.Variant;
import haxe.ui.behaviours.Behaviour;
import hxchart.basics.axis.Axis;
import hxchart.basics.trails.Scatter;
import hxchart.basics.data.DataLayer.TrailData;
import haxe.ui.core.CompositeBuilder;
import haxe.Exception;
import hxchart.basics.axis.Axis.AxisTypes;
import hxchart.basics.data.Data2D;
import hxchart.basics.legend.Legend;
import haxe.ui.containers.Absolute;

enum TrailTypes {
	scatter;
	bar;
	pie;
}

/**
 * Axis information. Usually used in the first trail.
 * 
 * When only `type` is set, the corresponding trail will calculate its own axis.
 * 
 * When supplying `values` beware of these differences based on `type`:
 * - linear: Only the first two values in the array will be used, the represent the min and max values of the axis.
 * - categorical: All values will be used.
 * 
 * @param type Type of axis. The positioning of data depends on this. 
 * @param axis Optional. A full axis object. If this is supplied, the trail will use this axis instead trying to generate its own.
 * @param values Optional. Values the axis should have. Depending on the type, this will work differently.
 */
typedef AxisInfo = {
	type:AxisTypes,
	?axis:Axis,
	?values:Array<Dynamic>
}

/**
 * Styling of a trail
 * @param colorPalette Color values in integer form. The length should be equal or greater than the length of `groups`. 
 * @param groups Mapping of groups from the data, 
 */
typedef TrailStyle = {
	?colorPalette:Array<Int>,
	?groups:Map<String, Int>,
	?layered:Bool,
	?stacked:Bool
}

/**
 * Information about a trail.
 * 
 * Beware `axisInfo` is mandatory for some types of trails:
 * - scatter
 * - bar
 * @param data The data that should be shown. 
 * @param type Type of trail that should be used.
 * @param x Optional. Key of the x values. This is necessary for `type = scatter` when only `data.values` is set.
 * @param y Optional. Key of the y values. This is necessary for `type = scatter` when only `data.values` is set.
 * @param style Optional. Style of the trail. Beware, this will reset if an additional trail is added to the plot, to keep styling consistent.
 * @param axisInfo Optional. Information about the axes. Technically it is possible to give every trail their own axes, resulting in multiple sub-plots (currently not implemented).
 */
typedef TrailInfo = {
	data:TrailData,
	type:TrailTypes,
	?x:String,
	?y:String,
	?style:TrailStyle,
	?axisInfo:Array<AxisInfo>
}

/**
 * Information about a plot legend.
 * 
 * Legends are always plot specific and not trail specific. Meaning multiple trails in a plot share the same legend.
 * @param title Optional. Title displayed on top of the legend. Will default to `"Legend"`.
 * @param nodeFontSize Optional. Fontsize for all legend nodes.
 * @param useLegend Optional. If a legend should be used. Per default a legend will be used.
 */
typedef LegendInfo = {
	?title:String,
	?nodeFontSize:Int,
	?useLegend:Bool
}

/**
 * Object for visualising one or multiple plots. 
 * 
 * A plot consists of one or multiple trails. A trail can be something like a scatter-plot, line-chart, bar-chart etc.
 * 
 * This allows the mixing of different types, for example scatter and line, into a single plot.
 * 
 * Beware that trails in the same plot share the same underlying coordinates (i.e. axes, or something similar) and styling. This may have unintended consequences, when the types don't mix well.
 */
@:composite(Builder)
class Plot extends Absolute {
	public var trailInfos:Array<TrailInfo>;
	public var legendInfo:LegendInfo;

	public var plotBody:Absolute;
	public var groups:Map<String, Int>;
	public var groupNumber:Int;
	public var axes:Map<String, Array<Axis>>;
	public var legend:Legend;

	public function new(chartInfo:TrailInfo, width:Float, height:Float, ?legendInfo:LegendInfo) {
		super();
		trailInfos = [];
		this.width = width;
		this.height = height;
		axes = new Map();
		groups = new Map();
		groupNumber = 0;
		trailInfos.push(chartInfo);
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
		for (info in trailInfos) {
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
				case pie:
			}
		}
		var colors = [];
		for (i => info in trailInfos) {
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
			if (info.style != null) {
				colors = colors.concat(info.style.colorPalette);
			}
		}
		if (colors.length < groupNumber) {
			colors = colors.concat(ColorPalettes.defaultColors(groupNumber - colors.length));
		}
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
		for (info in trailInfos) {
			if (reset) {
				info.style = null;
			}
			if (info.style == null) {
				info.style = {};
			}
			if (info.style.groups == null) {
				info.style.groups = groups;
				info.style.colorPalette = colors;
			}
		}
	}

	@:call(AddChart) public function addChart(chartInfo:TrailInfo):Void;
}

@:dox(hide) @:noCompletion
class PlotLayout extends DefaultLayout {}

@:dox(hide) @:noCompletion
private class AddChart extends Behaviour {
	public override function call(param:Any = null):Variant {
		var plot = cast(_component, Plot);
		var chartInfo:TrailInfo = param;
		plot.trailInfos.push(chartInfo);
		plot.setData(true);
		return null;
	}
}

enum PlotStatus {
	start;
	redraw;
}

class Builder extends CompositeBuilder {
	var _plot:Plot;

	public function new(plot:Plot) {
		super(plot);
		_plot = plot;
		_plot.plotBody = new Absolute();
		_plot.plotBody.percentWidth = 100;
		_plot.plotBody.percentHeight = 100;
		// _plot.plotBody.padding = 10; //Setting padding fucks with the inital positioning (redraw works fine)
		_plot.addComponent(_plot.plotBody);
	}

	override function validateComponentData() {
		super.validateComponentData();
		validateCharts(PlotStatus.start);
	}

	override function validateComponentLayout():Bool {
		_plot.left = _plot.marginLeft;
		_plot.top = _plot.marginTop;
		_plot.width -= _plot.marginLeft + _plot.marginRight;
		_plot.height -= _plot.marginTop + _plot.marginBottom;

		if (_plot.legend != null) {
			_plot.plotBody.percentWidth = 80;
			_plot.legend.percentWidth = 20;
			_plot.legend.left = _plot.plotBody.width + _plot.legend.marginLeft;
		}
		validateCharts(PlotStatus.redraw);
		return super.validateComponentLayout();
	}

	function validateCharts(status:PlotStatus) {
		if (status == PlotStatus.start) {
			_plot.axes = new Map();
		}
		var axisID = "axis_0";
		for (i => chartInfo in _plot.trailInfos) {
			var chartInfo = Reflect.copy(_plot.trailInfos[i]);
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
					if (chartInfo.axisInfo != null && chartInfo.axisInfo.length > 2) {
						throw new Exception("Not able to use more than 2 axes for bar-chart!");
					}
					if (_plot.axes.exists(axisID)) {
						chartInfo.axisInfo = [
							{
								type: categorical,
								axis: _plot.axes.get(axisID)[0]
							},
							{
								type: linear,
								axis: _plot.axes.get(axisID)[1]
							}
						];
					}
					var bar = new Bar(chartInfo, _plot.plotBody, chartID, axisID);
					bar.validateChart();
					if (!_plot.axes.exists(axisID)) {
						_plot.axes.set(axisID, bar.axes);
					}
				case pie:
					return;
			}
		}
	}
}
