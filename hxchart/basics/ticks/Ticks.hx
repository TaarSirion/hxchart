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

	public var bottomPos(default, set):Point;

	function set_bottomPos(pos:Point) {
		return bottomPos = pos;
	}

	public var topPos(default, set):Point;

	function set_topPos(pos:Point) {
		return topPos = pos;
	}

	public function new(is_sub:Bool = false, rotation:Int = 0) {
		super();
		this.is_sub = is_sub;
		this.tickRotation = rotation + 90;
		showLabel = true;
		labelPosition = S;
		#if !(haxeui_flixel || haxeui_heaps)
		color = Color.fromString("black");
		#end
	}
}

@:dox(hide) @:noCompletion
private class TickLayout extends DefaultLayout {
	public override function repositionChildren() {
		var _tick = cast(_component, Ticks);
		var _label = _component.findComponent("tick-label", Label, false, "css");
		if (_tick == null || _label == null) {
			return;
		}
		TickUtils.drawTicks(_tick, _label);
	}
}

@:dox(hide) @:noCompletion
private class TextBehaviour extends DataBehaviour {
	private override function validateData() {
		var label = _component.findComponent("tick-label", Label, false, "css");
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
		#if (haxeui_heaps || haxeui_flixel)
		_label.customStyle.color = Color.fromString("black");
		#end
		label.addClass("tick-label");
		_tick.addComponent(label);
	}

	public override function onReady() {
		super.onReady();
		TickUtils.drawTicks(_tick, _label);
	}

	override function validateComponentData() {
		super.validateComponentData();
		TickUtils.drawTicks(_tick, _label);
	}

	override function validateComponentLayout():Bool {
		TickUtils.drawTicks(_tick, _label);
		return super.validateComponentLayout();
	}
}

class TickUtils {
	public static function drawTicks(_tick:Ticks, _label:Label) {
		var is_sub = _tick.is_sub;
		var tickLength = is_sub ? _tick.subTickLength : _tick.tickLength;
		var tickFontsize = is_sub ? _tick.subFontSize : _tick.fontSize;
		var zeroPoint = new Point(0, 0);
		_label.customStyle.fontSize = tickFontsize;
		switch (_tick.labelPosition) {
			case S:
				var labelPoint = AxisTools.positionEndpoint(zeroPoint, 270, tickLength / 2 + 11);
				_label.left = labelPoint.x - _label.width / 2;
				_label.top = labelPoint.y - _label.height / 2;
			case N:
				var labelPoint = AxisTools.positionEndpoint(zeroPoint, 90, tickLength / 2 + 11);
				_label.left = labelPoint.x - _label.width / 2;
				_label.top = labelPoint.y + _label.height;
			case E:
				var labelPoint = AxisTools.positionEndpoint(zeroPoint, 0, tickLength / 2 + 11);
				_label.left = labelPoint.x + _label.width / 2;
				_label.top = labelPoint.y - _label.height / 2;
			case W:
				var labelPoint = AxisTools.positionEndpoint(zeroPoint, 180, tickLength / 2 + 11);
				_label.left = labelPoint.x - _label.width / 2;
				_label.top = labelPoint.y - _label.height / 2;
			case NE:
				var labelPoint = AxisTools.positionEndpoint(zeroPoint, 90, tickLength / 2 + 11);
				_label.left = labelPoint.x + _label.width / 2;
				_label.top = labelPoint.y + _label.height;
			case NW:
				var labelPoint = AxisTools.positionEndpoint(zeroPoint, 90, tickLength / 2 + 11);
				_label.left = labelPoint.x - _label.width;
				_label.top = labelPoint.y + _label.height;
			case SE:
				var labelPoint = AxisTools.positionEndpoint(zeroPoint, 270, tickLength / 2 + 11);
				_label.left = labelPoint.x + _label.width / 2;
				_label.top = labelPoint.y - _label.height / 2;
			case SW:
				var labelPoint = AxisTools.positionEndpoint(zeroPoint, 270, tickLength / 2 + 11);
				_label.left = labelPoint.x - _label.width;
				_label.top = labelPoint.y - _label.height / 2;
		}
		_label.hidden = !_tick.showLabel;
	}
}
