package hxchart.basics.axis;

import haxe.ds.Vector;

class NumericTickInfo extends TickInfo {
	public var precision(default, set):Int;

	function set_precision(precision:Int) {
		return this.precision = precision;
	}

	public var power(default, set):Float;

	function set_power(power:Float) {
		return this.power = power;
	}

	public var zeroIndex(default, set):Int;

	function set_zeroIndex(index:Int) {
		return zeroIndex = index;
	}

	public var negNum(default, set):Int;

	function set_negNum(num:Int) {
		return negNum = num;
	}

	public var min(default, set):Float;

	function set_min(min:Float) {
		return this.min = min;
	}

	public var max(default, set):Float;

	function set_max(max:Float) {
		return this.max = max;
	}

	/**
	 * Displayed distance between the ticks. This differs from tickDist in the sense
	 * that this is only for calculating the labels.
	 */
	public var valueDist(default, set):Float;

	function set_valueDist(dist:Float) {
		return valueDist = dist;
	}

	public var labels(default, set):Array<String>;

	function set_labels(labels:Array<String>) {
		return this.labels = labels;
	}

	/**
	 * Create a new object of NumericTickInfo.
	 * @param min Min value of the axis.
	 * @param max Max value of the axis.
	 */
	public function new(min:Float, max:Float) {
		super();
		this.min = min;
		this.max = max;
		var pow = 1;
		if (max > 1) {
			pow = Math.floor(Math.log(max - 1) / Math.log(10));
		} else if (max > 0 && max <= 1) {
			pow = Math.floor(Math.log(max) / Math.log(10));
		} else if (max <= 0 && min >= -1) {
			pow = Math.floor(Math.log(Math.abs(min)) / Math.log(10));
		} else if (max <= 0 && min < -1) {
			pow = Math.floor(Math.log(Math.abs(min) - 1) / Math.log(10));
		}
		power = Math.pow(10, pow);
		precision = power < 1 ? -1 * pow : pow;
	}

	/**
	 * Calculate the number of ticks.
	 */
	public function calcTickNum() {
		var maxRound = max < 0 ? 0 : Utils.roundToPrec(max, precision);
		var minRound = min < 0 ? Utils.roundToPrec(min, precision) : 0;
		var dist = Math.abs(minRound) + maxRound;
		tickNum = Math.round(dist * Math.pow(10, -precision));
		if (power < 1) {
			tickNum = Math.round(dist * Math.pow(10, precision));
		}
		if (tickNum > 20) {
			tickNum = 20;
		}
		var ratio = calcRatio(dist);
		calcZeroIndex(ratio);
		if (ratio > 0 && ratio < 1) {
			tickNum++;
		}
		calcNegNum();
	}

	/**
	 * Calculate the positive ratio of an axis.
	 * Will result in **0** if max is **0**.
	 * In **1** if min is **0**.
	 * And in **max / dist** else.
	 * @param dist Distance between rounded min and max values.
	 */
	private function calcRatio(dist:Float):Float {
		if (max == 0) {
			return 0;
		} else if (min == 0) {
			return 1;
		}
		return max / dist;
	}

	/**
	 * Calculate the index of the zero tick.
	 * Will result in **0** for a ratio of 1.
	 * In **1** for a ratio of **0**.
	 * And in **round(tickNum * (1 - ratio))** else.
	 * @param ratio Ratio of positive ticks.
	 */
	private function calcZeroIndex(ratio:Float) {
		switch ratio {
			case 1:
				zeroIndex = 0;
			case 0:
				zeroIndex = tickNum - 1;
			default:
				zeroIndex = Math.round(tickNum * (1 - ratio));
		}
	}

	/**
	 * Calculate the number of negative ticks.
	 * Inverts the zeroIndex and subtracts it from tickNum.
	 */
	private function calcNegNum() {
		var invertedIndex = tickNum - zeroIndex;
		negNum = tickNum - invertedIndex;
	}

	public function calcTickLabels() {
		labels = new Vector(tickNum).toArray();
		for (i in 0...negNum) {
			var negTick = negNum - i;
			labels[i] = "" + Utils.floatToStringPrecision(-1 * power * negTick, precision);
		}
		labels[zeroIndex] = "0";
		for (i in (zeroIndex + 1)...tickNum) {
			labels[i] = "" + Utils.floatToStringPrecision(power * (i - zeroIndex), precision);
		}
		return labels;
	}
}
