package hxchart;

import haxe.ui.geom.Point;

class Utils {
	public static function centerPoints(coords:Point, width:Float, height:Float) {}

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
			return str_before_comma + '.' + str_after_comma;
		}
	}

	private static function removeTrailingZeros(str:String) {
		while (str.charAt(str.length - 1) == '0' && str.length > 1) {
			str = str.substr(0, str.length - 1);
		}
		return str;
	}

	public static function roundToPrec(n:Float, prec:Int = 1) {
		if (n == 0) {
			return 0.0;
		}
		if (n > 0) {
			return (Math.floor(n * Math.pow(10, prec)) / Math.pow(10, prec));
		}
		return (Math.ceil(n * Math.pow(10, prec)) / Math.pow(10, prec));
	}
}
