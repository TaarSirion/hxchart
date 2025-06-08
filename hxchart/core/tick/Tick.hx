package hxchart.core.tick;

import hxchart.core.utils.Point;
import hxchart.core.utils.CompassOrientation;

class Tick {
	public var text:String;
	public var num(default, set):Float;

	function get_num() {
		return num;
	}

	function set_num(num:Float) {
		return this.num = num;
	}

	public var isSub(default, null):Bool;

	function get_isSub() {
		return isSub;
	}

	public var tickRotation(default, set):Int;

	function set_tickRotation(rotation:Int) {
		return this.tickRotation = rotation;
	}

	public var showLabel(default, set):Bool;

	function set_showLabel(show:Bool) {
		return showLabel = show;
	}

	public var labelPosition(default, set):CompassOrientation;

	function set_labelPosition(pos:CompassOrientation) {
		return labelPosition = pos;
	}

	public var middlePos(default, set):Point;

	function set_middlePos(pos:Point) {
		return middlePos = pos;
	}

	public var hidden(default, set):Bool;

	function set_hidden(hidden:Bool) {
		return this.hidden = hidden;
	}

	public function new(isSub:Bool = false, rotation:Int = 0) {
		this.isSub = isSub;
		this.tickRotation = rotation + 90;
		showLabel = true;
		labelPosition = S;
		hidden = false;
	}
}
