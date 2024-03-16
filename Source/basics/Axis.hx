package basics;

import basics.AxisInfo.TickInfo;
import js.html.audio.DistanceModelType;
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
	private var margin:Float;

	public var size:Float = 1;
	public var color:Color;

	private var tick_amount:Int = 10;
	private var ticks:Array<Ticks>;
	private var sub_ticks:Array<Ticks>;

	public function new(start:Point, end:Point, min:Float, max:Float, is_y:Bool, color:Color, margin:Float, tick_amount:Int = 10) {
		this.start = start;
		this.end = end;
		this.is_y = is_y;
		this.color = color;
		this.tick_amount = tick_amount;
		this.min = min;
		this.max = max;
		this.margin = margin;
		ticks = [];
		sub_ticks = [];
		setTickPosition(min, max);
	}

	public function draw(graphics:ComponentGraphics) {
		graphics.strokeStyle(color);
		graphics.moveTo(start.x, start.y);
		graphics.lineTo(end.x, end.y);
		for (tick in ticks) {
			tick.draw(graphics, start, is_y);
		}
		for (tick in sub_ticks) {
			tick.draw(graphics, start, is_y);
		}
		return ticks;
	}

	private static function calcZeroIndex(pos_ratio:Float, tick_num:Int):Int {
		if (pos_ratio == 1) {
			return tick_num - 1;
		}
		return Math.floor(tick_num * (1 - pos_ratio));
	}

	public static function calcTickNum(min:Float, max:Float):TickInfo {
		var ten_pow = 1;
		if (max > 0) {
			ten_pow = Math.floor(Math.log(max) / Math.log(10));
		} else if (max < 0) {
			ten_pow = Math.floor(Math.log(Math.abs(min)) / Math.log(10));
		}
		var tick_step = cast(Math.pow(10, ten_pow), Int);
		var prec = tick_step < 1 ? -1 * ten_pow : ten_pow;
		var nmax = max < 0 ? 0 : Utils.roundToPrec(max + tick_step, prec);
		var nmin = min < 0 ? Utils.roundToPrec(min - tick_step, prec) : 0;
		var dist = Math.abs(nmin) + nmax;
		var tick_num = (max < 0 ? Math.ceil(dist / tick_step) : Math.floor(dist / tick_step)) + 1;
		var pos_ratio = calcPosRatio(nmin, nmax, dist);
		return ({
			num: tick_num,
			step: tick_step,
			min: nmin,
			prec: prec,
			pos_ratio: pos_ratio,
			zero: calcZeroIndex(pos_ratio, tick_num),
		});
	}

	private static function calcPosRatio(min:Float, max:Float, dist:Float):Float {
		if (min == 0) {
			return 1;
		} else if (max == 0) {
			return 0;
		}
		return max / dist;
	}

	private function calcSubTickNum(dist:Float, num:Int, big_step:Float) {
		var prec = (big_step < 1 ? -1 : 1) * Math.floor(Math.log(big_step) / Math.log(10)) + 1;
		var step = big_step / num;
		var dists = dist / num;
		return {dists: dists, step: step, prec: prec};
	}

	private function setTickPosition(min:Float, max:Float) {
		var tick_calc = calcTickNum(min, max);
		var start_p = is_y ? start.y - margin : start.x + margin;
		var end_p = is_y ? end.y + margin : end.x - margin;
		var dist = is_y ? start_p - end_p : end_p - start_p;
		var dist_between_ticks = dist / (tick_calc.num - 1);
		trace("Axis dist", dist, dist_between_ticks);
		for (i in 0...tick_calc.num) {
			var pos = is_y ? start_p - dist_between_ticks * i : start_p + dist_between_ticks * i;
			var label = Utils.floatToStringPrecision(tick_calc.min + tick_calc.step * i, tick_calc.prec);
			trace("Tick ", label, " pos", pos);
			ticks.push(new Ticks(pos, label, tick_calc.min + tick_calc.step * i));
		}
		setSubTicks(tick_calc, dist_between_ticks);
	}

	private function setSubTicks(tick_calc:TickInfo, dist_between_ticks:Float) {
		var sub_num = 0;
		if (tick_calc.num <= 2) {
			sub_num = 6;
		} else if (tick_calc.num <= 5) {
			sub_num = 4;
		} else if (tick_calc.num <= 10) {
			sub_num = 2;
		}
		var sub_tick = calcSubTickNum(dist_between_ticks, sub_num, tick_calc.step);
		for (i in 0...(tick_calc.num - 1)) {
			var start = ticks[i].position;
			for (j in 0...(sub_num - 1)) {
				var l = ticks[i].num + sub_tick.step * (j + 1);
				var d = start + (is_y ? -sub_tick.dists : sub_tick.dists) * (j + 1);
				sub_ticks.push(new Ticks(d, Utils.floatToStringPrecision(l, sub_tick.prec + 1), l, true));
			}
		}
	}

	private function lerp(min:Float, max:Float, value:Float) {
		return min + (max - min) * value;
	}
}
