package hxchart.basics.plot;

import haxe.ui.core.Component;
import haxe.ui.styles.StyleSheet;
import haxe.ui.containers.HBox;
import haxe.ui.containers.VBox;
import hxchart.basics.events.EventLayer.EventInfo;
import hxchart.basics.events.EventLayer.EventHandler;
import haxe.ui.events.MouseEvent;
import hxchart.basics.trails.Bar;
import haxe.ui.layouts.DefaultLayout;
import hxchart.basics.colors.ColorPalettes;
import haxe.ui.util.Variant;
import haxe.ui.behaviours.Behaviour;
import hxchart.basics.axis.Axis;
import hxchart.basics.trails.Scatter;
import hxchart.basics.data.DataLayer.TrailData;
import haxe.ui.core.CompositeBuilder;
import haxe.Exception;
import hxchart.basics.axis.Axis.AxisTypes;
import hxchart.basics.legend.Legend;
import haxe.ui.containers.Absolute;

enum TrailTypes {
	scatter;
	line;
	bar;
	pie;
}

enum PositionOption {
	layered;
	stacked;
	filled;
}

/**
 * Styling of a border
 * 
 * @param thickness Optional. Thickness of the border.
 * @param alpha Optional. Alpha value of the color.
 * @param color Optional. Color
 */
@:structInit class BorderStyle {
	@:optional public var thickness:Any = 1;
	@:optional public var alpha:Any = 1;
	@:optional public var color:Any;
}

/**
 * Styling of a trail
 * @param colorPalette Color values in integer form. The length should be equal or greater than the length of `groups`. 
 * @param groups Mapping of groups from the data, 
 * @param positionOption Option on how to position data
 * @param size Optional. Set the size of points, pies etc.
 * @param alpha Optional. Alpha value of the color.
 * @param borderStyle Optional. Set this to use a border
 */
@:structInit class TrailStyle {
	@:optional public var colorPalette:Array<Int>;
	@:optional public var groups:Map<String, Int>;
	@:optional public var positionOption:PositionOption;
	@:optional public var size:Any;
	@:optional public var alpha:Any = 1;
	@:optional public var borderStyle:BorderStyle;
}

enum OptimizationType {
	optimGrid;
	quadTree;
}

/**
 * Options for optimizing the rendering process.
 * 
 * Only use when you know what you are doing, as this might result in a different looking plot.
 * 
 * *OptimizationTypes:*
 * - `optimGrid` Create an underlying grid, that hinders drawing multiple points over each other, or too close to each other. Use together with `gridStep` to set the size of each cell. Only use this for really large datasets.
 * - `quadTree` Use a quadtree to optimize the drawing of data. Only use this for semi large data (i.e. less than 100'000 points)
 * @param reduceVia Optional. *OptimizationType* to use, options are `optimGrid`, `quadTree`
 * @param gridStep Optional. Use together with `optimGrid`. Defines the size of each cell. Larger values result in less points being drawn!
 */
