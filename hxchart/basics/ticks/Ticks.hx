package hxchart.basics.ticks;

import hxchart.basics.axis.AxisTools;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.containers.Box;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.util.Color;
import haxe.ui.components.Canvas;
import haxe.ui.components.Label;
import haxe.ui.geom.Point;

enum CompassOrientation {
	N;
	NE;
	E;
	SE;
	S;
	SW;
	W;
	NW;
}

@:composite(TickBuilder, TickLayout)
class Ticks extends Box {
	@:clonable @:behaviour(DefaultBehaviour, 10) public var fontSize:Null<Float>;
	@:clonable @:behaviour(DefaultBehaviour, 6) public var subFontSize:Null<Float>;
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

	public var rotation(default, set):Int;

	function set_rotation(rotation:Int) {
		return this.rotation = rotation;
	}

	public var showLabel(default, set):Bool;

	function set_showLabel(show:Bool) {
		return showLabel = show;
	}

	public var labelPosition(default, set):CompassOrientation;

	function set_labelPosition(pos:CompassOrientation) {
		return labelPosition = pos;
	}

	public var options:Options;

	public function new(is_sub:Bool = false, rotation:Int = 0) {
		super();
		this.is_sub = is_sub;
		this.rotation = rotation + 90;
		showLabel = true;
		labelPosition = S;
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
		var zeroPoint = new Point(0, 0);
		var labelPoint = AxisTools.positionEndpoint(zeroPoint, _tick.rotation, tickLength / 2 + 11);
		_label.customStyle.fontSize = tickFontsize;
		switch (_tick.labelPosition) {
			case S:
				_label.left = labelPoint.x - _label.width / 2;
				_label.top = labelPoint.y - _label.height / 2;
			case N:
				_label.left = labelPoint.x - _label.width / 2;
				_label.top = labelPoint.y + _label.height;
			case E:
				_label.left = labelPoint.x + _label.width / 2;
				_label.top = labelPoint.y + _label.height / 2;
			case W:
				_label.left = labelPoint.x - _label.width;
				_label.top = labelPoint.y + _label.height / 2;
			case NE:
				_label.left = labelPoint.x + _label.width / 2;
				_label.top = labelPoint.y + _label.height;
			case NW:
				_label.left = labelPoint.x - _label.width;
				_label.top = labelPoint.y + _label.height;
			case SE:
				_label.left = labelPoint.x + _label.width / 2;
				_label.top = labelPoint.y - _label.height / 2;
			case SW:
				_label.left = labelPoint.x - _label.width;
				_label.top = labelPoint.y - _label.height / 2;
		}
		_label.hidden = !_tick.showLabel;
	}
}
