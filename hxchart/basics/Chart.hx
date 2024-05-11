package hxchart.basics;

import hxchart.basics.points.PointLayer;
import haxe.ui.geom.Size;
import haxe.ui.components.Button;
import haxe.ui.core.Component;
import haxe.ui.data.ListDataSource;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.behaviours.Behaviour;
import haxe.ui.util.Variant;
import haxe.ui.data.DataSource;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.util.Color;
import hxchart.basics.colors.ColorPalettes;
import haxe.ui.Toolkit;
import haxe.ui.styles.elements.Directive;
import haxe.ui.styles.elements.RuleElement;
import haxe.ui.styles.StyleSheet;
import hxchart.basics.legend.LegendTools.LegendPosition;
import hxchart.basics.legend.Legend;
import hxchart.basics.axis.AxisInfo;
import hxchart.basics.axis.Axis;
import haxe.ui.events.UIEvent;
import haxe.ui.containers.Absolute;
import hxchart.basics.Options.Option;
import hxchart.basics.ChartTools.AxisDist;
import haxe.ui.core.Screen;
import haxe.ui.components.Canvas;
import hxchart.basics.points.Point;
import hxchart.basics.axis.AxisTools;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.ValueBehaviour;

typedef ChartInfo = {
	axis_info:AxisInfo,
	x_tick_info:TickInfo,
	y_tick_info:TickInfo,
	x_dist:AxisDist,
	y_dist:AxisDist,
}

typedef TickInfos = {
	x:TickInfo,
	y:TickInfo,
}

/**
 * Basic `Chart` displaying points on a 2d coordinate system.
 */
@:composite(Builder, ChartLayout)
class Chart extends Absolute {
	@:behaviour(OptionsBehaviour) public var optionsDS:DataSource<Options>;
	@:behaviour(CanvasBehaviour) public var canvas:Canvas;

	@:call(SetTickInfo) public function setTickInfo(data:hxchart.basics.ChartTools.ChartMinMax):Void;

	@:call(SetPoints) public function setPoints(data:PointAdd):Void;

	@:call(SetLegend) public function setLegend(data:LegendAdd):Void;

	@:call(SetAxis) public function setAxis():Void;

	@:call(DrawPoints) public function drawPoints():Void;

	public var pointlayer:PointLayer;

	public var point_groups(default, set):Map<String, Int>;

	function set_point_groups(point_groups:Map<String, Int>) {
		return this.point_groups = point_groups;
	}

	public var x_tick_info:TickInfo;
	public var y_tick_info:TickInfo;

	private var options:Options;

	public var x_axis:Axis;
	public var y_axis:Axis;

	public var legendLayer(default, set):Absolute;

	function set_legendLayer(legendLayer:Absolute) {
		return this.legendLayer = legendLayer;
	}

	public var legend(default, set):Legend;

	function set_legend(legend:Legend) {
		return this.legend = legend;
	}

	private var init_top:Float = 0;
	private var init_left:Float = 0;

	/**
	 * [Create a new object of type Chart]
	 * @param top Initial top position of the chart.
	 * @param left Initial left position of the chart.
	 * @param width Initial width of the chart. Will at default use 500px.
	 * @param height Initial height of the chart. Will at default use 500px.
	 */
	public function new() {
		super();
	}

	private function createCanvas(top:Float, left:Float) {
		canvas.percentWidth = 100;
		canvas.percentHeight = 100;
		canvas.top = top;
		canvas.left = left;
	}

	private var init_width:Float = 0;
	private var init_height:Float = 0;

	private function setDimensions(width:Float, height:Float) {
		var screen = Screen.instance;
		this.width = width == null ? screen.width : width;
		this.height = height == null ? 500 : height;
		if (init_width == 0) {
			init_width = this.width;
		}
		if (init_height == 0) {
			init_height = this.height;
		}
	}

	public var min_x:Float;
	public var max_x:Float;
	public var min_y:Float;
	public var max_y:Float;

	public function sortPoints() {
		var minmax = pointlayer.sortPoints();
		min_x = minmax.min_x;
		max_x = minmax.max_x;
		min_y = minmax.min_y;
		max_y = minmax.max_y;
		return minmax;
	}

	/**
	 * [Draw the chart. This will explicitly call the functions for generating the chart.]
	 */
	public function draw() {
		// var axis_info = drawAxis();
		// drawPoints(axis_info);
		// legend.draw(label_layer);
		trace("drawing chart");
		return this;
	}

	private var margin_bottom:Float = 60;
	private var margin_left:Float = 60;

