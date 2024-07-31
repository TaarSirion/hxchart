package hxchart.basics;

import hxchart.basics.ticks.Ticks.CompassOrientation;
import hxchart.basics.axis.NumericTickInfo;
import hxchart.basics.legend.LegendNode;
import haxe.ui.backend.html5.filters.ColorMatrixFilter;
import haxe.ui.util.Color;
import hxchart.basics.points.Points;
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
	x_tick_info:NumericTickInfo,
	y_tick_info:NumericTickInfo,
	x_dist:AxisDist,
	y_dist:AxisDist,
}

typedef TickInfos = {
	x:NumericTickInfo,
	y:NumericTickInfo,
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

	@:call(SetTickInfo) public function setTickInfo(data:hxchart.basics.ChartTools.ChartMinMax):Void;

	@:call(SetPoints) public function setPoints(data:PointAdd):Void;

	@:call(SetAxis) public function setAxis():Void;

	@:call(DrawPoints) public function drawPoints():Void;

	public var pointlayer:Absolute;
	public var points:Points;

	public var point_groups(default, set):Map<String, Int>;
	public var countGroups:Int;

	function set_point_groups(point_groups:Map<String, Int>) {
		countGroups = 0;
		for (key in point_groups.keys()) {
			countGroups++;
		}
		return this.point_groups = point_groups;
	}

	public var x_tick_info:NumericTickInfo;
	public var y_tick_info:NumericTickInfo;

	public var x_axis:Axis;
	public var y_axis:Axis;
	public var axisLayer(default, set):Absolute;

	function set_axisLayer(layer:Absolute) {
		return axisLayer = layer;
	}

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
		var minmax = points.sortPoints();
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
private class ColorPaletteBehaviour extends DataBehaviour {
	override function set(value:Variant) {
		super.set(value);
		var chart = cast(_component, Chart);
		var bvalue:ColorPaletteEnum = ColorPaletteEnum.createByIndex(value);
		switch (bvalue) {
			case normal:
				chart.colors = ColorPalettes.defaultColors(chart.countGroups);
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
		for (point in chart.points.points) {
			point.color = chart.colors[point.group];
		}
		for (i => node in chart.legend.childNodes) {
			node.color = chart.colors[i];
		}
	}
}

@:dox(hide) @:noCompletion
private class SetTickInfo extends Behaviour {
	public override function call(param:Any = null):Variant {
		var pointInfo:hxchart.basics.ChartTools.ChartMinMax = param;
		var chart = cast(_component, Chart);
		chart.x_tick_info = new NumericTickInfo(pointInfo.min_x, pointInfo.max_x);
		chart.y_tick_info = new NumericTickInfo(pointInfo.min_y, pointInfo.max_y);
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
			chart.points.addPoint(point);
		}

		return chart;
	}
}

@:dox(hide) @:noCompletion
private class SetAxis extends Behaviour {
	public override function call(param:Any = null):Variant {
		var chart = cast(_component, Chart);
		var y_axis_length = ChartTools.calcAxisLength(chart.axisLayer.height, chart.marginTop, chart.marginBottom);
		var x_axis_length = ChartTools.calcAxisLength(chart.axisLayer.width, chart.marginLeft, chart.marginRight);
		var chartPoint = new haxe.ui.geom.Point(chart.marginLeft, chart.marginTop);
		chart.x_axis = new Axis(chartPoint, 0, x_axis_length, chart.x_tick_info, "xaxis");
		chart.x_axis.width = x_axis_length;
		chart.x_axis.height = y_axis_length;
		chart.y_axis = new Axis(chartPoint, 90, y_axis_length, chart.y_tick_info, "yaxis");
		chart.y_axis.width = x_axis_length;
		chart.y_axis.height = y_axis_length;
		// This is necessary to allow the ticks to be calculated
		chart.x_axis.startPoint = new haxe.ui.geom.Point(0, 40);
		chart.y_axis.startPoint = new haxe.ui.geom.Point(40, 0);
		// Real positioning
		chart.x_axis.startPoint = new haxe.ui.geom.Point(0, chart.y_axis.ticks[chart.y_tick_info.zeroIndex].top);
		chart.y_axis.startPoint = new haxe.ui.geom.Point(chart.x_axis.ticks[chart.x_tick_info.zeroIndex].left, 0);

		chart.y_axis.showZeroTick = false;
		chart.x_axis.zeroTickPosition = CompassOrientation.SE;

		var xComponent:Absolute = chart.axisLayer.findComponent("xaxis");
		if (xComponent == null) {
			chart.axisLayer.addComponent(chart.x_axis);
		} else {
			chart.axisLayer.removeComponent(xComponent);
			chart.axisLayer.addComponent(chart.x_axis);
		}
		var yComponent:Absolute = chart.axisLayer.findComponent("yaxis");
		if (yComponent == null) {
			chart.axisLayer.addComponent(chart.y_axis);
		} else {
			chart.axisLayer.removeComponent(yComponent);
			chart.axisLayer.addComponent(chart.y_axis);
		}
		return null;
	}
}

@:dox(hide) @:noCompletion
private class DrawPoints extends Behaviour {
	public override function call(param:Any = null):Variant {
		var chart = cast(_component, Chart);
		var x_coord_min = chart.x_axis.ticks[0].left;
		var x_coord_max = chart.x_axis.ticks[chart.x_axis.ticks.length - 1].left;
		var ratio = 1 - chart.x_tick_info.negNum / chart.x_tick_info.tickNum;
		var x_dist = ChartTools.calcAxisDists(x_coord_min, x_coord_max, ratio);
		var y_coord_min = chart.y_axis.ticks[0].top;
		var y_coord_max = chart.y_axis.ticks[chart.y_axis.ticks.length - 1].top;
		var ratio = 1 - chart.y_tick_info.negNum / chart.y_tick_info.tickNum;
		var y_dist = ChartTools.calcAxisDists(y_coord_max, y_coord_min, ratio);
		chart.points.setInfo({
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
		_chart.pointlayer = new Absolute();
		_chart.pointlayer.percentHeight = 100;
		_chart.pointlayer.percentWidth = 100;
		_chart.legendLayer = new Absolute();
		_chart.legendLayer.top = _chart.top;
		_chart.legendLayer.left = _chart.left;
		_chart.legendLayer.percentHeight = 100;
		_chart.legendLayer.percentWidth = 100;
		_chart.legendLayer.addClass("legend-layer");
		_chart.axisLayer = new Absolute();
		_chart.axisLayer.percentHeight = 100;
		_chart.axisLayer.percentWidth = 100;
		_chart.addComponent(_chart.legendLayer);
		_chart.addComponent(_chart.pointlayer);
		_chart.addComponent(_chart.axisLayer);
		_chart.points = new Points();
		_chart.points.percentHeight = 100;
		_chart.points.percentWidth = 100;
		_chart.pointlayer.addComponent(_chart.points);
	}

	override function onReady() {
		// var minmax = _chart.sortPoints();
		// _chart.setTickInfo(minmax);
		// _chart.setAxis();
		// _chart.drawPoints();
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
		setLayerPosition();
		var minmax = _chart.sortPoints();
		_chart.setTickInfo(minmax);
		_chart.setAxis();
	}

	function setLegend(legend:Legend) {
		var groups = new Map();
		for (i => text in legend.legendTexts) {
			groups.set(text, i);
		}
	}

	function setLayerPosition() {
		var legend = cast(_chart.legend, Legend);
		var minWidth:Int = 50;
		var minPercent:Int = 10;
		var maxPercent:Int = 100 - minPercent;
		_chart.legendLayer.percentHeight = 100;
		_chart.legendLayer.percentWidth = 100;
		_chart.pointlayer.percentHeight = 100;
		_chart.pointlayer.percentWidth = 100;
		_chart.axisLayer.percentHeight = 100;
		_chart.axisLayer.percentWidth = 100;
		if (legend == null) {
			_chart.pointlayer.percentHeight = 100;
			_chart.pointlayer.top = 0;
			_chart.axisLayer.percentHeight = 100;
			_chart.axisLayer.top = 0;
			return;
		}

		if (legend.align <= 1) {
			_chart.legendLayer.percentWidth = minPercent;
			_chart.pointlayer.percentWidth = maxPercent;
			_chart.axisLayer.percentWidth = maxPercent;
			var percent = (minWidth / _chart.width) * 100;
			if (percent > minPercent) {
				_chart.legendLayer.percentWidth = percent;
				_chart.pointlayer.percentWidth = 100 - percent;
				_chart.axisLayer.percentWidth = 100 - percent;
			}
			_chart.legendLayer.left = 0;
			_chart.pointlayer.left = _chart.legendLayer.width;
			_chart.axisLayer.left = _chart.legendLayer.width;
			if (legend.align == 1) {
				_chart.pointlayer.left = 0;
				_chart.axisLayer.left = 0;
				_chart.legendLayer.left = _chart.pointlayer.width;
			}
			trace(_chart.legendLayer.left);
		} else {
			_chart.legendLayer.percentHeight = minPercent;
			_chart.pointlayer.percentHeight = maxPercent;
			_chart.legendLayer.top = 0;
			_chart.pointlayer.top = _chart.legendLayer.height;
			_chart.axisLayer.top = _chart.legendLayer.height;
			_chart.axisLayer.percentHeight = maxPercent;
			if (legend.align == 3) {
				_chart.pointlayer.left = 0;
				_chart.axisLayer.left = 0;
				_chart.legendLayer.left = _chart.pointlayer.height;
			}
		}
	}
}
