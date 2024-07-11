package hxchart.basics.axis;

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
		if (ratio > 0 && ratio < 1) {
			tickNum++;
		}
		// calcZeroIndex(ratio)
		// calcNegNum(dist);
		// var pos_ratio = calcPosRatio(nmin, nmax, dist);
		// var zeroIndex = calcZeroIndex(pos_ratio, tickNum);
	}

	private function calcRatio(dist:Float):Float {
		if (max == 0) {
			return 0;
		} else if (min == 0) {
			return 1;
		}
		return max / dist;
	}

	private function calcZeroIndex(ratio:Float) {
		zeroIndex = Math.round(tickNum * ratio);
	}

	private function calcNegNum(dist:Float) {
		var posRatio = 1.0;
		negNum = 0;
		if (max == 0) {
			posRatio = 0;
			negNum = tickNum;
		} else if (min > 0) {
			posRatio = max / dist;
			negNum = Math.round(tickNum * posRatio);
		}
	}
}