@:structInit class OptimizationInfo {
	@:optional public var reduceVia:OptimizationType;
	@:optional public var gridStep:Null<Float>;
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
 * @param optimizationInfo Optional. Drawing large amounts of data might need some kind of optimization, which can be set through this info. Be careful with the usage, as some options might result in a different looking plot/chart.
 */
@:structInit class TrailInfo {
	public var data:TrailData;
	public final type:TrailTypes;
	@:optional public var style:TrailStyle;
	@:optional public var axisInfo:Null<Array<AxisInfo>>;
	@:optional public var optimizationInfo:OptimizationInfo;
	@:optional public var events:EventInfo;

	public function validate() {
		switch (type) {
			case scatter:
				if (data.values == null) {
					throw new Exception("No data available. Please set some data in trailInfo.data.values");
				}
				if (!data.values.exists("x") || !data.values.exists("y")) {
					throw new Exception("No data available. Please set 'x' and 'y' as keys in trailInfo.data.values.");
				}
				if (data.values.get("x").length != data.values.get("y").length) {
					throw new Exception("'x' and 'y' need to be the same length.");
				}
			case line:
				if (data.values == null) {
					throw new Exception("No data available. Please set some data in trailInfo.data.values");
				}
				if (!data.values.exists("x") || !data.values.exists("y")) {
					throw new Exception("No data available. Please set 'x' and 'y' as keys in trailInfo.data.values.");
				}
				if (data.values.get("x").length != data.values.get("y").length) {
					throw new Exception("'x' and 'y' need to be the same length.");
				}
			case bar:
				if (data.values == null) {
					throw new Exception("No data available. Please set some data in trailInfo.data.values");
				}
				if (!data.values.exists("x") || !data.values.exists("y")) {
					throw new Exception("No data available. Please set 'x' and 'y' as keys in trailInfo.data.values.");
				}
				if (data.values.get("x").length != data.values.get("y").length) {
					throw new Exception("'x' and 'y' need to be the same length.");
				}
			case pie:
		}
	}
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
class Chart extends Component {
	public var trailInfos:Array<TrailInfo>;
	public var trails:Array<Any>;
	public var legendInfo:LegendInfo;

	public var chartBody:Absolute;
	public var groups:Map<String, Int>;
	public var groupNumber:Int;
	public var axes:Map<String, Axis>;
	public var legend:Legend;
	public var chartStyleSheet:StyleSheet;

	public function new(chartInfo:TrailInfo, ?legendInfo:LegendInfo, ?styleSheet:StyleSheet) {
		super();
		trailInfos = [];
		trails = [];
		axes = new Map();
		groups = new Map();
		groupNumber = 0;
		trailInfos.push(chartInfo);
		chartStyleSheet = styleSheet;
		setLegend(legendInfo, styleSheet);
		setData();
	}

	private function setLegend(legendInfo:LegendInfo, styleSheet:StyleSheet) {
		if (legendInfo == null) {
			legendInfo = {
				useLegend: false
			};
		}
		this.legendInfo = legendInfo;
		if (legendInfo.useLegend) {
			this.legend = new Legend(legendInfo, styleSheet);

			switch (legend.legendPosition) {
				case left:
					var hbox = new HBox();
					hbox.percentWidth = 100;
					hbox.percentHeight = 100;
					hbox.addComponent(legend);
					hbox.addComponent(chartBody);
					addComponent(hbox);
				case right:
					var hbox = new HBox();
					hbox.percentWidth = 100;
					hbox.percentHeight = 100;
					hbox.addComponent(chartBody);
					hbox.addComponent(legend);
					addComponent(hbox);
				case top:
					var vbox = new VBox();
					vbox.percentWidth = 100;
					vbox.percentHeight = 100;
					vbox.addComponent(legend);
					vbox.addComponent(chartBody);
					addComponent(vbox);
				case bottom:
					var vbox = new VBox();
					vbox.percentWidth = 100;
					vbox.percentHeight = 100;
					vbox.addComponent(chartBody);
					vbox.addComponent(legend);
					addComponent(vbox);
				case Point(x, y, vertical):
					chartBody.percentHeight = 100;
					chartBody.percentWidth = 100;
					legend.left = x;
					legend.top = y;
					addComponent(chartBody);
					addComponent(legend);
			}
		} else {
			addComponent(chartBody);
		}
	}

	public function setData(reset:Bool = false) {
		if (reset) {
			legend.removeAllComponents();
			legend.childNodes = [];
		}
		for (info in trailInfos) {
			info.validate();
		}
		var colors = [];
		for (i => info in trailInfos) {
			info.data.setGroups(info.type, Std.string(i + 1));

			for (j => group in info.data.values.get("groups")) {
				if (!(group is String)) {
					continue;
				}
				if (!groups.exists((group : String))) {
					groups.set((group : String), groupNumber);
					groupNumber++;
				}
			}
			if (info.style != null && info.style.colorPalette != null) {
				colors = colors.concat(info.style.colorPalette);
			}
		}
		if (colors.length < groupNumber) {
			colors = colors.concat(ColorPalettes.defaultColors(groupNumber - colors.length));
		}
		if (legendInfo.useLegend) {
			legendInfo.validate();
			if (legendInfo.data != null) {
				for (node in legendInfo.data) {
					legend.addNode(node);
				}
			} else {
				var groupIterationIndex:Int = 0;
				for (group in groups.keys()) {
					if (legend.childNodes.contains(group)) {
						continue;
					}
					legend.addNode({
						style: {
							symbol: legendInfo.nodeStyle.symbol,
							symbolColor: colors[groupIterationIndex]
						},
						text: group
					});
					groupIterationIndex++;
				}
			}
		}

		for (info in trailInfos) {
			if (reset) {
				info.style = null;
			}
			if (info.style == null) {
				info.style = {};
			}
			if (info.style.colorPalette == null) {
				info.style.colorPalette = colors;
			}
			if (info.style.alpha == null) {
				info.style.alpha = 1;
			}
			if (info.style.size == null) {
				info.style.size = 2;
			}
			if (info.style.borderStyle == null) {
				info.style.borderStyle = {
					thickness: 1,
					alpha: 1
				}
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
class ChartLayout extends DefaultLayout {}

@:dox(hide) @:noCompletion
private class AddChart extends Behaviour {
	public override function call(param:Any = null):Variant {
		var chart = cast(_component, Chart);
		var chartInfo:TrailInfo = param;
		chart.trailInfos.push(chartInfo);
		chart.setData(true);
		return null;
	}
}

enum ChartStatus {
	start;
	redraw;
}

class Builder extends CompositeBuilder {
	var _chart:Chart;
	var eventHandler:EventHandler;

	public function new(chart:Chart) {
		super(chart);
		_chart = chart;
		_chart.styleSheet = chart.chartStyleSheet;
		eventHandler = {};
		_chart.chartBody = new Absolute();
		_chart.chartBody.percentWidth = 100;
		_chart.chartBody.percentHeight = 100;
		// _chart.addComponent(_chart.chartBody);
		_chart.registerEvent(MouseEvent.MOUSE_MOVE, function(e) {
			for (handler in eventHandler.hoverHandlers) {
				handler(e);
			}
		});
		_chart.registerEvent(MouseEvent.CLICK, function(e) {
			for (handler in eventHandler.clickHandlers) {
				handler(e);
			}
		});
	}

	override function validateComponentData() {
		super.validateComponentData();
		validateCharts(ChartStatus.start);
	}

	override function validateComponentLayout():Bool {
		_chart.left = _chart.marginLeft;
		_chart.top = _chart.marginTop;
		_chart.width -= _chart.marginLeft + _chart.marginRight;
		_chart.height -= _chart.marginTop + _chart.marginBottom;
		validateCharts(ChartStatus.redraw);
		return super.validateComponentLayout();
	}

	function validateCharts(status:ChartStatus) {
		eventHandler = {};
		if (status == ChartStatus.start) {
			_chart.axes = new Map();
		}
		var axisID = "axis_0";
		for (i => chartInfo in _chart.trailInfos) {
			// var chartInfo = Reflect.copy(_chart.trailInfos[i]);
			if (chartInfo == null) {
				continue;
			}

			var chartID = "chart_" + i;
			if (chartInfo.axisInfo != null) {
				axisID = "axis_" + i;
			}
			switch (chartInfo.type) {
				case scatter:
					if (chartInfo.axisInfo == null) {
						chartInfo.axisInfo = [
							{
								id: "x_" + axisID,
								rotation: 0
							},
							{
								id: "y_" + axisID,
								rotation: 90
							}
						];
						chartInfo.axisInfo[0].setAxisInfo(chartInfo.data.values.get("x"));
						chartInfo.axisInfo[1].setAxisInfo(chartInfo.data.values.get("y"));
					} else if (chartInfo.axisInfo.length > 2) {
						throw new Exception("Not able to use more than 2 axes for scatterplot!");
					}
					if (_chart.axes.exists(axisID)) {
						chartInfo.axisInfo = [_chart.axes.get(axisID).axesInfo[0], _chart.axes.get(axisID).axesInfo[1]];
					}
					var scatter = new Scatter(chartInfo, _chart.chartBody, chartID, axisID, eventHandler);
					scatter.validateChart();
					if (!_chart.axes.exists(axisID)) {
						_chart.axes.set(axisID, scatter.axes);
					}
				case line:
					if (chartInfo.axisInfo == null) {
						chartInfo.axisInfo = [
							{
								id: "x_" + axisID,
								rotation: 0
							},
							{
								id: "y_" + axisID,
								rotation: 90
							}
						];
						chartInfo.axisInfo[0].setAxisInfo(chartInfo.data.values.get("x"));
						chartInfo.axisInfo[1].setAxisInfo(chartInfo.data.values.get("y"));
					} else if (chartInfo.axisInfo.length > 2) {
						throw new Exception("Not able to use more than 2 axes for scatterplot!");
					} else {
						chartInfo.axisInfo[0].setAxisInfo(chartInfo.data.values.get("x"));
						chartInfo.axisInfo[1].setAxisInfo(chartInfo.data.values.get("y"));
					}
					if (_chart.axes.exists(axisID)) {
						chartInfo.axisInfo = [_chart.axes.get(axisID).axesInfo[0], _chart.axes.get(axisID).axesInfo[1]];
					}
					var scatter = new Scatter(chartInfo, _chart.chartBody, chartID, axisID, eventHandler);
					scatter.validateChart();
					if (!_chart.axes.exists(axisID)) {
						_chart.axes.set(axisID, scatter.axes);
					}
				case bar:
					if (chartInfo.axisInfo != null && chartInfo.axisInfo.length > 2) {
						throw new Exception("Not able to use more than 2 axes for bar-chart!");
					}
					if (_chart.axes.exists(axisID)) {
						chartInfo.axisInfo = [_chart.axes.get(axisID).axesInfo[0], _chart.axes.get(axisID).axesInfo[1]];
					}
					var bar = new Bar(chartInfo, _chart.chartBody, chartID, axisID);
					bar.validateChart();
					if (!_chart.axes.exists(axisID)) {
						_chart.axes.set(axisID, bar.axes);
					}
				case pie:
					return;
			}
		}
	}
}
