package basics;

import basics.AxisInfo.TickInfo;
import basics.Chart.ChartInfo;
import haxe.ui.core.Screen;
import basics.AxisInfo.AxisZeros;
import basics.AxisInfo.AxisDist;
import haxe.ui.util.Color;
import haxe.ui.graphics.ComponentGraphics;

class Point {
	private var size:Float = 1;
	private var color:Color;
	private var x:Float;
	private var y:Float;

	private var x_val:Float;
	private var y_val:Float;

	public function new(x_val:Float, y_val:Float, chart_info:ChartInfo, size:Float, color:Color) {
		this.x_val = x_val;
		this.y_val = y_val;
		setPosition(chart_info);
		this.size = size;
		this.color = color;
	}

	public function draw(graphics:ComponentGraphics) {
		var screen = Screen.instance;
		graphics.strokeStyle(color, 1);
		graphics.circle(x, y, size);
	}

	private function setPosition(chart_info:ChartInfo) {
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
