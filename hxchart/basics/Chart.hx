package hxchart.basics;

import hxchart.basics.legend.LegendNode;
import haxe.ui.backend.html5.filters.ColorMatrixFilter;
import haxe.ui.util.Color;
import hxchart.basics.points.PointLayer;
import haxe.ui.geom.Size;
import haxe.ui.core.Component;
import haxe.ui.data.ListDataSource;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.behaviours.Behaviour;
import haxe.ui.util.Variant;
import haxe.ui.data.DataSource;
import haxe.ui.core.CompositeBuilder;
import hxchart.basics.colors.ColorPalettes;
import haxe.ui.styles.StyleSheet;
import hxchart.basics.legend.Legend;
import hxchart.basics.axis.AxisInfo;
import hxchart.basics.axis.Axis;
import haxe.ui.events.UIEvent;
import haxe.ui.containers.Absolute;
import hxchart.basics.ChartTools.AxisDist;
import haxe.ui.core.Screen;
import haxe.ui.components.Canvas;
import hxchart.basics.points.Point;
import hxchart.basics.axis.AxisTools;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;

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
	@:clonable @:behaviour(DefaultBehaviour, 10) public var fontSize:Null<Float>;
	@:clonable @:behaviour(DefaultBehaviour, 8) public var subFontSize:Null<Float>;
	@:clonable @:behaviour(DefaultBehaviour, 7) public var tickLength:Null<Float>;
	@:clonable @:behaviour(DefaultBehaviour, 4) public var subTickLength:Null<Float>;
	@:clonable @:behaviour(DefaultBehaviour, 10) public var tickMargin:Null<Float>;

	@:clonable @:behaviour(ColorPaletteBehaviour) public var colorPalatte:Int;

	public var colors:Array<Int>;

	@:behaviour(CanvasBehaviour) public var canvas:Canvas;

	@:call(SetTickInfo) public function setTickInfo(data:hxchart.basics.ChartTools.ChartMinMax):Void;

	@:call(SetPoints) public function setPoints(data:PointAdd):Void;

	@:call(SetAxis) public function setAxis():Void;

	@:call(DrawPoints) public function drawPoints():Void;

	public var pointlayer:PointLayer;

	public var point_groups(default, set):Map<String, Int>;
	public var countGroups:Int;

	function set_point_groups(point_groups:Map<String, Int>) {
		countGroups = 0;
		for (key in point_groups.keys()) {
			countGroups++;
		}
		return this.point_groups = point_groups;
	}

	public var x_tick_info:TickInfo;
	public var y_tick_info:TickInfo;

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

	private var margin_bottom:Float = 60;
	private var margin_left:Float = 60;
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
private class CanvasBehaviour extends DataBehaviour {
	private override function validateData() {
		if (_component.findComponent(null, Canvas) == null) {
			_component.addComponent(_value);
		}
	}
}

@:dox(hide) @:noCompletion
private class ColorPaletteBehaviour extends DataBehaviour {
	override function set(value:Variant) {
		super.set(value);
		var chart = cast(_component, Chart);
		var bvalue:ColorPaletteEnum = ColorPaletteEnum.createByIndex(value);
		switch (bvalue) {
			case blue:
				chart.colors = ColorPalettes.blue(chart.countGroups);
			case green:
				chart.colors = ColorPalettes.green(chart.countGroups);
			case red:
				chart.colors = ColorPalettes.red(chart.countGroups);
			case grey:
				chart.colors = ColorPalettes.grey(chart.countGroups);
			case blueGreen:
				chart.colors = ColorPalettes.blueGreen(chart.countGroups);
			case pastellBlueGreen:
				chart.colors = ColorPalettes.pastellBlueGreen(chart.countGroups);
			case blueRed:
				chart.colors = ColorPalettes.blueRed(chart.countGroups);
			case pastellBlueRed:
				chart.colors = ColorPalettes.pastellBlueRed(chart.countGroups);
			case greenRed:
				chart.colors = ColorPalettes.greenRed(chart.countGroups);
			case pastellGreenRed:
				chart.colors = ColorPalettes.pastellGreenRed(chart.countGroups);
			default:
				chart.colors = ColorPalettes.defaultColors(chart.countGroups);
		}
	}

