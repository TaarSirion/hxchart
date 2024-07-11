package hxchart.basics.axis;

class TickInfo {
	public var tickNum(default, set):Int;

	function set_tickNum(num:Int) {
		return tickNum = num;
	}

	public var tickDist(default, set):Float;

	function set_tickDist(dist:Float) {
		return tickDist = dist;
	}

	public function new() {}
}
