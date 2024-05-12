package hxchart.basics.points;

import haxe.ui.util.Color;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.events.MouseEvent;
import hxchart.basics.Chart.ChartInfo;
import haxe.ui.core.Screen;
import haxe.ui.graphics.ComponentGraphics;

class Point {
	public var pointSize:Null<Int> = 1;
	public var color:Color = Color.fromString("black");

	private var x:Float;
	private var y:Float;

	public var x_val(default, null):Float;
	public var y_val(default, null):Float;

	public var group(default, null):Int;

	public function new(x_val:Float, y_val:Float, group:Int = 0) {
		this.x_val = x_val;
		this.y_val = y_val;
		this.group = group;
	}

	public function draw(graphics:ComponentGraphics) {
		graphics.strokeStyle(color, 1);
		graphics.circle(x, y, pointSize);
	}

	private function onClick(e:MouseEvent) {
		if (isClickInside(e.screenX, e.screenY)) {
			trace("Clicked smt", e);
		}
	}

	private function isClickInside(x:Float, y:Float) {
		var in_x = x >= this.x - pointSize / 2 && x <= this.x + pointSize / 2;
		var in_y = y >= this.y - pointSize / 2 && y <= this.y + pointSize / 2;
		return in_x && in_y;
	}

	public function setPosition(chart_info:ChartInfo) {
		var axis_info = chart_info.axis_info;
		var x_tick_info = chart_info.x_tick_info;
		var y_tick_info = chart_info.y_tick_info;
		var x_dist = chart_info.x_dist;
		var y_dist = chart_info.y_dist;
		x = PointTools.calcXCoord(x_val, axis_info.x_ticks[axis_info.x_ticks.length - 1].num, axis_info.x_ticks[0].num,
			axis_info.x_ticks[x_tick_info.zero].left, x_dist);
		y = PointTools.calcYCoord(y_val, axis_info.y_ticks[axis_info.y_ticks.length - 1].num, axis_info.y_ticks[0].num,
			axis_info.y_ticks[y_tick_info.zero].top, y_dist);
	}
}
