package hxchart.core.utils;

import haxe.Timer;

using StringTools;

class Utils {
	/**
	 * Convert a float to a string with precision on how many digits should be shown.
	 * Will round the number to be accurate.
	 * @param n The number to be converted.
	 * @param prec The amount of digits after the comma.
	 */
	public static function floatToStringPrecision(n:Float, prec:Int) {
		n = Math.round(n * Math.pow(10, prec));
		var str = Std.string(n);
		var sign = str.startsWith("-") ? str.charAt(0) : '';
		if (sign.length == 1) {
			str = str.substr(1);
		}
		var len = str.length;
		if (len <= prec) {
			while (len < prec) {
				str = '0' + str;
				len++;
			}
			str = removeTrailingZeros(str);
			if (str == '0') {
				return str;
			}
			if (str.charAt(str.length - 1) == '.') {
				return sign + str.substr(0, str.length - 2);
			}
			return sign + '0.' + str;
		} else {
			if (prec <= 0) {
				return sign + str;
			}
			var str_before_comma = sign + str.substr(0, str.length - prec);
			var str_after_comma = removeTrailingZeros(str.substr(str.length - prec));
			if (str_after_comma == '0') {
				return str_before_comma;
			}
			return str_before_comma + '.' + str_after_comma;
		}
	}

	@:allow(hxchart.tests)
	private static function removeTrailingZeros(str:String) {
		while (str.endsWith('0') && str.length > 1) {
			str = str.substr(0, str.length - 1);
		}
		return str;
	}

	/**
	 * Round a number to the next decimal. 
	 * 
	 * This means a `10.4` with `prec = 1` will be rounded to `20`.
	 * 
	 * Equally this applies for negative numbers, a `-10.4` will be rounded to `-20` for `prec = 1`.
	 * 
	 * A special case is for numbers in the range -1 to 1. Here a higher `prec` will lead to a more precise number. E.g. `0.45` with `prec = 1` will be `0.5`, while `prec = 2` will be `0.45`.
	 * 
	 * The reason for this is, that this function is mainly used by the Axis, which will need this kind of rounding to show the correct values.
	 * @param n The number to round.
	 * @param prec The decimal precision to achieve.
	 */
	public static function roundToPrec(n:Float, prec:Float = 1) {
		if (n == 0) {
			return 0.0;
		}
		if (n % Math.pow(10, prec) == 0) {
			return n;
		}

		if (n > -1 && n < 1) {
			if (n > 0) {
				return (Math.ceil(n * Math.pow(10, prec)) / Math.pow(10, prec));
			}
			return (Math.floor(n * Math.pow(10, prec)) / Math.pow(10, prec));
		}
		if (n > 0) {
			return Math.round((n + Math.pow(10, prec) / 2) / Math.pow(10, prec)) * Math.pow(10, prec);
		}
		return Math.round((n - Math.pow(10, prec) / 2) / Math.pow(10, prec)) * Math.pow(10, prec);
	}

	/**
	 * Will remove all leading numbers before a dot.
	 * @param str Numeric String
	 */
	public static function removeLeadingNumbers(str:String) {
		if (!str.contains(".")) {
			return str;
		}
		var x = str.split(".");
		return x[1];
	}

	public static function benchmark(f:Void->Void, iterations:Int = 1) {
		var totalTime = 0.0;
		for (i in 0...iterations) {
			var start = Timer.stamp();
			f();
			var end = Timer.stamp();
			totalTime += end - start;
		}
		return totalTime / iterations;
	}
}
