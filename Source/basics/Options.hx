package basics;

import haxe.ui.util.Color;

typedef Option = {
	name:String,
	value:Any
}

class Options {
	public var margin(default, set):Float = 50;

	function set_margin(margin:Float) {
		return this.margin = margin;
	}

	public var tick_margin(default, set):Float = 10;

	function set_tick_margin(tick_margin:Float) {
		return this.tick_margin = tick_margin;
	}

	public var color(default, set):Color = Color.fromString("black");

	function set_color(color:Color) {
		return this.color = color;
	}

	public var point_color(default, set):Color = Color.fromString("black");

	function set_point_color(color:Color) {
		return this.point_color = color;
	}

	public var tick_color(default, set):Color = Color.fromString("black");

	function set_tick_color(color:Color) {
		return this.tick_color = color;
	}

	public var label_color(default, set):Color = Color.fromString("black");

	function set_label_color(color:Color) {
		return this.label_color = color;
	}

	public var point_size(default, set):Float = 1;

	function set_point_size(size:Float) {
		return this.point_size = size;
	}

	public function new() {}
}
