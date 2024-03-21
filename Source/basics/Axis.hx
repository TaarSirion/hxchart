package basics;

import haxe.ui.containers.Absolute;
import basics.AxisTools.TickInfo;
import haxe.ui.core.Screen;
import haxe.ui.core.Component;
import haxe.ui.components.Canvas;
import basics.ticks.Ticks;
import haxe.ui.util.Color;
import haxe.ui.graphics.ComponentGraphics;
import haxe.ui.geom.Point;

class Axis {
	private var start:Point;
	private var end:Point;
	private var is_y:Bool;
	private var min:Float;
	private var max:Float;

	private var options:Options;

	public var ticks(default, null):Array<Ticks>;

	private var sub_ticks:Array<Ticks>;

	public function new(start:Point, end:Point, min:Float, max:Float, is_y:Bool, options:Options) {
		this.start = start;
		this.end = end;
		this.is_y = is_y;
		this.min = min;
		this.max = max;
		this.options = options;
		ticks = [];
		sub_ticks = [];
		setTickPosition(min, max);
	}

	private function setOtherMargin(value:Float) {
		if (is_y) {
			start.x = value;
			end.x = value;
		} else {
			start.y = value;
			end.y = value;
		}
	}

	public function draw(graphics:ComponentGraphics, other_margin:Float, label_layer:Absolute) {
		setOtherMargin(other_margin);
		graphics.strokeStyle(options.color);
		graphics.moveTo(start.x, start.y);
		graphics.lineTo(end.x, end.y);
		for (tick in ticks) {
			tick.draw(graphics, start, is_y, label_layer);
		}
		for (tick in sub_ticks) {
			tick.draw(graphics, start, is_y, label_layer);
		}
		return ticks;
	}

	private function setTickPosition(min:Float, max:Float) {
		var tick_calc = AxisTools.calcTickInfo(min, max);
		var start_p = is_y ? start.y - options.tick_margin : start.x + options.tick_margin;
		var end_p = is_y ? end.y + options.tick_margin : end.x - options.tick_margin;
		var dist = is_y ? start_p - end_p : end_p - start_p;
		var dist_between_ticks = dist / (tick_calc.num - 1);
		var pos = AxisTools.calcTickPos(tick_calc.num, dist_between_ticks, start_p, is_y);
		for (i in 0...tick_calc.num) {
			var label = Utils.floatToStringPrecision(tick_calc.min + tick_calc.step * i, tick_calc.prec);
			ticks.push(new Ticks(pos[i], label, tick_calc.min + tick_calc.step * i, false, options));
		}
		setSubTicks(tick_calc, dist_between_ticks);
	}

	private function setSubTicks(tick_calc:TickInfo, dist_between_ticks:Float) {
		var sub_num = AxisTools.setSubTickNum(tick_calc.num);
		var sub_tick = AxisTools.calcSubTickInfo(dist_between_ticks, sub_num, tick_calc.step);
		for (i in 0...(tick_calc.num - 1)) {
			var start = ticks[i].position;
			for (j in 0...(sub_num - 1)) {
				var l = ticks[i].num + sub_tick.step * (j + 1);
				var d = start + (is_y ? -sub_tick.dists : sub_tick.dists) * (j + 1);
				sub_ticks.push(new Ticks(d, Utils.floatToStringPrecision(l, sub_tick.prec + 1), l, true, options));
			}
		}
	}
}
