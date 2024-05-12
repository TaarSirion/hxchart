package hxchart.basics.ticks;

import haxe.ui.macros.ComponentMacros;
import haxe.ui.util.ComponentUtil;
import haxe.ui.behaviours.DefaultBehaviour;
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
	@:clonable @:behaviour(DefaultBehaviour, 10) public var fontSize:Null<Float>;
	@:clonable @:behaviour(DefaultBehaviour, 8) public var subFontSize:Null<Float>;
	@:clonable @:behaviour(DefaultBehaviour, 7) public var tickLength:Null<Float>;
	@:clonable @:behaviour(DefaultBehaviour, 4) public var subTickLength:Null<Float>;

	@:clonable @:behaviour(TextBehaviour) public var text:String;

	public var canvas:Canvas;

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

	public function new(is_sub:Bool = false, is_y:Bool = false) {
		super();
		this.is_sub = is_sub;
		this.is_y = is_y;
		color = Color.fromString("black");
	}
}

@:dox(hide) @:noCompletion
private class TickLayout extends DefaultLayout {
	public override function repositionChildren() {
		var _tick = cast(_component, Ticks);
		var _label = _component.findComponent("tick-label", Label, null, "css");
		TickUtils.drawTicks(_tick, _label);
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
		TickUtils.drawTicks(_tick, _label);
	}
}

class TickUtils {
	public static function drawTicks(_tick:Ticks, _label:Label) {
		var is_sub = _tick.is_sub;
		var tickLength = is_sub ? _tick.subTickLength : _tick.tickLength;
		var tickFontsize = is_sub ? _tick.subFontSize : _tick.fontSize;
		var tickTop = is_sub ? ((_tick.tickLength - _tick.subTickLength) / 2) : 0;
		_tick.canvas.componentGraphics.strokeStyle(_tick.color);
		_label.customStyle.fontSize = tickFontsize;
		_label.left = _tick.is_y ? 5 : 0;
		_label.top = _tick.is_y ? 0 : 5;
		_tick.canvas.componentGraphics.clear();
		if (_tick.is_y) {
			_tick.canvas.left = -tickLength / 2;
			_tick.canvas.componentGraphics.moveTo(tickTop, 0);
			_tick.canvas.componentGraphics.lineTo(tickLength, 0);
		} else {
			_tick.canvas.top = -tickLength / 2;
			_tick.canvas.componentGraphics.moveTo(0, tickTop);
			_tick.canvas.componentGraphics.lineTo(0, tickLength);
		}
	}
}
