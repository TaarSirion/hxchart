package basics;

import basics.AxisInfo.AxisZeros;
import basics.AxisInfo.AxisDist;
import haxe.ui.util.Color;
import haxe.ui.graphics.ComponentGraphics;

class Point {
	private var size:Float = 1;
	private var color:Color;
	private var x:Float;
	private var y:Float;

	public function new(x_val:Float, y_val:Float, axis_info:AxisInfo, x_dist:AxisDist, y_dist:AxisDist, ?size:Float = 1) {
		setPosition(x_val, y_val, axis_info, x_dist, y_dist);
		this.size = size;
	}

	public function draw(graphics:ComponentGraphics) {
		graphics.strokeStyle(color, 1);
		graphics.circle(x, y, size);
	}

	private function setPosition(x_val:Float, y_val:Float, axis_info:AxisInfo, x_dist:AxisDist, y_dist:AxisDist) {
		var x_ratio = x_val / axis_info.x_ticks[axis_info.x_ticks.length - 1].num;
		this.x = axis_info.x_ticks[axis_info.x_tick_info.zero].position + x_dist.pos_dist * x_ratio;
		if (x_val < 0) {
			x_ratio = x_val / axis_info.x_ticks[0].num;
			this.x = axis_info.x_ticks[axis_info.x_tick_info.zero].position - x_dist.neg_dist * x_ratio;
		}

		var y_ratio = y_val / axis_info.y_ticks[axis_info.y_ticks.length - 1].num;
		this.y = axis_info.y_ticks[axis_info.y_tick_info.zero].position - y_dist.pos_dist * y_ratio;
		if (y_val < 0) {
			y_ratio = y_val / axis_info.y_ticks[0].num;
			this.y = axis_info.y_ticks[axis_info.x_tick_info.zero].position + y_dist.neg_dist * y_ratio;
		}
	}
}
