package hxchart.basics.ticks;

import haxe.ui.layouts.DefaultLayout;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.containers.Box;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.containers.Absolute;
import haxe.ui.util.Color;
import haxe.ui.core.Screen;
import haxe.ui.core.Component;
import haxe.ui.components.Canvas;
import haxe.ui.components.Label;
import haxe.ui.graphics.ComponentGraphics;
import haxe.ui.geom.Point;

@:composite(TickBuilder, TickLayout)
class Ticks extends Box {
	@:clonable @:behaviour(TextBehaviour) public var text:String;

	public var canvas:Canvas;
	public var position(default, set):Float;

	function get_position() {
		return position;
	}

	function set_position(pos:Float) {
		return position = pos;
	}

	public var num(default, set):Float;

	function get_num() {
		return num;
	}

	function set_num(num:Float) {
		return this.num = num;
	}

	public var is_sub(default, null):Bool;

	function get_is_sub() {
		return is_sub;
	}

	public var is_y(default, set):Bool;

	function get_is_y() {
		return is_y;
	}

	function set_is_y(is_y:Bool) {
		return this.is_y = is_y;
	}

	public var options:Options;

	public function new(is_sub:Bool = false, options:Options, is_y:Bool = false) {
		super();
		this.is_sub = is_sub;
		this.options = options;
		this.is_y = is_y;
		// text_label = new Label();
	}

	public function draw(graphics:ComponentGraphics, start:Point, is_y:Bool, label_layer:Absolute) {
		// text_label.width = 20;
		// text_label.text = label;
		// text_label.customStyle.fontSize = tick_fontsize;

		// if (label == '0' && !is_y) {
		// 	return;
		// }

		// if (label == '0' && is_y) {
		// 	text_label.left = start.x - 15;
		// 	text_label.top = position + 5;
		// 	label_layer.addComponent(text_label);
		// } else if (is_y) {
		// 	text_label.customStyle.textAlign = "right";
		// 	text_label.left = start.x - 18 - 12;
		// 	text_label.top = position - tick_fontsize / 2;
		// 	label_layer.addComponent(text_label);
		// 	graphics.moveTo(start.x - tick_length, position);
		// 	graphics.lineTo(start.x + tick_length, position);
		// } else {
		// 	text_label.left = position - tick_fontsize / 2;
		// 	text_label.top = start.y + 10;
		// 	label_layer.addComponent(text_label);
		// 	graphics.moveTo(position, start.y - tick_length);
		// 	graphics.lineTo(position, start.y + tick_length);
		// }
	}
}

@:dox(hide) @:noCompletion
private class TickLayout extends DefaultLayout {
	public override function repositionChildren() {
		var _tick = cast(_component, Ticks);
		var _label = _component.findComponent(null, Label);
		var is_sub = _tick.is_sub;
		var options = _tick.options;

		var tick_length = (is_sub ? options.tick_sublength : options.tick_length);
		var tick_fontsize = (is_sub ? options.tick_subfontsize : options.tick_fontsize);
		_tick.canvas.componentGraphics.strokeStyle(options.tick_color);
		_label.customStyle.fontSize = tick_fontsize;
		_label.left = _tick.is_y ? -15 : 0;
		_label.top = _tick.is_y ? 0 : 15;
		if (_tick.is_y) {
			_tick.canvas.left = -tick_length / 2;
			_tick.canvas.componentGraphics.moveTo(0, 0);
			_tick.canvas.componentGraphics.lineTo(tick_length, 0);
		} else {
			_tick.canvas.top = -tick_length / 2;
			_tick.canvas.componentGraphics.moveTo(0, 0);
			_tick.canvas.componentGraphics.lineTo(0, tick_length);
		}
	}
}

@:dox(hide) @:noCompletion
private class TextBehaviour extends DataBehaviour {
	private override function validateData() {
		var label = _component.findComponent("tick-label", Label, null, "css");
		if (label != null) {
			label.text = _value;
		}
	}
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
class TickBuilder extends CompositeBuilder {
	private var _tick:Ticks;
	private var _label:Label;

	public function new(tick:Ticks) {
		super(tick);
		_tick = tick;
		var label = new Label();
		_label = label;
		label.addClass("tick-label");
		_tick.addComponent(label);
		_tick.canvas = new Canvas();
		_tick.canvas.addClass("tick-symbol");
		_tick.addComponent(_tick.canvas);
	}

	public override function onReady() {
		super.onReady();
		var is_sub = _tick.is_sub;
		var options = _tick.options;

		var tick_length = (is_sub ? options.tick_sublength : options.tick_length);
		var tick_fontsize = (is_sub ? options.tick_subfontsize : options.tick_fontsize);
		_tick.canvas.componentGraphics.strokeStyle(options.tick_color);
		_label.customStyle.fontSize = tick_fontsize;
		_label.left = 0;
		_label.top = _tick.is_y ? 0 : 15;
		if (_tick.is_y) {
			_tick.canvas.left = 15 - tick_length / 2;
			_tick.canvas.componentGraphics.moveTo(0, 0);
			_tick.canvas.componentGraphics.lineTo(tick_length, 0);
		} else {
			_tick.canvas.top = 15 - tick_length / 2;
			_tick.canvas.componentGraphics.moveTo(0, 0);
			_tick.canvas.componentGraphics.lineTo(0, tick_length);
		}
	}
}
