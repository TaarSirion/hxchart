package basics.ticks;

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

	private var tick_length:Float;
	private var fontsize:Float;

	public function new(pos:Float, label:String, num:Float, is_sub:Bool = false) {
		this.position = pos;
		this.label = label;
		this.num = num;
		this.is_sub = is_sub;
		tick_length = is_sub ? 2 : 5;
		fontsize = is_sub ? 8 : 10;
	}

	public function draw(graphics:ComponentGraphics, start:Point, is_y:Bool) {
		var screen = Screen.instance;
		var text_label = new Label();
		text_label.width = 20;
		text_label.text = label;
		text_label.customStyle.fontSize = fontsize;
		if (is_sub) {
			graphics.strokeStyle(Color.fromComponents(120, 120, 120, 1));
		}
		if (label == '0' && !is_y) {
			return;
		}

		if (label == '0' && is_y) {
			text_label.left = start.x - 15;
			text_label.top = position + 5;
			screen.addComponent(text_label);
		} else if (is_y) {
			text_label.customStyle.textAlign = "right";
			text_label.left = start.x - 18 - 12;
			text_label.top = position - fontsize / 2;
			screen.addComponent(text_label);
			graphics.moveTo(start.x - tick_length, position);
			graphics.lineTo(start.x + tick_length, position);
		} else {
			text_label.left = position - fontsize / 2;
			text_label.top = start.y + 10;
			screen.addComponent(text_label);
			graphics.moveTo(position, start.y - tick_length);
			graphics.lineTo(position, start.y + tick_length);
		}
	}
}
