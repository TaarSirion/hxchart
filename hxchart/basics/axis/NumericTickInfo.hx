package hxchart.basics.axis;

import hxchart.basics.ticks.Ticks.CompassOrientation;
import haxe.ds.Vector;

class NumericTickInfo implements TickInfo {
	public var tickNum:Int;
	public var tickDist:Float;
	public var zeroIndex:Int;
	public var labels:Array<String>;
	public var useSubTicks:Bool;
	public var subTickNum:Int;
	public var subLabels:Array<String>;
	public var subTicksPerPart:Int;
	public var labelPosition:CompassOrientation;

	public var precision(default, set):Int;

	function set_precision(precision:Int) {
		return this.precision = precision;
	}

	public var power(default, set):Float;

	function set_power(power:Float) {
		return this.power = power;
	}

	/**
	 * Negative Number of Ticks
	 */
	public var negNum(default, set):Int;

	function set_negNum(num:Int) {
		return negNum = num;
	}

	/**
	 * Min value
	 */
	public var min(default, set):Float;

	function set_min(min:Float) {
		return this.min = min;
	}

	public var max(default, set):Float;

	function set_max(max:Float) {
		return this.max = max;
	}

	/**
	 * Negative Number of Sub Ticks.
	 */
	public var subNegNum(default, set):Int;

	function set_subNegNum(num:Int) {
		return subNegNum = num;
	}

	public var removeLead(default, set):Bool;

	function set_removeLead(remove:Bool) {
		return removeLead = remove;
	}

	/**
	 * Create a new object of NumericTickInfo.
	 * @param min Min value of the axis.
	 * @param max Max value of the axis.
	 */
	public function new(min:Float, max:Float, useSubTicks:Bool = false, subTicksPerPart:Int = 3, removeLead:Bool = false) {
		this.min = min;
		this.max = max;
		this.useSubTicks = useSubTicks;
		this.subTicksPerPart = subTicksPerPart;
		this.removeLead = removeLead;
		calcPower();
		calcTickNum();
		setLabels([]);
	}

	function calcPower() {
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
		var diff = Math.abs(max) + Math.abs(min);
		// In case the current calculation is not able to envelope all values in 16 ticks, we need to do a different calculation.
		if (Math.floor(diff / power) > 16) {
			var rawStep = diff / 16;
			var step:Float = Math.floor(rawStep);
			if (rawStep < 1) {
				step = rawStep;
			}
			pow = Math.floor(Math.log(step) / Math.log(10));
			power = Math.pow(10, pow);
			if (power >= step) {
				step = power;
			} else if (power * 2 >= step) {
				step = power * 2;
			} else if (power * 5 >= step) {
				step = power * 5;
			} else {
				step = power * 10;
			}
			power = step;
		}
		precision = power < 1 ? -1 * pow : pow;
	}

	/**
	 * Calculate the number of ticks.
	 */
	public function calcTickNum() {
		var maxRound = max < 0 ? 0 : Utils.roundToPrec(max, precision);
		var minRound = min < 0 ? Utils.roundToPrec(min, precision) : 0;
		max = maxRound;
		min = minRound;
		var dist = Math.abs(minRound) + maxRound;
		tickNum = Math.round(dist / power);
		// Add extra tickNum for 0
		tickNum++;
		if (useSubTicks) {
			var tickSpaces = tickNum - 1;
			subTickNum = tickSpaces * subTicksPerPart;
		}
		var ratio = calcRatio(dist);
		calcZeroIndex(ratio);
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
		if (ratio == 1) {
			zeroIndex = 0;
		} else if (ratio == 0) {
			zeroIndex = tickNum - 1;
		} else {
			zeroIndex = Math.round((tickNum - 1) * (1 - ratio));
		}
	}

	/**
	 * Calculate the number of negative ticks.
	 * Inverts the zeroIndex and subtracts it from tickNum.
	 */
	private function calcNegNum() {
		negNum = zeroIndex > 0 ? zeroIndex : 0;
		if (useSubTicks) {
			subNegNum = negNum * subTicksPerPart;
		}
	}

	public function setLabels(values:Array<String>) {
		labels = new Vector(tickNum).toArray();
		var betweenTickStep = 0.0;
		var subTickPrec = 0;
		var roundPrec = 0;
		if (useSubTicks) {
			subLabels = new Vector(subTickNum).toArray();
			var vv = power / (subTicksPerPart + 1);
			subTickPrec = precision + 2;
			roundPrec = vv < 1 && vv > -1 ? precision + 2 : -1 * precision;
			betweenTickStep = Utils.roundToPrec(vv, roundPrec);
		}
		var subIndex = 0;
		for (i in 0...negNum) {
			var negTick = negNum - i;
			var negValue = -1 * power * negTick;
			labels[i] = "" + Utils.floatToStringPrecision(negValue, precision);
			if (useSubTicks) {
				var loopValue = negValue;
				for (j in 0...subTicksPerPart) {
					loopValue += betweenTickStep;
					var subLabel = "" + Utils.floatToStringPrecision(loopValue, subTickPrec);
					if (removeLead) {
						subLabels[subIndex] = "." + Utils.removeLeadingNumbers(subLabel);
					} else {
						subLabels[subIndex] = subLabel;
					}
					subIndex++;
				}
			}
		}
		labels[zeroIndex] = "0";
		for (i in (zeroIndex + 1)...tickNum) {
			var value = power * (i - zeroIndex);
			labels[i] = "" + Utils.floatToStringPrecision(value, precision);
			if (useSubTicks) {
				var loopValue = power * (i - zeroIndex - 1);
				for (j in 0...subTicksPerPart) {
					loopValue += betweenTickStep;
					var subLabel = "" + Utils.floatToStringPrecision(loopValue, subTickPrec);
					if (removeLead) {
						subLabels[subIndex] = "." + Utils.removeLeadingNumbers(subLabel);
					} else {
						subLabels[subIndex] = subLabel;
					}
					subIndex++;
				}
			}
		}
	}
}
