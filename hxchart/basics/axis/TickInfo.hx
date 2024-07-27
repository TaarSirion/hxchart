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

	public var zeroIndex(default, set):Int;

	function set_zeroIndex(index:Int) {
		return zeroIndex = index;
	}

	/**
	 * Tick Labels. Depending on the info type, this will be set automatically or has to be set manually.
	 */
	public var labels(default, set):Array<String>;

	function set_labels(labels:Array<String>) {
		return this.labels = labels;
	}

	/**
	 * If subticks should be used.
	 */
	public var useSubTicks(default, set):Bool;

	function set_useSubTicks(useSubTicks:Bool) {
		return this.useSubTicks = useSubTicks;
	}

	public var subTickNum(default, set):Int;

	function set_subTickNum(num:Int) {
		return subTickNum = num;
	}

	public var subLabels(default, set):Array<String>;

	function set_subLabels(labels:Array<String>) {
		return subLabels = labels;
	}

	public function new() {}
}
