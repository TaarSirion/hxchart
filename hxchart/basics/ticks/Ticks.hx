package basics.ticks;

import haxe.ui.containers.Absolute;
import haxe.ui.util.Color;
import haxe.ui.core.Screen;
import haxe.ui.core.Component;
import haxe.ui.components.Canvas;
import haxe.ui.components.Label;
import haxe.ui.graphics.ComponentGraphics;
import haxe.ui.geom.Point;

class Ticks {
	public var position(default, set):Float;

	function get_position() {
		return position;
	}

	function set_position(pos:Float) {
		return position = pos;
	}

	public var label(default, set):String;

	function get_label() {
		return label;
	}

	function set_label(t:String) {
		return label = t;
	}

	public var num(default, null):Float;

	function get_num() {
		return num;
	}

	public var is_sub(default, null):Bool;

	function get_is_sub() {
		return is_sub;
	}

	private var options:Options;
	private var text_label:Label;

	public function new(pos:Float, label:String, num:Float, is_sub:Bool = false, options:Options) {
		this.position = pos;
		this.label = label;
		this.num = num;
		this.is_sub = is_sub;
		this.options = options;
		text_label = new Label();
	}

	public function draw(graphics:ComponentGraphics, start:Point, is_y:Bool, label_layer:Absolute) {
		var tick_length = (is_sub ? options.tick_sublength : options.tick_length);
		var tick_fontsize = (is_sub ? options.tick_subfontsize : options.tick_fontsize);
		text_label.width = 20;
		text_label.text = label;
		text_label.customStyle.fontSize = tick_fontsize;
		graphics.strokeStyle(options.tick_color);

		if (label == '0' && !is_y) {
			return;
		}

		if (label == '0' && is_y) {
			text_label.left = start.x - 15;
			text_label.top = position + 5;
			label_layer.addComponent(text_label);
		} else if (is_y) {
			text_label.customStyle.textAlign = "right";
			text_label.left = start.x - 18 - 12;
			text_label.top = position - tick_fontsize / 2;
			label_layer.addComponent(text_label);
			graphics.moveTo(start.x - tick_length, position);
			graphics.lineTo(start.x + tick_length, position);
		} else {
			text_label.left = position - tick_fontsize / 2;
			text_label.top = start.y + 10;
			label_layer.addComponent(text_label);
			graphics.moveTo(position, start.y - tick_length);
			graphics.lineTo(position, start.y + tick_length);
		}
	}
}
