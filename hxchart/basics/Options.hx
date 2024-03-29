package hxchart.basics;

import hxchart.basics.legend.LegendTools.LegendPosition;
import haxe.ui.util.Color;

enum OptionEnum {
	margin;
	color;
	point_color;
	point_size;
	tick_length;
	tick_margin;
	tick_fontsize;
	tick_color;
}

typedef Option = {
	name:OptionEnum,
	value:Dynamic,
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

	public var point_color(default, set):Array<Color> = [Color.fromString("black")];

	function set_point_color(color:Array<Color>) {
		return this.point_color = color;
	}

	public var tick_color(default, set):Color = Color.fromString("black");

	function set_tick_color(color:Color) {
		return this.tick_color = color;
	}

	public var point_size(default, set):Float = 1;

	function set_point_size(size:Float) {
		return this.point_size = size;
	}

	public var tick_fontsize(default, set):Float = 10;

	function set_tick_fontsize(size:Float) {
		return this.tick_fontsize = size;
	}

	public var tick_subfontsize(default, set):Float = 8;

	function set_tick_subfontsize(size:Float) {
		return this.tick_subfontsize = size;
	}

	public var tick_length(default, set):Float = 5;

	function set_tick_length(length:Float) {
		return this.tick_length = length;
	}

	public var tick_sublength(default, set):Float = 2;

	function set_tick_sublength(length:Float) {
		return this.tick_sublength = length;
	}

	public var legend_margin(default, set):Float = 10;

	function set_legend_margin(margin:Float) {
		return legend_margin = margin;
	}

	public var legend_padding(default, set):Float = 10;

	function set_legend_padding(padding:Float) {
		return legend_padding = padding;
	}

	public var legend_align(default, set):LegendPosition = topright;

	function set_legend_align(align:LegendPosition) {
		return legend_align = align;
	}

	public function new() {}
}
