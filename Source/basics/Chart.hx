package basics;

import basics.Options.Option;
import basics.AxisInfo.TickInfo;
import haxe.ui.containers.VBox;
import basics.AxisInfo.AxisDist;
import basics.ticks.Ticks;
import haxe.ui.graphics.ComponentGraphics;
import haxe.ui.Toolkit;
import haxe.ui.core.Screen;
import haxe.ui.core.Component;
import haxe.ui.util.Color;
import haxe.ui.components.Canvas;
import haxe.ui.geom.Point;

typedef ChartInfo = {
	axis_info:AxisInfo,
	x_tick_info:TickInfo,
	y_tick_info:TickInfo,
	x_dist:AxisDist,
	y_dist:AxisDist,
}

class Chart {
	private var x_points:Array<Float>;
	private var y_points:Array<Float>;

	private var x_tick_info:TickInfo;
	private var y_tick_info:TickInfo;

	private var options:Options;
	private var x_axis:Axis;
	private var y_axis:Axis;

	public function new(x_points:Array<Float>, y_points:Array<Float>, ?top:Float, ?left:Float, ?width:Float, ?height:Float) {
		options = new Options();
		this.x_points = x_points;
		this.y_points = y_points;
		setDimensions(width, height);
		createCanvas(top, left);
		sortPoints();
		setAxis();
		setTickInfo();
	}

	private var canvas:Canvas;
	private var width:Float;
	private var height:Float;

	private function createCanvas(top:Float, left:Float) {
		canvas = haxe.ui.ComponentBuilder.fromFile("Assets/chart.xml", {width: width, height: height});
		canvas.percentWidth = 50;
		canvas.percentHeight = 100;
		canvas.top = top;
		canvas.left = left;
	}

	private function setDimensions(width:Float, height:Float) {
		var screen = Screen.instance;
		this.width = width == null ? screen.width / 2 : width;
		var new_height = height == null ? screen.height / 2 : height;
		this.height = new_height == 0 ? 500 : new_height;
	}

	private var min_x:Float;
	private var max_x:Float;
	private var min_y:Float;
	private var max_y:Float;

	private function sortPoints() {
		var x_points_copy = x_points.copy();
		var y_points_copy = y_points.copy();
		x_points_copy.sort(Reflect.compare);
		y_points_copy.sort(Reflect.compare);
		min_x = x_points_copy.shift();
		max_x = x_points_copy.pop();
		min_y = y_points_copy.shift();
		max_y = y_points_copy.pop();
	}

	public function draw() {
		if (x_points.length != y_points.length) {
			return null;
		}
		var axis_info = drawAxis();
		drawPoints(axis_info);
		return canvas;
	}

	private function setTickInfo() {
		x_tick_info = Axis.calcTickNum(min_x, max_x);
		y_tick_info = Axis.calcTickNum(min_y, max_y);
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
		var y_axis_length = calcAxisLength(height);
		var x_axis_length = calcAxisLength(width);
		setXAxis(x_axis_length, y_axis_length);
		setYAxis(x_axis_length, y_axis_length);
	}

	private function setXAxis(x_axis_length:Float, y_axis_length:Float) {
		var x_axis_start = setAxisStartPoint(options.margin, 0, false);
		var x_axis_end = setAxisEndPoint(x_axis_start, x_axis_length, false);
		x_axis = new Axis(x_axis_start, x_axis_end, min_x, max_x, false, options);
	}

	private function setYAxis(x_axis_length:Float, y_axis_length:Float) {
		var y_axis_end = setAxisStartPoint(options.margin, 0, true);
		var y_axis_start = setAxisEndPoint(y_axis_end, y_axis_length, true);
		y_axis = new Axis(y_axis_start, y_axis_end, min_y, max_y, true, options);
	}

	private function drawXAxis() {
		var x_ticks = x_axis.draw(canvas.componentGraphics, y_axis.ticks[y_tick_info.zero].position);
		return x_ticks;
	}

	private function drawYAxis() {
		var y_ticks = y_axis.draw(canvas.componentGraphics, x_axis.ticks[x_tick_info.zero].position);
		return y_ticks;
	}

	private function calcAxisLength(length:Float) {
		return length - 2 * options.margin;
	}

	private function setAxisStartPoint(margin:Float, axis_margin:Float, is_y:Bool) {
		if (is_y) {
			return new Point(axis_margin, margin);
		}
		return new Point(margin, axis_margin);
	}

	private function setAxisEndPoint(start_point:Point, axis_length:Float, is_y:Bool) {
		if (is_y) {
			return new Point(start_point.x, start_point.y + axis_length);
		}
		return new Point(start_point.x + axis_length, start_point.y);
	}

	private function calcAxisDists(min_coord:Float, max_coord:Float, pos_ratio:Float):AxisDist {
		var dist = max_coord - min_coord;
		var pos_dist = dist * pos_ratio;
		var neg_dist = dist - pos_dist;
		return {pos_dist: pos_dist, neg_dist: neg_dist};
	}

	private function drawPoints(axis_info:AxisInfo) {
		var x_coord_min = axis_info.x_ticks[0].position;
		var x_coord_max = axis_info.x_ticks[axis_info.x_ticks.length - 1].position;
		var x_dist = calcAxisDists(x_coord_min, x_coord_max, x_tick_info.pos_ratio);
		var y_coord_min = axis_info.y_ticks[0].position;
		var y_coord_max = axis_info.y_ticks[axis_info.y_ticks.length - 1].position;
		var y_dist = calcAxisDists(y_coord_max, y_coord_min, y_tick_info.pos_ratio);
		for (i in 0...x_points.length) {
			var point = new basics.Point(x_points[i], y_points[i], {
				axis_info: axis_info,
				x_dist: x_dist,
				y_dist: y_dist,
				y_tick_info: y_tick_info,
				x_tick_info: x_tick_info
			}, options);
			point.draw(canvas.componentGraphics);
		}
	}

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
