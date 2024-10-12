// package hxchart.basics.pointchart;
// import hxchart.basics.data.DataLayer;
// import hxchart.basics.data.Data2D;
// import hxchart.basics.axis.AxisLayer;
// import hxchart.basics.axis.TickInfo;
// import hxchart.basics.axis.StringTickInfo;
// import haxe.ui.styles.Style;
// import hxchart.basics.ticks.Ticks;
// import hxchart.basics.ticks.Ticks.CompassOrientation;
// import hxchart.basics.axis.NumericTickInfo;
// import hxchart.basics.legend.LegendNode;
// import haxe.ui.backend.html5.filters.ColorMatrixFilter;
// import haxe.ui.util.Color;
// import haxe.ui.geom.Size;
// import haxe.ui.core.Component;
// import haxe.ui.data.ListDataSource;
// import haxe.ui.layouts.DefaultLayout;
// import haxe.ui.behaviours.Behaviour;
// import haxe.ui.util.Variant;
// import haxe.ui.data.DataSource;
// import haxe.ui.core.CompositeBuilder;
// import hxchart.basics.colors.ColorPalettes;
// import haxe.ui.styles.StyleSheet;
// import hxchart.basics.legend.Legend;
// import hxchart.basics.axis.AxisInfo;
// import hxchart.basics.axis.Axis;
// import haxe.ui.events.UIEvent;
// import haxe.ui.containers.Absolute;
// import hxchart.basics.pointchart.ChartTools.AxisDist;
// import haxe.ui.core.Screen;
// import haxe.ui.components.Canvas;
// import hxchart.basics.axis.AxisTools;
// import haxe.ui.behaviours.DataBehaviour;
// import haxe.ui.behaviours.DefaultBehaviour;
// /**
//  * Basic `Point-Chart` displaying points on a 2d coordinate system.
//  */
// @:composite(Builder, ChartLayout)
// class Scatter extends Absolute implements AxisLayer implements DataLayer {
// 	@:clonable @:behaviour(DefaultBehaviour, 10) public var fontSize:Null<Float>;
// 	@:clonable @:behaviour(DefaultBehaviour, 8) public var subFontSize:Null<Float>;
// 	@:clonable @:behaviour(DefaultBehaviour, 7) public var tickLength:Null<Float>;
// 	@:clonable @:behaviour(DefaultBehaviour, 4) public var subTickLength:Null<Float>;
// 	@:clonable @:behaviour(DefaultBehaviour, 10) public var tickMargin:Null<Float>;
// 	@:clonable @:behaviour(ColorPaletteBehaviour) public var colorPalatte:Int;
// 	public var colors:Array<Int>;
// 	// @:call(SetTickInfo) public function setTickInfo():Void;
// 	@:call(SetPoints) public function addData(data:AddDataType):Void;
// 	@:call(SetAxis) public function positionAxes(data:Array<Data2D>):Void;
// 	public function styleAxes() {}
// 	@:call(DrawPoints) public function positionData():Void;
// 	public var dataLayer:Absolute;
// 	public var dataCanvas:Canvas;
// 	public var data:Array<Data2D> = [];
// 	public var point_groups(default, set):Map<String, Int>;
// 	public var countGroups:Int;
// 	function set_point_groups(point_groups:Map<String, Int>) {
// 		countGroups = 0;
// 		for (key in point_groups.keys()) {
// 			countGroups++;
// 		}
// 		return this.point_groups = point_groups;
// 	}
// 	public var axes:Array<Axis> = [];
// 	public var tickInfos:Array<TickInfo> = [];
// 	public var axisPaddingT:Float = 0;
// 	public var axisPaddingL:Float = 0;
// 	public var axisPaddingR:Float = 0;
// 	public var axisPaddingB:Float = 0;
// 	public var axisLayer(default, set):Absolute;
// 	function set_axisLayer(layer:Absolute) {
// 		return axisLayer = layer;
// 	}
// 	public var legendLayer(default, set):Absolute;
// 	function set_legendLayer(legendLayer:Absolute) {
// 		return this.legendLayer = legendLayer;
// 	}
// 	public var legend(default, set):Legend;
// 	function set_legend(legend:Legend) {
// 		return this.legend = legend;
// 	}
// 	private var init_top:Float = 0;
// 	private var init_left:Float = 0;
// 	public var chartPoint:haxe.ui.geom.Point;
// 	override function set_padding(value:Null<Float>):Null<Float> {
// 		dataLayer.top = value;
// 		dataLayer.left = value;
// 		dataLayer.width -= 2 * value;
// 		dataLayer.height -= 2 * value;
// 		axisPaddingL = value;
// 		axisPaddingT = value;
// 		axisPaddingB = value;
// 		axisPaddingR = value;
// 		chartPoint.x = value;
// 		chartPoint.y = value;
// 		return super.set_padding(0);
// 	}
// 	override function set_paddingBottom(value:Null<Float>):Null<Float> {
// 		axisPaddingB = value;
// 		return super.set_paddingBottom(0);
// 	}
// 	override function set_paddingLeft(value:Null<Float>):Null<Float> {
// 		axisPaddingL = value;
// 		dataLayer.left = value;
// 		chartPoint.x = value;
// 		return super.set_paddingLeft(0);
// 	}
// 	override function set_paddingRight(value:Null<Float>):Null<Float> {
// 		axisPaddingR = value;
// 		return super.set_paddingRight(0);
// 	}
// 	override function set_paddingTop(value:Null<Float>):Null<Float> {
// 		axisPaddingT = value;
// 		dataLayer.top = value;
// 		chartPoint.y = value;
// 		return super.set_paddingTop(0);
// 	}
// 	/**
// 	 * [Create a new object of type Chart]
// 	 * @param top Initial top position of the chart.
// 	 * @param left Initial left position of the chart.
// 	 * @param width Initial width of the chart. Will at default use 500px.
// 	 * @param height Initial height of the chart. Will at default use 500px.
// 	 */
// 	public function new() {
// 		super();
// 		chartPoint = new haxe.ui.geom.Point(0, 0);
// 	}
// 	private var init_width:Float = 0;
// 	private var init_height:Float = 0;
// 	private function setDimensions(width:Float, height:Float) {
// 		var screen = Screen.instance;
// 		this.width = width == null ? screen.width : width;
// 		this.height = height == null ? 500 : height;
// 		if (init_width == 0) {
// 			init_width = this.width;
// 		}
// 		if (init_height == 0) {
// 			init_height = this.height;
// 		}
// 	}
// 	public var min_x:Float;
// 	public var max_x:Float;
// 	public var min_y:Float;
// 	public var max_y:Float;
// 	public function sortPoints() {
// 		var xVals = data.map(x -> {
// 			return x.xValue;
// 		});
// 		var yVals = data.map(x -> {
// 			return x.yValue;
// 		});
// 		if (xVals[0] is Float) {
// 			xVals.sort(Reflect.compare);
// 			min_x = xVals[0];
// 			max_x = xVals[xVals.length - 1];
// 		}
// 		if (yVals[0] is Float) {
// 			yVals.sort(Reflect.compare);
// 			min_y = yVals[0];
// 			max_y = yVals[yVals.length - 1];
// 		}
// 		return null;
// 	}
// 	private var margin_bottom:Float = 60;
// 	private var margin_left:Float = 60;
// }
// @:dox(hide) @:noCompletion
// private class ChartLayout extends DefaultLayout {}
// @:dox(hide) @:noCompletion
// private class ColorPaletteBehaviour extends DataBehaviour {
// 	override function set(value:Variant) {
// 		super.set(value);
// 		var chart = cast(_component, Scatter);
// 		var bvalue:ColorPaletteEnum = ColorPaletteEnum.createByIndex(value);
// 		switch (bvalue) {
// 			case normal:
// 				chart.colors = ColorPalettes.defaultColors(chart.countGroups);
// 			case blue:
// 				chart.colors = ColorPalettes.blue(chart.countGroups);
// 			case green:
// 				chart.colors = ColorPalettes.green(chart.countGroups);
// 			case red:
// 				chart.colors = ColorPalettes.red(chart.countGroups);
// 			case grey:
// 				chart.colors = ColorPalettes.grey(chart.countGroups);
// 			case blueGreen:
// 				chart.colors = ColorPalettes.blueGreen(chart.countGroups);
// 			case pastellBlueGreen:
// 				chart.colors = ColorPalettes.pastellBlueGreen(chart.countGroups);
// 			case blueRed:
// 				chart.colors = ColorPalettes.blueRed(chart.countGroups);
// 			case pastellBlueRed:
// 				chart.colors = ColorPalettes.pastellBlueRed(chart.countGroups);
// 			case greenRed:
// 				chart.colors = ColorPalettes.greenRed(chart.countGroups);
// 			case pastellGreenRed:
// 				chart.colors = ColorPalettes.pastellGreenRed(chart.countGroups);
// 			default:
// 				chart.colors = ColorPalettes.defaultColors(chart.countGroups);
// 		}
// 	}
// 	private override function validateData() {
// 		super.validateData();
// 		var chart = cast(_component, Scatter);
// 		for (data in chart.data) {
// 			// point.color = chart.colors[point.group];
// 		}
// 		for (i => node in chart.legend.childNodes) {
// 			node.color = chart.colors[i];
// 		}
// 	}
// }
// // @:dox(hide) @:noCompletion
// // private class SetTickInfo extends Behaviour {
// // 	public override function call(param:Any = null):Variant {
// // 		var chart = cast(_component, Chart);
// // 		if (chart.min_x != null && chart.max_x != null) {
// // 			chart.x_tick_info = new NumericTickInfo(chart.min_x, chart.max_x);
// // 		} else {
// // 			var xVals = chart.data.map(x -> {
// // 				return x.xValue;
// // 			});
// // 			chart.x_tick_info = new StringTickInfo(xVals);
// // 		}
// // 		if (chart.min_y != null && chart.max_y != null) {
// // 			chart.y_tick_info = new NumericTickInfo(chart.min_y, chart.max_y);
// // 		} else {
// // 			var yVals = chart.data.map(x -> {
// // 				return x.yValue;
// // 			});
// // 			chart.y_tick_info = new StringTickInfo(yVals);
// // 		}
// // 		return chart;
// // 	}
// // }
// typedef PointAdd = {
// 	x_points:Array<Dynamic>,
// 	y_points:Array<Dynamic>,
// 	?groups:Array<String>
// }
// @:dox(hide) @:noCompletion
// private class SetPoints extends Behaviour {
// 	public override function call(param:Any = null):Variant {
// 		var chart = cast(_component, Scatter);
// 		var params:AddDataType = param;
// 		if (params.groups == null) {
// 			params.groups = [];
// 			for (i in 0...params.xValues.length) {
// 				params.groups.push("1");
// 			}
// 		}
// 		var j = 0;
// 		chart.point_groups = new Map();
// 		for (i => val in params.groups) {
// 			if (params.groups.indexOf(val) == i) {
// 				chart.point_groups.set(val, j);
// 				j++;
// 			}
// 		}
// 		chart.countGroups = j;
// 		if (chart.colorPalatte == null) {
// 			chart.colors = ColorPalettes.defaultColors(chart.countGroups);
// 		}
// 		for (i in 0...params.xValues.length) {
// 			var point = new Data2D(params.xValues[i], params.yValues[i], chart.point_groups.get(params.groups[i]));
// 			// point.color = chart.colors[point.group];
// 			chart.data.push(point);
// 		}
// 		return chart;
// 	}
// }
// @:dox(hide) @:noCompletion
// private class SetAxis extends Behaviour {
// 	public override function call(param:Any = null):Variant {
// 		trace(param);
// 		var chart = cast(_component, Scatter);
// 		chart.tickInfos = [];
// 		chart.axes = [];
// 		if (chart.min_x != null && chart.max_x != null) {
// 			chart.tickInfos.push(new NumericTickInfo(chart.min_x, chart.max_x));
// 		} else {
// 			var xVals = chart.data.map(x -> {
// 				return x.xValue;
// 			});
// 			chart.tickInfos.push(new StringTickInfo(xVals));
// 		}
// 		if (chart.min_y != null && chart.max_y != null) {
// 			chart.tickInfos.push(new NumericTickInfo(chart.min_y, chart.max_y));
// 		} else {
// 			var yVals = chart.data.map(x -> {
// 				return x.yValue;
// 			});
// 			chart.tickInfos.push(new StringTickInfo(yVals));
// 		}
// 		var y_axis_length = chart.axisLayer.height - chart.axisPaddingT - chart.axisPaddingB;
// 		var x_axis_length = chart.axisLayer.width - chart.axisPaddingL - chart.axisPaddingR;
// 		chart.axes.push(new Axis(chart.chartPoint, 0, x_axis_length, chart.tickInfos[0], "xaxis"));
// 		chart.axes[0].width = x_axis_length;
// 		chart.axes[0].height = y_axis_length;
// 		chart.axes.push(new Axis(chart.chartPoint, 270, y_axis_length, chart.tickInfos[1], "yaxis"));
// 		chart.axes[1].width = x_axis_length;
// 		chart.axes[1].height = y_axis_length;
// 		// This is necessary to allow the ticks to be calculated
// 		chart.axes[0].startPoint = new haxe.ui.geom.Point(0, 40);
// 		chart.axes[1].startPoint = new haxe.ui.geom.Point(40, y_axis_length);
// 		// Real positioning
// 		chart.axes[0].startPoint = new haxe.ui.geom.Point(0, chart.axes[1].ticks[chart.tickInfos[1].zeroIndex].top);
// 		chart.axes[1].startPoint = new haxe.ui.geom.Point(chart.axes[0].ticks[chart.tickInfos[0].zeroIndex].left, y_axis_length);
// 		chart.axes[1].showZeroTick = false;
// 		chart.axes[0].zeroTickPosition = CompassOrientation.SW;
// 		var xComponent:Absolute = chart.axisLayer.findComponent("xaxis");
// 		if (xComponent == null) {
// 			chart.axisLayer.addComponent(chart.axes[0]);
// 		} else {
// 			chart.axisLayer.removeComponent(xComponent);
// 			chart.axisLayer.addComponent(chart.axes[0]);
// 		}
// 		var yComponent:Absolute = chart.axisLayer.findComponent("yaxis");
// 		if (yComponent == null) {
// 			chart.axisLayer.addComponent(chart.axes[1]);
// 		} else {
// 			chart.axisLayer.removeComponent(yComponent);
// 			chart.axisLayer.addComponent(chart.axes[1]);
// 		}
// 		return null;
// 	}
// }
// @:dox(hide) @:noCompletion
// private class DrawPoints extends Behaviour {
// 	public override function call(param:Any = null):Variant {
// 		var chart = cast(_component, Scatter);
// 		if (chart.tickInfos.length < 2 || chart.tickInfos[0] == null || chart.tickInfos[1] == null) {
// 			return null;
// 		}
// 		chart.dataLayer.width = chart.dataLayer.width - chart.axisPaddingL - chart.axisPaddingR;
// 		chart.dataLayer.height = chart.dataLayer.height - chart.axisPaddingT - chart.axisPaddingB;
// 		var x_coord_min = chart.axes[0].ticks[0].left;
// 		var x_coord_max = chart.axes[0].ticks[chart.axes[0].ticks.length - 1].left;
// 		var ratio = 1.0;
// 		if (chart.tickInfos[0] is NumericTickInfo) {
// 			var tickInfo:NumericTickInfo = cast(chart.tickInfos[0], NumericTickInfo);
// 			ratio = 1 - tickInfo.negNum / (tickInfo.tickNum - 1);
// 		}
// 		var x_dist = ChartTools.calcAxisDists(x_coord_min, x_coord_max, ratio);
// 		var y_coord_min = chart.axes[1].ticks[0].top;
// 		var y_coord_max = chart.axes[1].ticks[chart.axes[1].ticks.length - 1].top;
// 		ratio = 1.0;
// 		if (chart.tickInfos[1] is NumericTickInfo) {
// 			var tickInfo:NumericTickInfo = cast(chart.tickInfos[1], NumericTickInfo);
// 			ratio = 1 - tickInfo.negNum / (tickInfo.tickNum - 1);
// 		}
// 		var y_dist = ChartTools.calcAxisDists(y_coord_max, y_coord_min, ratio);
// 		for (data in chart.data) {
// 			var x = calcXCoord(data.xValue, chart.axes[0].ticks, chart.axes[0].ticks[chart.tickInfos[0].zeroIndex].left, x_dist);
// 			var y = calcYCoord(data.yValue, chart.axes[1].ticks, chart.axes[1].ticks[chart.tickInfos[1].zeroIndex].top, y_dist);
// 			chart.dataCanvas.componentGraphics.strokeStyle("black", 1);
// 			chart.dataCanvas.componentGraphics.circle(x, y, 1);
// 		}
// 		return null;
// 	}
// 	public function calcXCoord(xValue:Dynamic, ticks:Array<Ticks>, zeroPos:Float, xDist:AxisDist) {
// 		if (xValue is String) {
// 			var ticksFiltered = ticks.filter(x -> {
// 				return x.text == xValue;
// 			});
// 			return ticksFiltered[0].left;
// 		}
// 		var xMax = Std.parseFloat(ticks[ticks.length - 1].text);
// 		var xMin = Std.parseFloat(ticks[0].text);
// 		var x_ratio = xValue / xMax;
// 		var x = zeroPos + xDist.pos_dist * x_ratio;
// 		if (xValue < 0) {
// 			x_ratio = xValue / xMin;
// 			x = zeroPos - xDist.neg_dist * x_ratio;
// 		}
// 		return x;
// 	}
// 	public function calcYCoord(yValue:Dynamic, ticks:Array<Ticks>, zeroPos:Float, yDist:AxisDist) {
// 		if (yValue is String) {
// 			var ticksFiltered = ticks.filter(x -> {
// 				return x.text == yValue;
// 			});
// 			return ticksFiltered[0].top;
// 		}
// 		var yMax = Std.parseFloat(ticks[ticks.length - 1].text);
// 		var yMin = Std.parseFloat(ticks[0].text);
// 		var y_ratio = yValue / yMax;
// 		var y = zeroPos - yDist.pos_dist * y_ratio;
// 		if (yValue < 0) {
// 			y_ratio = yValue / yMin;
// 			y = zeroPos + yDist.neg_dist * y_ratio;
// 		}
// 		return y;
// 	}
// }
// class Builder extends CompositeBuilder {
// 	var _chart:Scatter;
// 	public function new(chart:Scatter) {
// 		super(chart);
// 		_chart = chart;
// 		_chart.width = 500;
// 		_chart.height = 500;
// 		_chart.backgroundColor = Color.fromString("#E5E5EB");
// 		_chart.borderSize = 1;
// 		_chart.borderColor = Color.fromString("black");
// 		_chart.borderRadius = 0;
// 		_chart.dataLayer = new Absolute();
// 		_chart.dataLayer.percentHeight = 100;
// 		_chart.dataLayer.percentWidth = 100;
// 		_chart.dataLayer.left = 0;
// 		_chart.dataLayer.top = 0;
// 		_chart.dataLayer.borderColor = Color.fromString("black");
// 		_chart.dataLayer.borderSize = 1;
// 		_chart.dataLayer.borderRadius = 0;
// 		_chart.dataLayer.backgroundColor = Color.fromString("#F8F8FC");
// 		// _chart.legendLayer = new Absolute();
// 		// _chart.legendLayer.top = _chart.top;
// 		// _chart.legendLayer.left = _chart.left;
// 		// _chart.legendLayer.percentHeight = 100;
// 		// _chart.legendLayer.percentWidth = 100;
// 		// _chart.legendLayer.addClass("legend-layer");
// 		_chart.axisLayer = new Absolute();
// 		_chart.axisLayer.percentHeight = 100;
// 		_chart.axisLayer.percentWidth = 100;
// 		_chart.addComponent(_chart.legendLayer);
// 		_chart.addComponent(_chart.dataLayer);
// 		_chart.addComponent(_chart.axisLayer);
// 		_chart.dataCanvas = new Canvas();
// 		_chart.dataCanvas.percentHeight = 100;
// 		_chart.dataCanvas.percentWidth = 100;
// 		_chart.dataLayer.addComponent(_chart.dataCanvas);
// 	}
// 	override function onReady() {}
// 	override function addComponent(child:Component):Component {
// 		if (child is Legend) {
// 			var legend = cast(child, Legend);
// 			setLegend(legend);
// 			_chart.legend = legend;
// 			return _chart.legendLayer.addComponent(legend);
// 		} else {
// 			return super.addComponent(child);
// 		}
// 	}
// 	override function applyStyle(style:Style) {
// 		super.applyStyle(style);
// 		// It seems that margin does not get applied.
// 		_chart.left = _chart.left + _chart.marginLeft;
// 		_chart.top = _chart.top + _chart.marginTop;
// 		_chart.width = _chart.width - _chart.marginRight;
// 		_chart.height = _chart.height - _chart.marginBottom;
// 	}
// 	override function validateComponentData() {
// 		super.validateComponentData();
// 		// setLayerPosition();
// 		_chart.sortPoints();
// 		_chart.positionAxes(_chart.data);
// 		_chart.positionData();
// 	}
// 	function setLegend(legend:Legend) {
// 		var groups = new Map();
// 		for (i => text in legend.legendTexts) {
// 			groups.set(text, i);
// 		}
// 	}
// 	function setLayerPosition() {
// 		var legend = cast(_chart.legend, Legend);
// 		var minWidth:Int = 50;
// 		var minPercent:Int = 10;
// 		var maxPercent:Int = 100 - minPercent;
// 		_chart.legendLayer.percentHeight = 100;
// 		_chart.legendLayer.percentWidth = 100;
// 		_chart.dataLayer.percentHeight = 100;
// 		_chart.dataLayer.percentWidth = 100;
// 		_chart.axisLayer.percentHeight = 100;
// 		_chart.axisLayer.percentWidth = 100;
// 		if (legend == null) {
// 			_chart.dataLayer.percentHeight = 100;
// 			_chart.dataLayer.top = 0;
// 			_chart.axisLayer.percentHeight = 100;
// 			_chart.axisLayer.top = 0;
// 			return;
// 		}
// 		if (legend.align <= 1) {
// 			_chart.legendLayer.percentWidth = minPercent;
// 			_chart.dataLayer.percentWidth = maxPercent;
// 			_chart.axisLayer.percentWidth = maxPercent;
// 			var percent = (minWidth / _chart.width) * 100;
// 			if (percent > minPercent) {
// 				_chart.legendLayer.percentWidth = percent;
// 				_chart.dataLayer.percentWidth = 100 - percent;
// 				_chart.axisLayer.percentWidth = 100 - percent;
// 			}
// 			_chart.legendLayer.left = 0;
// 			_chart.dataLayer.left = _chart.legendLayer.width;
// 			_chart.axisLayer.left = _chart.legendLayer.width;
// 			if (legend.align == 1) {
// 				_chart.dataLayer.left = 0;
// 				_chart.dataLayer.top = 0;
// 				_chart.axisLayer.left = 0;
// 				_chart.legendLayer.left = _chart.dataLayer.width;
// 			}
// 		} else {
// 			_chart.legendLayer.percentHeight = minPercent;
// 			_chart.dataLayer.percentHeight = maxPercent;
// 			_chart.legendLayer.top = 0;
// 			_chart.dataLayer.top = _chart.legendLayer.height;
// 			_chart.axisLayer.top = _chart.legendLayer.height;
// 			_chart.axisLayer.percentHeight = maxPercent;
// 			if (legend.align == 3) {
// 				_chart.dataLayer.left = 0;
// 				_chart.axisLayer.left = 0;
// 				_chart.legendLayer.left = _chart.dataLayer.height;
// 			}
// 		}
// 	}
// }
