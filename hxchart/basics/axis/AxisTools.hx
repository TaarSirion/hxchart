package basics.axis;

import haxe.ds.Vector;

typedef TickInfo = {
	num:Int,
	step:Int,
	min:Float,
	prec:Int,
	pos_ratio:Float,
	zero:Int,
}

class AxisTools {
	private static function calcZeroIndex(pos_ratio:Float, tick_num:Int):Int {
		if (pos_ratio == 1) {
			return 0;
		}
		return Math.floor(tick_num * (1 - pos_ratio));
	}

	public static function calcTickInfo(min:Float, max:Float):TickInfo {
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

	public static function setSubTickNum(tick_num:Int) {
		if (tick_num <= 2) {
			return 6;
		} else if (tick_num <= 5) {
			return 4;
		} else if (tick_num <= 10) {
			return 2;
		}
		return 0;
	}

	public static function calcSubTickInfo(dist:Float, num:Int, big_step:Float) {
		var prec = (big_step < 1 ? -1 : 1) * Math.floor(Math.log(big_step) / Math.log(10)) + 1;
		var step = big_step / num;
		var dists = dist / num;
		return {dists: dists, step: step, prec: prec};
	}

	public static function calcTickPos(num:Int, dist_between_ticks:Float, start:Float, is_y:Bool) {
		var pos = new Vector(num);
		for (i in 0...pos.length) {
			pos[i] = is_y ? start - dist_between_ticks * i : start + dist_between_ticks * i;
		}
		return pos;
	}
}
