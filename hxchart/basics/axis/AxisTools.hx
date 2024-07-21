// package hxchart.basics.axis;
// import haxe.ds.Vector;
// import hxchart.Utils;
// // typedef TickInfo = {
// // 	num:Int,
// // 	step:Float,
// // 	min:Float,
// // 	prec:Int,
// // 	pos_ratio:Float,
// // 	zero:Int,
// // 	labels:Array<String>
// // }
class AxisTools {
	// 	private static function calcZeroIndex(pos_ratio:Float, tick_num:Int):Int {
	// 		if (pos_ratio == 1) {
	// 			return 0;
	// 		}
	// 		if (pos_ratio == 0) {
	// 			return tick_num - 1;
	// 		}
	// 		// if (pos_ratio == 0.5) {
	// 		// 	return Math.round((tick_num + 1) / 2) - 1; // basically the median value
	// 		// }
	// 		return Math.floor(tick_num * (1 - pos_ratio));
	// 	}
	// 	private static function calcTickNum(dist:Float, prec:Int, tick_step:Float, max:Float):Int {
	// 		var tick_num:Int = Math.round(dist * Math.pow(10, -prec)) + 1;
	// 		if (tick_step < 1) {
	// 			tick_num = Math.round(dist * Math.pow(10, prec)) + 1;
	// 		}
	// 		if (tick_num > 20) {
	// 			tick_num = 20;
	// 		}
	// 		return tick_num;
	// 	}
	// 	public static function setTickValues(tickStep:Float, zeroIndex:Int, tickNum:Int, prec:Int) {
	// 		var labels:Array<String> = new Vector(tickNum).toArray();
	// 		trace(tickStep, tickNum, zeroIndex);
	// 		var negDist = zeroIndex - 1;
	// 		for (i in 0...negDist) {
	// 			labels[i] = "" + Utils.floatToStringPrecision(-1 * tickStep * (negDist - i), prec);
	// 		}
	// 		labels[zeroIndex] = "0";
	// 		for (i in (zeroIndex + 1)...tickNum) {
	// 			labels[i] = "" + Utils.floatToStringPrecision(tickStep * (i - zeroIndex), prec);
	// 		}
	// 		return labels;
	// 	}
	// 	public static function calcTickInfo(min:Float, max:Float):TickInfo {
	// 		var tenPow = 1;
	// 		if (max > 0) {
	// 			tenPow = Math.floor(Math.log(max) / Math.log(10));
	// 		} else if (max < 0) {
	// 			tenPow = Math.floor(Math.log(Math.abs(min)) / Math.log(10));
	// 		}
	// 		var tickStep = Math.pow(10, tenPow);
	// 		var prec = tickStep < 1 ? -1 * tenPow : tenPow;
	// 		var nmax = max < 0 ? 0 : Utils.roundToPrec(max, prec);
	// 		var nmin = min < 0 ? Utils.roundToPrec(min, prec) : 0;
	// 		var dist = Math.abs(nmin) + nmax;
	// 		var tickNum = calcTickNum(dist, prec, tickStep, nmax);
	// 		if (tickNum == 20) {
	// 			// var realDist = dist / 20;
	// 			// var tickDiff = realDist - tickStep;
	// 			// if (tickDiff >= 0 && tickDiff < 10) {
	// 			// 	tickNum += 2;
	// 			// } else if (tickDiff >= 0 && tickDiff < 50) {
	// 			// 	tickStep = tickStep + tickStep / 2;
	// 			// 	tickNum = calcTickNum(dist, prec, tickStep, nmax);
	// 			// }
	// 			tickNum++;
	// 		}
	// 		var pos_ratio = calcPosRatio(nmin, nmax, dist);
	// 		var zeroIndex = calcZeroIndex(pos_ratio, tickNum);
	// 		return ({
	// 			num: tickNum,
	// 			step: tickStep,
	// 			min: nmin,
	// 			prec: tickStep < 1 ? -prec : 0,
	// 			pos_ratio: pos_ratio,
	// 			zero: zeroIndex,
	// 			labels: setTickValues(tickStep, zeroIndex, tickNum, prec),
	// 		});
	// 	}
	// 	private static function calcPosRatio(min:Float, max:Float, dist:Float):Float {
	// 		if (min == 0) {
	// 			return 1;
	// 		} else if (max == 0) {
	// 			return 0;
	// 		}
	// 		return max / dist;
	// 	}
	// 	public static function setSubTickNum(tick_num:Int) {
	// 		if (tick_num <= 2) {
	// 			return 6;
	// 		} else if (tick_num <= 5) {
	// 			return 4;
	// 		} else if (tick_num <= 10) {
	// 			return 2;
	// 		}
	// 		return 0;
	// 	}
	// 	public static function calcSubTickInfo(dist:Float, num:Int, big_step:Float) {
	// 		var prec = (big_step < 1 ? -1 : 1) * Math.floor(Math.log(big_step) / Math.log(10)) + 1;
	// 		var step = big_step / num;
	// 		var dists = dist / num;
	// 		return {dists: dists, step: step, prec: prec};
	// 	}
	// 	public static function calcTickPos(num:Int, dist_between_ticks:Float, start:Float, is_y:Bool) {
	// 		var pos = new Vector(num);
	// 		for (i in 0...pos.length) {
	// 			pos[i] = is_y ? start - dist_between_ticks * i : start + dist_between_ticks * i;
	// 		}
	// 		return pos;
	// 	}
}