	private override function validateData() {
		super.validateData();
		var chart = cast(_component, Chart);
		for (point in chart.pointlayer.points) {
			point.color = chart.colors[point.group];
		}
		for (i => node in chart.legend.childNodes) {
			if (i == 0) {
				continue;
			}
			node.color = chart.colors[i - 1];
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
		trace(chart.x_axis.ticks[infos.x.zero].num);
		trace(chart.y_axis.ticks[infos.y.zero].num);
		chart.y_axis.left = chart.x_axis.ticks[infos.x.zero].left;
		chart.y_axis.width = 30;
		chart.x_axis.top = chart.y_axis.ticks[infos.y.zero].top;
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
		chart.countGroups = j;
		if (chart.colorPalatte == null) {
			chart.colors = ColorPalettes.defaultColors(chart.countGroups);
		}
		for (i in 0...params.x_points.length) {
			var point = new Point(params.x_points[i], params.y_points[i], chart.point_groups.get(params.groups[i]));
			point.color = chart.colors[point.group];
			chart.pointlayer.addPoint(point);
		}

		return chart;
	}
}

@:dox(hide) @:noCompletion
private class SetAxis extends Behaviour {
	public override function call(param:Any = null):Variant {
		var chart = cast(_component, Chart);
		var y_axis_length = ChartTools.calcAxisLength(chart.height, chart.marginTop, chart.marginBottom);
		var x_axis_length = ChartTools.calcAxisLength(chart.width, chart.marginLeft, chart.marginRight);
		setXAxis(x_axis_length, chart);
		setYAxis(y_axis_length, chart);
		return null;
	}

	private function setXAxis(x_axis_length:Float, chart:Chart) {
		chart.x_axis = new Axis();
		chart.x_axis.is_y = false;
		chart.x_axis.setStartToEnd(x_axis_length, chart.marginLeft);
		var minmax = new haxe.ui.geom.Point(chart.min_x, chart.max_x);
		chart.x_axis.setTicks(minmax);
		chart.x_axis.width = chart.width;
		chart.addComponent(chart.x_axis);
	}

	private function setYAxis(y_axis_length:Float, chart:Chart) {
		chart.y_axis = new Axis();
		chart.y_axis.is_y = true;
		chart.y_axis.setStartToEnd(y_axis_length, chart.marginTop);
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
		_chart.canvas = new Canvas();
		_chart.canvas.width = _chart.width;
		_chart.canvas.height = _chart.height;
		_chart.pointlayer = new PointLayer();
		_chart.pointlayer.percentHeight = 100;
		_chart.pointlayer.percentWidth = 100;
		_chart.legendLayer = new Absolute();
		_chart.legendLayer.top = _chart.top;
		_chart.legendLayer.left = _chart.left;
		_chart.legendLayer.percentHeight = 100;
		_chart.legendLayer.percentWidth = 100;
		_chart.legendLayer.addClass("legend-layer");
		_chart.addComponent(_chart.legendLayer);
		_chart.addComponent(_chart.pointlayer);
	}

	override function onReady() {
		var minmax = _chart.sortPoints();
		_chart.setAxis();
		_chart.setTickInfo(minmax);
		_chart.drawPoints();
	}

	override function addComponent(child:Component):Component {
		if (child is Legend) {
			var legend = cast(child, Legend);
			setLegend(legend);
			_chart.legend = legend;
			return _chart.legendLayer.addComponent(legend);
		} else {
			return super.addComponent(child);
		}
	}

	override function validateComponentData() {
		super.validateComponentData();
	}

	function setLegend(legend:Legend) {
		var groups = new Map();
		for (i => text in legend.legendTexts) {
			groups.set(text, i);
			legend.colors.push(_chart.colors[i]);
		}
	}
}
