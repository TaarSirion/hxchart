package basics;

import haxe.ui.themes.ThemeManager;
import basics.legend.Legend;
import basics.axis.AxisInfo;
import basics.axis.Axis;
import haxe.ui.events.UIEvent;
import haxe.ui.containers.Absolute;
import basics.Options.Option;
import basics.ChartTools.AxisDist;
import haxe.ui.core.Screen;
import haxe.ui.components.Canvas;
import basics.points.Point;
import basics.axis.AxisTools;

typedef ChartInfo = {
	axis_info:AxisInfo,
	x_tick_info:TickInfo,
	y_tick_info:TickInfo,
	x_dist:AxisDist,
	y_dist:AxisDist,
}

/**
 * Basic `Chart` displaying points on a 2d coordinate system.
 */
class Chart extends Absolute {
	private var canvas:Canvas;

	private var points:Array<Point> = [];

	private var x_tick_info:TickInfo;
	private var y_tick_info:TickInfo;

	private var options:Options;
	private var x_axis:Axis;
	private var y_axis:Axis;
	private var label_layer:Absolute;
	private var legend:Legend;

	/**
	 * [Create a new object of type Chart]
	 * @param top Initial top position of the chart.
	 * @param left Initial left position of the chart.
	 * @param width Initial width of the chart. Will at default use 500px.
	 * @param height Initial height of the chart. Will at default use 500px.
	 */
	public function new(?top:Float, ?left:Float, ?width:Float, ?height:Float) {
		super();
		options = new Options();
		canvas = new Canvas();
		addComponent(canvas);
		label_layer = new Absolute();
		addComponent(label_layer);
		var screen = Screen.instance;
		screen.registerEvent("resize", onResize);
		legend = new Legend(options);
		label_layer.percentHeight = 100;
		label_layer.percentWidth = 100;
		setDimensions(width, height);
		createCanvas(top, left);
	}

	/**
	 * [Set the points to be displayed in the chart]
	 * @param x_points An array of x values the points should have. Beware this will match the first x value to the first y value.
	 * @param y_points An array of y values the points should have. Beware this will match the first x value to the first y value.
	 * @param groups An array of groups the points belong to. Currently this has no effect.
	 */
	public function setPoints(x_points:Array<Float>, y_points:Array<Float>, ?groups:Array<Int>) {
		if (groups == null) {
			groups = [];
			for (i in 0...x_points.length) {
				groups.push(1);
			}
		}
		for (i in 0...x_points.length) {
			points.push(new Point(x_points[i], y_points[i], options, groups[i]));
		}
		var unique_groups = [];
		for (i => val in groups) {
			if (groups.indexOf(val) == i) {
				unique_groups.push(val);
			}
		}
		for (group in unique_groups) {
			legend.addText(group + "");
		}
		setChart();
	}

	private function onResize(e:UIEvent) {
		var screen = Screen.instance;
		setDimensions(screen.width, screen.height);
		createCanvas(top, left);
		setChart();
		canvas.componentGraphics.clear();
		label_layer.removeAllComponents();
		draw();
	}

	private function setChart() {
		sortPoints();
		setAxis();
		setTickInfo();
	}

	private function createCanvas(top:Float, left:Float) {
		canvas.percentWidth = 100;
		canvas.percentHeight = 100;
		canvas.top = top;
		canvas.left = left;
	}

	private function setDimensions(width:Float, height:Float) {
		var screen = Screen.instance;
		this.width = width == null ? 500 : width;
		this.height = height == null ? 500 : height;
	}

	private var min_x:Float;
	private var max_x:Float;
	private var min_y:Float;
	private var max_y:Float;

	private function sortPoints() {
		var x_points = points.map(function(p) {
			return p.x_val;
		});
		var y_points = points.map(function(p) {
			return p.y_val;
		});
		var minmax = ChartTools.sortPoints(x_points, y_points);
		min_x = minmax.min_x;
		max_x = minmax.max_x;
		min_y = minmax.min_y;
		max_y = minmax.max_y;
	}

	/**
	 * [Draw the chart. This will explicitly call the functions for generating the chart.]
	 */
	public function draw() {
		var axis_info = drawAxis();
		drawPoints(axis_info);
		// legend.draw(this);
		return this;
	}

	private function setTickInfo() {
		x_tick_info = AxisTools.calcTickInfo(min_x, max_x);
		y_tick_info = AxisTools.calcTickInfo(min_y, max_y);
	}

	private var margin_bottom:Float = 60;
	private var margin_left:Float = 60;

	private function drawAxis():AxisInfo {
		var x_ticks = drawXAxis();
		var y_ticks = drawYAxis();
		return {
			x_ticks: x_ticks,
			y_ticks: y_ticks
		};
	}

	private function setAxis() {
		var y_axis_length = ChartTools.calcAxisLength(height, options.margin);
		var x_axis_length = ChartTools.calcAxisLength(width, options.margin);
		setXAxis(x_axis_length, y_axis_length);
		setYAxis(x_axis_length, y_axis_length);
	}

	private function setXAxis(x_axis_length:Float, y_axis_length:Float) {
		var x_axis_start = ChartTools.setAxisStartPoint(options.margin, 0, false);
		var x_axis_end = ChartTools.setAxisEndPoint(x_axis_start, x_axis_length, false);
		x_axis = new Axis(x_axis_start, x_axis_end, min_x, max_x, false, options);
	}

	private function setYAxis(x_axis_length:Float, y_axis_length:Float) {
		var y_axis_end = ChartTools.setAxisStartPoint(options.margin, 0, true);
		var y_axis_start = ChartTools.setAxisEndPoint(y_axis_end, y_axis_length, true);
		y_axis = new Axis(y_axis_start, y_axis_end, min_y, max_y, true, options);
	}

	private function drawXAxis() {
		var x_ticks = x_axis.draw(canvas.componentGraphics, y_axis.ticks[y_tick_info.zero].position, label_layer);
		return x_ticks;
	}

	private function drawYAxis() {
		var y_ticks = y_axis.draw(canvas.componentGraphics, x_axis.ticks[x_tick_info.zero].position, label_layer);
		return y_ticks;
	}

	private function drawPoints(axis_info:AxisInfo) {
		var x_coord_min = axis_info.x_ticks[0].position;
		var x_coord_max = axis_info.x_ticks[axis_info.x_ticks.length - 1].position;
		var x_dist = ChartTools.calcAxisDists(x_coord_min, x_coord_max, x_tick_info.pos_ratio);
		var y_coord_min = axis_info.y_ticks[0].position;
		var y_coord_max = axis_info.y_ticks[axis_info.y_ticks.length - 1].position;
		var y_dist = ChartTools.calcAxisDists(y_coord_max, y_coord_min, y_tick_info.pos_ratio);
		for (point in points) {
			point.setPosition({
				axis_info: axis_info,
				x_dist: x_dist,
				y_dist: y_dist,
				y_tick_info: y_tick_info,
				x_tick_info: x_tick_info
			});
			point.draw(canvas.componentGraphics);
		}
	}

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
					if (old_color.toInt() == this.options.point_color.toInt()) {
						this.options.point_color = option.value;
					}
					if (old_color.toInt() == this.options.tick_color.toInt()) {
						this.options.tick_color = option.value;
					}
				case point_size:
					this.options.point_size = option.value;
				case point_color:
					this.options.point_color = option.value;
			}
		}
	}
}