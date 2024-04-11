package hxchart.basics.axis;

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

@:composite(AxisBuilder)
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

	// private function setOtherMargin(value:Float) {
	// 	if (is_y) {
	// 		start.x = value;
	// 		end.x = value;
	// 	} else {
	// 		start.y = value;
	// 		end.y = value;
	// 	}
	// }
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
		trace("Drawing axis");
		// setOtherMargin(other_margin);
		var start = cast(_component, Axis).pointsDS.get(0);
		var end = cast(_component, Axis).pointsDS.get(1);
		var is_y = cast(_component, Axis).is_y;
		var options = cast(_component, Axis).optionsDS.get(0);
		var canvas = _component.findComponent(null, Canvas);
		trace(canvas);
		var layer = _component.findComponent(null, Absolute);
		if (canvas != null) {
			canvas.componentGraphics.strokeStyle(options.color);
			canvas.componentGraphics.moveTo(start.x, start.y);
			canvas.componentGraphics.lineTo(end.x, end.y);
			// return ticks;
		}
	}
}

@:dox(hide) @:noCompletion
private class TickBehaviour extends DataBehaviour {
	public override function set(value:Variant) {
		super.set(value);
		trace("here");
	}

	private override function validateData() {
		var ticksDS:DataSource<Float> = _value;
		trace("validate ticksds");
		if (ticksDS.get(0) != null && ticksDS.get(1) != null) {
			setTickPosition(ticksDS.get(0), ticksDS.get(1));
		}
	}

	private function setTickPosition(min:Float, max:Float) {
		trace("setting ticks");
		var start = cast(_component, Axis).pointsDS.get(0);
		var end = cast(_component, Axis).pointsDS.get(1);
		var is_y = cast(_component, Axis).is_y;
		var options = cast(_component, Axis).optionsDS.get(0);
		var ticks = cast(_component, Axis).ticks;
		var tick_calc = AxisTools.calcTickInfo(min, max);
		var start_p = is_y ? start.y - options.tick_margin : start.x + options.tick_margin;
		var end_p = is_y ? end.y + options.tick_margin : end.x - options.tick_margin;
		var dist = is_y ? start_p - end_p : end_p - start_p;
		var dist_between_ticks = dist / (tick_calc.num - 1);
		var pos = AxisTools.calcTickPos(tick_calc.num, dist_between_ticks, start_p, is_y);
		var layer = _component.findComponent(null, Absolute);
		for (i in 0...tick_calc.num) {
			var label = Utils.floatToStringPrecision(tick_calc.min + tick_calc.step * i, tick_calc.prec);
			var tick = new Ticks(false, options, is_y);
			tick.text = label;
			tick.num = tick_calc.min + tick_calc.step * i;
			if (is_y) {
				tick.top = pos[i];
				tick.left = _component.left - 15;
			} else {
				tick.left = pos[i];
				tick.top = _component.top - 15;
			}
			ticks.push(tick); // new Ticks(pos[i], label, tick_calc.min + tick_calc.step * i, false, options, is_y));
			layer.addComponent(tick);
		}
		setSubTicks(tick_calc, dist_between_ticks, is_y, options);
		// var canvas = _component.findComponent(null, Canvas);
		// for (tick in ticks) {
		// 	tick.draw(canvas.componentGraphics, start, is_y, layer);
		// }
	}

	private function setSubTicks(tick_calc:TickInfo, dist_between_ticks:Float, is_y:Bool, options:Options) {
		var ticks = cast(_component, Axis).ticks;
		var sub_ticks = cast(_component, Axis).sub_ticks;
		var sub_num = AxisTools.setSubTickNum(tick_calc.num);
		var sub_tick = AxisTools.calcSubTickInfo(dist_between_ticks, sub_num, tick_calc.step);
		var layer = _component.findComponent(null, Absolute);
		for (i in 0...(tick_calc.num - 1)) {
			var start = is_y ? ticks[i].top : ticks[i].left;
			for (j in 0...(sub_num - 1)) {
				var l = ticks[i].num + sub_tick.step * (j + 1);
				var d = start + (is_y ? -sub_tick.dists : sub_tick.dists) * (j + 1);
				var tick = new Ticks(true, options, is_y); // new Ticks(d, Utils.floatToStringPrecision(l, sub_tick.prec + 1), l, true, options)
				tick.text = Utils.floatToStringPrecision(l, sub_tick.prec + 1);
				tick.num = l;
				if (is_y) {
					tick.top = d;
					tick.left = _component.left - 15;
				} else {
					tick.left = d;
					tick.top = _component.top - 15;
				}
				sub_ticks.push(tick);
				layer.addComponent(tick);
			}
		}
		// var canvas = _component.findComponent(null, Canvas);
		// var start = cast(_component, Axis).pointsDS.get(0);
		// for (tick in sub_ticks) {
		// 	tick.draw(canvas.componentGraphics, start, is_y, layer);
		// }
	}
}

private class AxisBuilder extends CompositeBuilder {
	var _axis:Axis;
	var _tickLabelLayer:Absolute;
	var _tickCanvasLayer:Canvas;

	public function new(axis:Axis) {
		super(axis);
		trace("Axis Builder");
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
		_tickCanvasLayer.width = _axis.width;
		_tickCanvasLayer.height = _axis.height;
	}
}
