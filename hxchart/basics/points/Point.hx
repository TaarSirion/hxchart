package hxchart.basics.points;

import hxchart.basics.ticks.Ticks;
import hxchart.basics.pointchart.ChartTools.AxisDist;
import haxe.ui.util.Color;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.events.MouseEvent;
import hxchart.basics.pointchart.Chart.ChartInfo;
import haxe.ui.core.Screen;
import haxe.ui.graphics.ComponentGraphics;

class Point {
	public var pointSize:Null<Int> = 1;
	public var color:Color = Color.fromString("black");

	private var x:Float;
	private var y:Float;

	public var x_val(default, null):Dynamic;
	public var y_val(default, null):Dynamic;

	public var group(default, null):Int;

	public function new(x_val:Dynamic, y_val:Dynamic, group:Int = 0) {
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
		var x_tick_info = chart_info.x_tick_info;
		var y_tick_info = chart_info.y_tick_info;
		var x_dist = chart_info.x_dist;
		var y_dist = chart_info.y_dist;
		x = calcXCoord(chart_info.xTicks, chart_info.xTicks[x_tick_info.zeroIndex].left, x_dist);
		y = calcYCoord(chart_info.yTicks, chart_info.yTicks[y_tick_info.zeroIndex].top, y_dist);
	}

	public function calcXCoord(ticks:Array<Ticks>, zero_pos:Float, x_dist:AxisDist) {
		if (x_val is String) {
			return ticks.filter(x -> {
				return x.text == x_val;
			})[0].left;
		}
		var xMax = Std.parseFloat(ticks[ticks.length - 1].text);
		var xMin = Std.parseFloat(ticks[0].text);
		var x_ratio = x_val / xMax;
		var x = zero_pos + x_dist.pos_dist * x_ratio;
		if (x_val < 0) {
			x_ratio = x_val / xMin;
			x = zero_pos - x_dist.neg_dist * x_ratio;
		}
		return x;
	}

	public function calcYCoord(ticks:Array<Ticks>, zero_pos:Float, y_dist:AxisDist) {
		if (y_val is String) {
			return ticks.filter(x -> {
				return x.text == y_val;
			})[0].top;
		}
		var yMax = Std.parseFloat(ticks[ticks.length - 1].text);
		var yMin = Std.parseFloat(ticks[0].text);
		var y_ratio = y_val / yMax;
		var y = zero_pos - y_dist.pos_dist * y_ratio;
		if (y_val < 0) {
			y_ratio = y_val / yMin;
			y = zero_pos + y_dist.neg_dist * y_ratio;
		}
		return y;
	}
}
