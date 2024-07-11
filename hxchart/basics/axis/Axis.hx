package hxchart.basics.axis;

import haxe.ui.util.Color;
import haxe.ui.behaviours.Behaviour;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.util.Variant;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.containers.Absolute;
import haxe.ui.components.Canvas;
import hxchart.basics.ticks.Ticks;
import haxe.ui.geom.Point;
import haxe.ui.behaviours.DefaultBehaviour;

@:composite(AxisBuilder, Layout)
class Axis extends Absolute {
	@:clonable @:behaviour(DefaultBehaviour, 10) public var tickMargin:Null<Float>;

	@:call(SetTicks) public function setTicks(data:Point):Void;

	@:call(Draw) private function draw():Void;

	public var is_y:Bool;
	public var startPoint:Point;
	public var endPoint:Point;
	public var ticks(default, set):Array<Ticks>;

	private function set_ticks(ticks:Array<Ticks>) {
		return this.ticks = ticks;
	}

	public var sub_ticks(default, set):Array<Ticks>;

	private function set_sub_ticks(ticks:Array<Ticks>) {
		return this.sub_ticks = ticks;
	}

	public function new() {
		super();
		startPoint = new Point(0, 0);
		endPoint = new Point(0, 0);
		color = Color.fromString("black");
	}

	public function setStartToEnd(axisLength:Float, marginStart:Float) {
		if (is_y) {
			endPoint = ChartTools.setAxisStartPoint(marginStart, 0, is_y, 0);
			startPoint = ChartTools.setAxisEndPoint(endPoint, axisLength, is_y);
		} else {
			startPoint = ChartTools.setAxisStartPoint(marginStart, 0, is_y, 0);
			endPoint = ChartTools.setAxisEndPoint(startPoint, axisLength, is_y);
		}
		draw();
	}
}

@:dox(hide) @:noCompletion
private class Layout extends DefaultLayout {
	public override function repositionChildren() {
		var axis = cast(_component, Axis);
	}
}

@:dox(hide) @:noCompletion
private class Draw extends Behaviour {
	public override function call(param:Any = null):Variant {
		var axis = cast(_component, Axis);
		var canvas = _component.findComponent(null, Canvas);
		if (canvas != null) {
			canvas.componentGraphics.strokeStyle(axis.color);
			canvas.componentGraphics.moveTo(axis.startPoint.x, axis.startPoint.y);
			canvas.componentGraphics.lineTo(axis.endPoint.x, axis.endPoint.y);
		}
		return null;
	}
}

@:dox(hide) @:noCompletion
private class SetTicks extends Behaviour {
	var axis:Axis;
	var start:Point;
	var end:Point;

	var is_y:Bool;
	var ticks:Array<Ticks>;
	var sub_ticks:Array<Ticks>;

	var layer:Absolute;

	public override function call(param:Any = null):Variant {
		var minmax:Point = param;
		axis = cast(_component, Axis);
		start = axis.startPoint;
		end = axis.endPoint;
		is_y = axis.is_y;
		ticks = axis.ticks;
		sub_ticks = axis.sub_ticks;
		layer = _component.findComponent(null, Absolute);
		setTickPosition(minmax.x, minmax.y);
		return null;
	}

	private function setTickPosition(min:Float, max:Float) {
		var tick_calc = AxisTools.calcTickInfo(min, max);
		var start_p = is_y ? start.y - axis.tickMargin : start.x + axis.tickMargin;
		var end_p = is_y ? end.y + axis.tickMargin : end.x - axis.tickMargin;
		var dist = is_y ? start_p - end_p : end_p - start_p;
		var dist_between_ticks = dist / (tick_calc.num - 1);
		var pos = AxisTools.calcTickPos(tick_calc.num, dist_between_ticks, start_p, is_y);
		for (i in 0...tick_calc.num) {
			var tick = new Ticks(false, is_y);
			tick.text = tick_calc.labels[i];
			tick.num = Std.parseFloat(tick_calc.labels[i]);
			if (is_y) {
				tick.top = pos[i];
				tick.left = 0;
			} else {
				tick.left = pos[i];
				tick.top = 0;
			}
			ticks.push(tick);
			layer.addComponent(tick);
		}
		var axis = cast(_component, Axis);
		axis.ticks = ticks;
		setSubTicks(tick_calc, dist_between_ticks);
	}

	private function setSubTicks(tick_calc:TickInfo, dist_between_ticks:Float) {
		var sub_num = AxisTools.setSubTickNum(tick_calc.num);
		var sub_tick = AxisTools.calcSubTickInfo(dist_between_ticks, sub_num, tick_calc.step);
		for (i in 0...(tick_calc.num - 1)) {
			var start = is_y ? ticks[i].top : ticks[i].left;
			for (j in 0...(sub_num - 1)) {
				var l = ticks[i].num + sub_tick.step * (j + 1);
				var d = start + (is_y ? -sub_tick.dists : sub_tick.dists) * (j + 1);
				var tick = new Ticks(true, is_y);
				tick.text = Utils.floatToStringPrecision(l, sub_tick.prec + 1);
				tick.num = l;
				if (is_y) {
					tick.top = d;
					tick.left = 0;
				} else {
					tick.left = d;
					tick.top = 0;
				}
				sub_ticks.push(tick);
				layer.addComponent(tick);
			}
		}
		var axis = cast(_component, Axis);
		axis.sub_ticks = sub_ticks;
	}
}

private class AxisBuilder extends CompositeBuilder {
	var _axis:Axis;
	var _tickLabelLayer:Absolute;
	var _tickCanvasLayer:Canvas;

	public function new(axis:Axis) {
		super(axis);
		_axis = axis;
		_axis.ticks = [];
		_axis.sub_ticks = [];
		_tickLabelLayer = new Absolute();
		_tickCanvasLayer = new Canvas();
		_axis.addComponent(_tickCanvasLayer);
		_axis.addComponent(_tickLabelLayer);
	}

	public override function onReady() {
		var sub_width = _axis.width;
		var sub_height = _axis.height;
		_tickCanvasLayer.width = sub_width;
		_tickLabelLayer.width = sub_width;
		_tickCanvasLayer.height = sub_height;
		_tickLabelLayer.height = sub_height;
	}
}
