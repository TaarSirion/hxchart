package hxchart.basics.axis;

import haxe.ui.layouts.DefaultLayout;
import haxe.ui.util.Variant;
import haxe.ui.data.ListDataSource;
import haxe.ui.data.DataSource;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.containers.Absolute;
import hxchart.basics.axis.AxisTools.TickInfo;
import haxe.ui.components.Canvas;
import hxchart.basics.ticks.Ticks;
import haxe.ui.geom.Point;

@:composite(AxisBuilder, Layout)
class Axis extends Absolute {
	@:behaviour(OptionsBehaviour) public var optionsDS:DataSource<Options>;
	@:behaviour(PointsBehaviour) public var pointsDS:DataSource<Point>;
	@:behaviour(TickBehaviour) public var ticksDS:DataSource<Float>;

	public var is_y:Bool;
	public var ticks(default, set):Array<Ticks>;

	private function set_ticks(ticks:Array<Ticks>) {
		return this.ticks = ticks;
	}

	public var sub_ticks(default, set):Array<Ticks>;

	private function set_sub_ticks(ticks:Array<Ticks>) {
		return this.sub_ticks = ticks;
	}

	public function new(start:Point, end:Point, min:Float, max:Float, is_y:Bool, options:Options) {
		super();
		optionsDS.add(options);
		pointsDS.add(start);
		pointsDS.add(end);
		ticksDS.add(min);
		ticksDS.add(max);
		this.is_y = is_y;
	}
}

@:dox(hide) @:noCompletion
private class Layout extends DefaultLayout {
	public override function repositionChildren() {
		var axis = cast(_component, Axis);
		trace("A");
	}
}

@:dox(hide) @:noCompletion
private class OptionsBehaviour extends DataBehaviour {
	private override function validateData() {
		var optionDS:DataSource<Options> = _value;
		// if (optionDS.get(0) != null) {
		// 	setStyleSheet(optionDS.get(0));
		// }
	}
}

@:dox(hide) @:noCompletion
private class PointsBehaviour extends DataBehaviour {
	private override function validateData() {
		var pointsDS:DataSource<Point> = _value;
		if (pointsDS.get(0) != null && pointsDS.get(1) != null) {
			draw();
		}
	}

	private function draw() {
		var start = cast(_component, Axis).pointsDS.get(0);
		var end = cast(_component, Axis).pointsDS.get(1);
		var options = cast(_component, Axis).optionsDS.get(0);
		var canvas = _component.findComponent(null, Canvas);
		if (canvas != null) {
			canvas.componentGraphics.strokeStyle(options.color);
			canvas.componentGraphics.moveTo(start.x, start.y);
			canvas.componentGraphics.lineTo(end.x, end.y);
		}
	}
}

@:dox(hide) @:noCompletion
private class TickBehaviour extends DataBehaviour {
	var start:Point;
	var end:Point;

	var is_y:Bool;
	var options:Options;
	var ticks:Array<Ticks>;
	var sub_ticks:Array<Ticks>;

	var layer:Absolute;

	public override function set(value:Variant) {
		super.set(value);
	}

	private override function validateData() {
		var ticksDS:DataSource<Float> = _value;
		if (ticksDS.get(0) != null && ticksDS.get(1) != null) {
			start = cast(_component, Axis).pointsDS.get(0);
			end = cast(_component, Axis).pointsDS.get(1);
			is_y = cast(_component, Axis).is_y;
			options = cast(_component, Axis).optionsDS.get(0);
			ticks = cast(_component, Axis).ticks;
			sub_ticks = cast(_component, Axis).sub_ticks;
			layer = _component.findComponent(null, Absolute);
			setTickPosition(ticksDS.get(0), ticksDS.get(1));
		}
	}

	private function setTickPosition(min:Float, max:Float) {
		var tick_calc = AxisTools.calcTickInfo(min, max);
		var start_p = is_y ? start.y - options.tick_margin : start.x + options.tick_margin;
		var end_p = is_y ? end.y + options.tick_margin : end.x - options.tick_margin;
		var dist = is_y ? start_p - end_p : end_p - start_p;
		var dist_between_ticks = dist / (tick_calc.num - 1);
		var pos = AxisTools.calcTickPos(tick_calc.num, dist_between_ticks, start_p, is_y);
		for (i in 0...tick_calc.num) {
			var label = Utils.floatToStringPrecision(tick_calc.min + tick_calc.step * i, tick_calc.prec);
			var tick = new Ticks(false, options, is_y);
			tick.text = label;
			tick.num = tick_calc.min + tick_calc.step * i;
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
				var tick = new Ticks(true, options, is_y);
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
		_axis.pointsDS = new ListDataSource();
		_axis.ticksDS = new ListDataSource();
		_axis.optionsDS = new ListDataSource();
		_tickLabelLayer = new Absolute();
		_tickCanvasLayer = new Canvas();
		_axis.addComponent(_tickCanvasLayer);
		_axis.addComponent(_tickLabelLayer);
	}

	public override function onReady() {
		var parent = _axis.parentComponent;
		var sub_width = _axis.width + (_axis.is_y ? 15 : 0);
		var sub_height = _axis.height + (_axis.is_y ? 15 : 0);
		_tickCanvasLayer.width = sub_width;
		_tickLabelLayer.width = sub_width;
		_tickCanvasLayer.height = sub_height;
		_tickLabelLayer.height = sub_height;
	}
}
