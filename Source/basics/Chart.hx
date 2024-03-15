package basics;

import basics.AxisInfo.AxisDist;
import basics.ticks.Ticks;
import haxe.ui.graphics.ComponentGraphics;
import haxe.ui.Toolkit;
import haxe.ui.core.Screen;
import haxe.ui.core.Component;
import haxe.ui.util.Color;
import haxe.ui.components.Canvas;
import haxe.ui.geom.Point;

class Chart {
	public static function draw(x_points:Array<Float>, y_points:Array<Float>, ?x:Float = 0, ?y:Float = 0, ?width:Float, ?height:Float) {
		if (x_points.length != y_points.length) {
			return null;
		}
		var screen = Screen.instance;
		var new_width = width == null ? screen.width / 2 : width;
		var new_height = height == null ? screen.height / 2 : height;
		new_height = new_height == 0 ? 500 : new_height;
		var canvas = haxe.ui.ComponentBuilder.fromFile("Assets/chart.xml", {width: new_width, height: new_height});
		canvas.top = y;
		canvas.left = x;
		var x_points_copy = x_points.copy();
		var y_points_copy = y_points.copy();
		x_points_copy.sort(Reflect.compare);
		y_points_copy.sort(Reflect.compare);
		var margin = 50;
		var min_x = x_points_copy.shift();
		var max_x = x_points_copy.pop();
		var min_y = y_points_copy.shift();
		var max_y = y_points_copy.pop();
		var axis_info = drawAxis(canvas.componentGraphics, screen, margin, new_height, new_width, min_x, max_x, min_y, max_y);
		drawPoints(canvas.componentGraphics, x_points, y_points, axis_info);

		canvas.percentWidth = 50;
		canvas.percentHeight = 100;
		return canvas;
	}

	private static function drawAxis(graphics:ComponentGraphics, screen:Screen, margin:Float, height:Float, width:Float, min_x:Float, max_x:Float,
			min_y:Float, max_y:Float):AxisInfo {
		var color = Color.fromString("black");
		var x_tick_info = Axis.calcTickNum(min_x, max_x);
		var y_tick_info = Axis.calcTickNum(min_y, max_y);
		var tick_margin = 10;
		var y_axis_length = calcAxisLength(height, margin);
		var y_tick_boundary = calcAxisLength(y_axis_length, tick_margin);
		var x_axis_length = calcAxisLength(width, margin);
		var x_tick_boundary = calcAxisLength(x_axis_length, tick_margin);

		var y_tick_max = y_tick_info.min + y_tick_info.step * (max_y <= 0 ? y_tick_info.num - 1 : y_tick_info.num);
		var margin_bottom = calcAxisMargin(y_tick_info.min, y_tick_max, y_tick_info.pos_ratio, tick_margin, margin, y_tick_boundary, true);
		var x_axis_start = setAxisStartPoint(margin, margin_bottom, false);
		var x_axis_end = setAxisEndPoint(x_axis_start, x_axis_length, false);

		var x_tick_max = x_tick_info.min + x_tick_info.step * (max_x <= 0 ? x_tick_info.num - 1 : x_tick_info.num);
		var margin_left = calcAxisMargin(x_tick_info.min, x_tick_max, x_tick_info.pos_ratio, tick_margin, margin, x_tick_boundary, false);
		var y_axis_end = setAxisStartPoint(margin, margin_left, true);
		var y_axis_start = setAxisEndPoint(y_axis_end, y_axis_length, true);
		var x_axis = new Axis(x_axis_start, x_axis_end, min_x, max_x, false, color, tick_margin);
		var x_ticks = x_axis.draw(graphics, screen);
		var y_axis = new Axis(y_axis_start, y_axis_end, min_y, max_y, true, color, tick_margin);
		var y_ticks = y_axis.draw(graphics, screen);
		return {
			margin_bottom: margin_bottom,
			margin_left: margin_left,
			x_tick_info: x_tick_info,
			y_tick_info: y_tick_info,
			x_ticks: x_ticks,
			y_ticks: y_ticks
		};
	}

	private static function calcAxisLength(length:Float, margin:Float) {
		return length - 2 * margin;
	}

	private static function calcAxisMargin(tick_min:Float, tick_max:Float, pos_ratio:Float, tick_margin:Float, margin:Float, tick_boundary:Float, is_y:Bool) {
		if (tick_min >= 0) {
			return (is_y ? tick_boundary + tick_margin : 0) + margin;
		}
		if (tick_max <= 0) {
			return (is_y ? 0 : tick_boundary) + tick_margin + margin;
		}
		return tick_margin + margin + tick_boundary * (is_y ? pos_ratio : 1 - pos_ratio);
	}

	private static function setAxisStartPoint(margin:Float, axis_margin:Float, is_y:Bool) {
		if (is_y) {
			return new Point(axis_margin, margin);
		}
		return new Point(margin, axis_margin);
	}

	private static function setAxisEndPoint(start_point:Point, axis_length:Float, is_y:Bool) {
		if (is_y) {
			return new Point(start_point.x, start_point.y + axis_length);
		}
		return new Point(start_point.x + axis_length, start_point.y);
	}

	private static function calcAxisDists(min_coord:Float, max_coord:Float, pos_ratio:Float):AxisDist {
		var dist = max_coord - min_coord;
		var pos_dist = dist * pos_ratio;
		var neg_dist = dist - pos_dist;
		return {pos_dist: pos_dist, neg_dist: neg_dist};
	}

	private static function drawPoints(graphhics:ComponentGraphics, x_points:Array<Float>, y_points:Array<Float>, axis_info:AxisInfo) {
		var x_coord_min = axis_info.x_ticks[0].position;
		var x_coord_max = axis_info.x_ticks[axis_info.x_ticks.length - 1].position;
		var x_dist = calcAxisDists(x_coord_min, x_coord_max, axis_info.x_tick_info.pos_ratio);
		var y_coord_min = axis_info.y_ticks[0].position;
		var y_coord_max = axis_info.y_ticks[axis_info.y_ticks.length - 1].position;
		var y_dist = calcAxisDists(y_coord_max, y_coord_min, axis_info.y_tick_info.pos_ratio);
		for (i in 0...x_points.length) {
			var point = new basics.Point(x_points[i], y_points[i], axis_info, x_dist, y_dist);
			point.draw(graphhics);
		}
	}

	public static function setOptions() {}
}