	/**
	 * [Set options for a chart]
	 * @param options An array of `Option`. Each option need to have a name and value.
	 */
	public function setOptions(options:Array<Option>) {
		for (option in options) {
			switch option.name {
				case margin:
					this.options.margin = option.value;
				case tick_length:
					this.options.tick_length = option.value;
				case tick_color:
					this.options.tick_color = option.value;
				case tick_margin:
					this.options.tick_margin = option.value;
				case tick_fontsize:
					this.options.tick_fontsize = option.value;

				case color:
					var old_color = this.options.color;
					this.options.color = option.value;
					if (old_color.toInt() == this.options.point_color[0].toInt()) {
						this.options.point_color[0] = option.value;
					}
					if (old_color.toInt() == this.options.tick_color.toInt()) {
						this.options.tick_color = option.value;
					}
				case point_size:
					this.options.point_size = option.value;
				case point_color:
					this.options.point_color = option.value;
				case legend_options:
					legend.setOptions(option.value);
				case use_legend:
					if (!this.options.used_set_legend) {
						this.options.use_legend = option.value;
					}
			}
		}
	}
}

@:dox(hide) @:noCompletion
private class ChartLayout extends DefaultLayout {
	public override function repositionChildren() {
		trace("reposition");
		var chart:Chart = cast(_component, Chart);
		chart.setAxis();
	}

	public override function resizeChildren() {
		trace("resizeChildren");
		var chart:Chart = cast(_component, Chart);
		chart.setAxis();
	}

	override function autoSize():Bool {
		trace("Autosize");
		return super.autoSize();
	}

	override function calcAutoSize(exclusions:Array<Component> = null):Size {
		trace("Calc auto");
		return super.calcAutoSize(exclusions);
	}
}

@:dox(hide) @:noCompletion
private class OptionsBehaviour extends DataBehaviour {
	override function set(value:Variant) {
		super.set(value);
	}

	private override function validateData() {
		var optionDS:DataSource<Options> = _value;
		if (optionDS.get(0) != null) {
			setStyleSheet(optionDS.get(0));
		}
	}

	private function setStyleSheet(options:Options) {
		_component.styleSheet = new StyleSheet();
		_component.styleSheet.parse("");
	}
}

@:dox(hide) @:noCompletion
private class CanvasBehaviour extends DataBehaviour {
	private override function validateData() {
		if (_component.findComponent(null, Canvas) == null) {
			trace("Canvas");
			_component.addComponent(_value);
		}
	}
}

@:dox(hide) @:noCompletion
private class SetTickInfo extends Behaviour {
	public override function call(param:Any = null):Variant {
		var pointInfo:hxchart.basics.ChartTools.ChartMinMax = param;
		var infos:TickInfos = {
			x: AxisTools.calcTickInfo(pointInfo.min_x, pointInfo.max_x),
			y: AxisTools.calcTickInfo(pointInfo.min_y, pointInfo.max_y)
		}
		var chart = cast(_component, Chart);
		chart.y_axis.left = chart.x_axis.ticks[infos.x.zero].left - 15;
		chart.y_axis.width = 30;
		chart.x_axis.top = chart.y_axis.ticks[infos.y.zero].top - 15;
		chart.x_axis.height = 30;
		chart.x_tick_info = infos.x;
		chart.y_tick_info = infos.y;
		return chart;
	}
}

typedef PointAdd = {
	x_points:Array<Float>,
	y_points:Array<Float>,
	groups:Array<String>
}

@:dox(hide) @:noCompletion
private class SetPoints extends Behaviour {
	public override function call(param:Any = null):Variant {
		var chart = cast(_component, Chart);
		var options = chart.optionsDS.get(0);
		var params:PointAdd = param;
		if (params.groups == null) {
			params.groups = [];
			for (i in 0...params.x_points.length) {
				params.groups.push("1");
			}
		}
		var j = 0;
		chart.point_groups = new Map();
		for (i => val in params.groups) {
			if (params.groups.indexOf(val) == i) {
				chart.point_groups.set(val, j);
				j++;
			}
		}
		for (i in 0...params.x_points.length) {
			var point = new Point(params.x_points[i], params.y_points[i], options, chart.point_groups.get(params.groups[i]));
			chart.pointlayer.addPoint(point);
		}

		if (j > 0 && options.point_color.length == 1) {
			options.point_color = ColorPalettes.defaultColors(j + 1);
		}
		return chart;
	}
}

typedef LegendAdd = {
	legends:Array<String>,
	title:String,
	options:LegendOptions
}

