package hxchart;

class Utils {
	public static function floatToStringPrecision(n:Float, prec:Int) {
		n = Math.round(n * Math.pow(10, prec));
		var str = '' + n;
		var sign = str.charAt(0) == '-' ? str.charAt(0) : '';
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
			if (prec == 0) {
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

	private static function removeTrailingZeros(str:String) {
		while (str.charAt(str.length - 1) == '0' && str.length > 1) {
			str = str.substr(0, str.length - 1);
		}
		return str;
	}

	public static function roundToPrec(n:Float, prec:Float = 1) {
		if (n == 0) {
			return 0.0;
		}
		if (n % Math.pow(10, prec) == 0) {
			return n;
		}

		if (n > -1 && n < 1) {
			if (n > 0) {
				return (Math.floor(n * Math.pow(10, prec)) / Math.pow(10, prec));
			}
			return (Math.ceil(n * Math.pow(10, prec)) / Math.pow(10, prec));
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
		var x = str.split(".");
		return x[1];
	}
}
