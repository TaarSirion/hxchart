package basics;

import haxe.ui.events.MouseEvent;
import basics.AxisTools.TickInfo;
import basics.Chart.ChartInfo;
import haxe.ui.core.Screen;
import basics.ChartTools.AxisDist;
import haxe.ui.graphics.ComponentGraphics;

class Point {
	private var x:Float;
	private var y:Float;

	public var x_val(default, null):Float;
	public var y_val(default, null):Float;

	public var group(default, null):Int;

	private var options:Options;

	public function new(x_val:Float, y_val:Float, options:Options, group:Int = 1) {
		this.x_val = x_val;
		this.y_val = y_val;
		this.group = group;
		this.options = options;
	}

	public function draw(graphics:ComponentGraphics) {
		var screen = Screen.instance;
		screen.registerEvent("click", onClick);
		graphics.strokeStyle(options.point_color, 1);
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
		calcXCoord(axis_info, x_tick_info, x_dist);
		calcYCoord(axis_info, y_tick_info, y_dist);
	}

	private function calcXCoord(axis_info:AxisInfo, x_tick_info:TickInfo, x_dist:AxisDist) {
		var x_ratio = x_val / axis_info.x_ticks[axis_info.x_ticks.length - 1].num;
		x = axis_info.x_ticks[x_tick_info.zero].position + x_dist.pos_dist * x_ratio;
		if (x_val < 0) {
			x_ratio = x_val / axis_info.x_ticks[0].num;
			x = axis_info.x_ticks[x_tick_info.zero].position - x_dist.neg_dist * x_ratio;
		}
	}

	private function calcYCoord(axis_info:AxisInfo, y_tick_info:TickInfo, y_dist:AxisDist) {
		var y_ratio = y_val / axis_info.y_ticks[axis_info.y_ticks.length - 1].num;
		y = axis_info.y_ticks[y_tick_info.zero].position - y_dist.pos_dist * y_ratio;
		if (y_val < 0) {
			y_ratio = y_val / axis_info.y_ticks[0].num;
			y = axis_info.y_ticks[y_tick_info.zero].position + y_dist.neg_dist * y_ratio;
		}
	}
}
