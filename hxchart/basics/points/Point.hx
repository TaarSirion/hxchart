package hxchart.basics.points;

import thx.Floats;
import haxe.ui.events.MouseEvent;
import hxchart.basics.Chart.ChartInfo;
import haxe.ui.core.Screen;
import haxe.ui.graphics.ComponentGraphics;

class Point {
	private var x:Float;
	private var y:Float;

	public var x_val(default, null):Float;
	public var y_val(default, null):Float;

	public var group(default, null):Int;

	private var options:Options;

	public function new(x_val:Float, y_val:Float, options:Options, group:Int = 0) {
		this.x_val = x_val;
		this.y_val = y_val;
		this.group = group;
		this.options = options;
	}

	public function draw(graphics:ComponentGraphics) {
		var screen = Screen.instance;
		screen.registerEvent("click", onClick);
		graphics.strokeStyle(options.point_color[group], 1);
		graphics.circle(x, y, options.point_size);
	}

	private function onClick(e:MouseEvent) {
		if (isClickInside(e.screenX, e.screenY)) {
			trace("Clicked smt", e);
		}
	}

	private function isClickInside(x:Float, y:Float) {
		var in_x = x >= this.x - options.point_size / 2 && x <= this.x + options.point_size / 2;
		var in_y = y >= this.y - options.point_size / 2 && y <= this.y + options.point_size / 2;
		return in_x && in_y;
	}

	public function setPosition(chart_info:ChartInfo) {
		var axis_info = chart_info.axis_info;
		var x_tick_info = chart_info.x_tick_info;
		var y_tick_info = chart_info.y_tick_info;
		var x_dist = chart_info.x_dist;
		var y_dist = chart_info.y_dist;
		x = PointTools.calcXCoord(x_val, axis_info.x_ticks[axis_info.x_ticks.length - 1].num, axis_info.x_ticks[0].num,
			axis_info.x_ticks[x_tick_info.zero].position, x_dist);
		y = PointTools.calcYCoord(y_val, axis_info.y_ticks[axis_info.y_ticks.length - 1].num, axis_info.y_ticks[0].num,
			axis_info.y_ticks[y_tick_info.zero].position, y_dist);
	}
}
