package hxchart.basics.utils;

class Statistics {
	public static function order<T>(arr:Array<T>) {
		var x = arr.copy();
		x.sort(Reflect.compare);
		var vMap:Map<String, Int> = [];
		return x.map(v -> {
			var j = 0;
			if (vMap.exists(Std.string(v))) {
				j = vMap.get(Std.string(v)) + 1;
			}
			var index = arr.indexOf(v, j);
			vMap.set(Std.string(v), index);
			return index;
		});
	}

	public static function unique<T>(arr:Array<T>) {
		var a = arr.copy();
		var b = [];
		a.sort(Reflect.compare);
		for (i => v in a) {
			if (i == a.indexOf(v)) {
				b.push(v);
			}
		}
		return b;
	}

	public static function position<T>(arr:Array<T>, value:T) {
		var indexes = [];
		for (i => v in arr) {
			if (v == value) {
				indexes.push(i);
			}
		}
		return indexes;
	}
}