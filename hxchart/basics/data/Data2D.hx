package hxchart.basics.data;

class Data2D {
	public var xValue(default, set):Dynamic;

	function set_xValue(value:Dynamic) {
		return xValue = value;
	}

	public var yValue(default, set):Dynamic;

	function set_yValue(value:Dynamic) {
		return yValue = value;
	}

	public var group(default, set):Int;

	function set_group(group:Int) {
		return this.group = group;
	}

	public function new(x:Dynamic, y:Dynamic, ?group:Int) {
		xValue = x;
		yValue = y;
		this.group = group;
	}
}
