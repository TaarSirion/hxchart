package hxchart.haxeui.plot;

import hxchart.core.utils.CoordinateSystem;
import haxe.Timer;
import hxchart.core.utils.Utils;
import haxe.ui.core.Component;
import haxe.ui.styles.StyleSheet;
import haxe.ui.containers.HBox;
import haxe.ui.containers.VBox;
import hxchart.core.events.EventLayer.EventInfo;
import hxchart.core.events.EventLayer.EventHandler;
import haxe.ui.events.MouseEvent;
// import hxchart.haxeui.trails.Bar;
import haxe.ui.layouts.DefaultLayout;
import hxchart.haxeui.colors.ColorPalettes;
import haxe.ui.util.Variant;
import haxe.ui.behaviours.Behaviour;
import hxchart.haxeui.axis.Axis;
import hxchart.haxeui.trails.Scatter;
import hxchart.core.data.DataLayer.TrailData;
import haxe.ui.core.CompositeBuilder;
import haxe.Exception;
import hxchart.core.axis.AxisTypes;
import hxchart.haxeui.legend.Legend;
import haxe.ui.containers.Absolute;
import hxchart.core.chart.ChartStatus;
import hxchart.core.trails.TrailInfo;
import hxchart.core.legend.LegendInfo;
import hxchart.core.optimization.OptimizationType;

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
 */ @:structInit class OptimizationInfo {
	@:optional public var reduceVia:OptimizationType;

	@:optional public var gridStep:Null<Float>;
}

/**
 * Object for visualising one or multiple plots. 
 * 
 * A plot consists of one or multiple trails. A trail can be something like a scatter-plot, line-chart, bar-chart etc.
 * 
 * This allows the mixing of different types, for example scatter and line, into a single plot.
 * 
 * Beware that trails in the same plot share the same underlying coordinates (i.e. axes, or something similar) and styling. This may have unintended consequences, when the types don't mix well.
 */ @:composite(Builder)
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

	public var isAlive:Bool = false;

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

class Builder extends CompositeBuilder {
	var _chart:Chart;
	var eventHandler:EventHandler;
	var registeredHover:Bool = false;

	public function new(chart:Chart) {
		super(chart);
		_chart = chart;
		_chart.styleSheet = chart.chartStyleSheet;
		eventHandler = {};
		_chart.chartBody = new Absolute();
		_chart.chartBody.percentWidth = 100;
		_chart.chartBody.percentHeight = 100;
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
		if (_chart.isAlive) {
			validateCharts(ChartStatus.redraw);
			return;
		}
		validateCharts(ChartStatus.start);
		_chart.isAlive = true;
	}

	override function validateComponentLayout():Bool {
		validateCharts(ChartStatus.redraw);
		return super.validateComponentLayout();
	}

	function validateCharts(status:ChartStatus) {
		if (status == ChartStatus.start) {
			_chart.axes = new Map();
			eventHandler = {};
		}
		var axisID = "axis_0";
		for (i => chartInfo in _chart.trailInfos) {
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
						chartInfo.axisInfo = [
							_chart.axes.get(axisID).axisCalc.axesInfo[0],
							_chart.axes.get(axisID).axisCalc.axesInfo[1]
						];
					} else {
						var coordSystem = new CoordinateSystem();
						chartInfo.axisInfo[0].setAxisInfo(chartInfo.data.values.get("x"));
						chartInfo.axisInfo[1].setAxisInfo(chartInfo.data.values.get("y"));
						var axis = new Axis(axisID, chartInfo.axisInfo, coordSystem);
						axis.percentHeight = 100;
						axis.percentWidth = 100;
						_chart.axes.set(axisID, axis);
						_chart.chartBody.addComponent(axis);
					}

					var scatter = null;
					if (_chart.trails.length < (i + 1)) {
						scatter = new Scatter(chartInfo, _chart.axes.get(axisID), _chart.chartBody, chartID, axisID, eventHandler);
						_chart.trails.push(scatter);
					} else {
						scatter = _chart.trails[i];
					}
					scatter.validateChart(status);
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
						chartInfo.axisInfo = [
							_chart.axes.get(axisID).axisCalc.axesInfo[0],
							_chart.axes.get(axisID).axisCalc.axesInfo[1]
						];
					}
					var scatter = null;
					if (!_chart.axes.exists(axisID)) {
						scatter = new Scatter(chartInfo, null, _chart.chartBody, chartID, axisID, eventHandler);
						_chart.trails.push(scatter);
					} else {
						scatter = _chart.trails[i];
					}
					scatter.validateChart(status);
					if (!_chart.axes.exists(axisID)) {
						_chart.axes.set(axisID, scatter.axes);
					}
				case bar:
					// if (chartInfo.axisInfo == null) {
					// 	chartInfo.axisInfo = [
					// 		{
					// 			id: "x_" + axisID,
					// 			rotation: 0
					// 		},
					// 		{
					// 			id: "y_" + axisID,
					// 			rotation: 90
					// 		}
					// 	];
					// 	chartInfo.axisInfo[0].setAxisInfo(chartInfo.data.values.get("x"));
					// 	chartInfo.axisInfo[1].setAxisInfo(chartInfo.data.values.get("y"));
					// } else if (chartInfo.axisInfo.length > 2) {
					// 	throw new Exception("Not able to use more than 2 axes for bar-chart!");
					// } else {
					// 	chartInfo.axisInfo[0].setAxisInfo(chartInfo.data.values.get("x"));
					// 	chartInfo.axisInfo[1].setAxisInfo(chartInfo.data.values.get("y"));
					// }
					// if (_chart.axes.exists(axisID)) {
					// 	chartInfo.axisInfo = [_chart.axes.get(axisID).axesInfo[0], _chart.axes.get(axisID).axesInfo[1]];
					// }
					// var bar = null;
					// if (!_chart.axes.exists(axisID)) {
					// 	bar = new Bar(chartInfo, null, _chart.chartBody, chartID, axisID);
					// 	_chart.trails.push(bar);
					// } else {
					// 	bar = _chart.trails[i];
					// }
					// bar.validateChart(status);
					// if (!_chart.axes.exists(axisID)) {
					// 	_chart.axes.set(axisID, bar.axes);
					// }
				case pie:
					return;
			}
		}
	}
}