@:dox(hide) @:noCompletion
private class SetLegend extends Behaviour {
	public override function call(param:Any = null):Variant {
		var chart = cast(_component, Chart);
		var params:LegendAdd = param;
		var options = chart.optionsDS.get(0);
		chart.legend.setOptions(params.options);
		if (params.title == null) {
			params.title = "Groups";
		}
		chart.legend.legendTitle = params.title;
		options.use_legend = true;
		options.used_set_legend = true;
		var groups = new Map();
		for (i => text in params.legends) {
			groups.set(text, i);
			chart.legend.addNode({text: text, color: options.point_color[i]});
		}
		return null;
	}
}

@:dox(hide) @:noCompletion
private class SetAxis extends Behaviour {
	public override function call(param:Any = null):Variant {
		var chart = cast(_component, Chart);
		var options = chart.optionsDS.get(0);
		var y_axis_length = ChartTools.calcAxisLength(chart.height, options.margin);
		var x_axis_length = ChartTools.calcAxisLength(chart.width, options.margin);
		setXAxis(x_axis_length, options, chart);
		setYAxis(y_axis_length, options, chart);
		return null;
	}

	private function setXAxis(x_axis_length:Float, options:Options, chart:Chart) {
		chart.x_axis = new Axis();
		chart.x_axis.is_y = false;
		chart.x_axis.options = options;
		chart.x_axis.setStartToEnd(x_axis_length);
		var minmax = new haxe.ui.geom.Point(chart.min_x, chart.max_x);
		chart.x_axis.setTicks(minmax);
		chart.x_axis.width = chart.width;
		chart.addComponent(chart.x_axis);
	}

	private function setYAxis(y_axis_length:Float, options:Options, chart:Chart) {
		chart.y_axis = new Axis();
		chart.y_axis.is_y = true;
		chart.y_axis.options = options;
		chart.y_axis.setStartToEnd(y_axis_length);
		var minmax = new haxe.ui.geom.Point(chart.min_y, chart.max_y);
		chart.y_axis.setTicks(minmax);
		chart.y_axis.height = chart.height;
		chart.addComponent(chart.y_axis);
	}
}

@:dox(hide) @:noCompletion
private class DrawPoints extends Behaviour {
	public override function call(param:Any = null):Variant {
		var chart = cast(_component, Chart);
		trace(chart.x_tick_info);
		var x_coord_min = chart.x_axis.ticks[0].left;
		var x_coord_max = chart.x_axis.ticks[chart.x_axis.ticks.length - 1].left;
		var x_dist = ChartTools.calcAxisDists(x_coord_min, x_coord_max, chart.x_tick_info.pos_ratio);
		var y_coord_min = chart.y_axis.ticks[0].top;
		var y_coord_max = chart.y_axis.ticks[chart.y_axis.ticks.length - 1].top;
		var y_dist = ChartTools.calcAxisDists(y_coord_max, y_coord_min, chart.y_tick_info.pos_ratio);
		chart.pointlayer.setInfo({
			axis_info: {x_ticks: chart.x_axis.ticks, y_ticks: chart.y_axis.ticks},
			x_dist: x_dist,
			y_dist: y_dist,
			y_tick_info: chart.y_tick_info,
			x_tick_info: chart.x_tick_info
		});
		return null;
	}
}

class Builder extends CompositeBuilder {
	var _chart:Chart;

	public function new(chart:Chart) {
		super(chart);
		_chart = chart;
		_chart.width = 500;
		_chart.height = 500;
		_chart.optionsDS = new ListDataSource();
		_chart.optionsDS.add(new Options());
		_chart.canvas = new Canvas();
		_chart.canvas.width = _chart.width;
		_chart.canvas.height = _chart.height;
		_chart.pointlayer = new PointLayer();
		_chart.pointlayer.width = _chart.width;
		_chart.pointlayer.height = _chart.height;
		_chart.legendLayer = new Absolute();
		_chart.legendLayer.top = _chart.top;
		_chart.legendLayer.left = _chart.left;
		_chart.legendLayer.percentHeight = 100;
		_chart.legendLayer.percentWidth = 100;
		_chart.legendLayer.addClass("legend-layer");
		_chart.addComponent(_chart.legendLayer);
		_chart.legend = new Legend(_chart.optionsDS.get(0));
		_chart.legendLayer.addComponent(_chart.legend);
		_chart.addComponent(_chart.pointlayer);
	}

	override function onReady() {
		var minmax = _chart.sortPoints();
		_chart.setAxis();
		_chart.setTickInfo(minmax);
		_chart.drawPoints();
	}

	override function addComponent(child:Component):Component {
		trace("adding component");
		return super.addComponent(child);
	}
}
