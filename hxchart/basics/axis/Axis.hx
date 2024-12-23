package hxchart.basics.axis;

import js.Lib;
import haxe.Timer;
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

enum AxisTypes {
	linear;
	categorical;
}

@:composite(AxisBuilder, Layout)
class Axis extends Absolute {
	@:clonable @:behaviour(DefaultBehaviour, 10) public var tickMargin:Null<Float>;

	@:call(SetTicks) public function setTicks(data:TickInfo):Void;

	@:call(UpdateTicks) public function updateTicks(data:TickInfo):Void;

	@:call(Draw) private function draw():Void;

	/**
	 * Rotation of an axis in degrees.
	 */
	public var rotation(default, set):Int;

	private function set_rotation(rotation:Int) {
		return this.rotation = rotation;
	}

	/**
	 * Start Point of an axis. Will not be calculated dynamically.
	 */
	public var startPoint(default, set):Point;

	function set_startPoint(point:Point) {
		if (startPoint == null) {
			startPoint = point;
			setTicks(tickInfo);
		} else {
			startPoint = point;
			updateTicks(tickInfo);
		}
		return startPoint;
	}

	public var linkedAxes(default, set):Map<String, Axis>;

	function set_linkedAxes(links:Map<String, Axis>) {
		return linkedAxes = links;
	}

	/**
	 * End Point of an axis. Will be calculated dynamically. But can also be set.
	 */
	public var endPoint(default, set):Point;

	function set_endPoint(point:Point) {
		return endPoint = point;
	}

	/**
	 * Length of the axis.
	 */
	public var axisLength(default, set):Float;

	function set_axisLength(length:Float) {
		return axisLength = length;
	}

	public var ticks(default, set):Array<Ticks>;

	private function set_ticks(ticks:Array<Ticks>) {
		return this.ticks = ticks;
	}

	public var tickInfo(default, set):TickInfo;

	private function set_tickInfo(tickInfo:TickInfo) {
		return this.tickInfo = tickInfo;
	}

	public var sub_ticks(default, set):Array<Ticks>;

	private function set_sub_ticks(ticks:Array<Ticks>) {
		return this.sub_ticks = ticks;
	}

	public var showZeroTick(default, set):Bool;

	private function set_showZeroTick(show:Bool) {
		return showZeroTick = show;
	}

	public var zeroTickPosition(default, set):CompassOrientation;

	private function set_zeroTickPosition(pos:CompassOrientation) {
		return zeroTickPosition = pos;
	}

	public function new(start:Point, rotation:Int, length:Float, tickInfo:TickInfo, idName:String, color:String = "black") {
		super();
		top = start.y;
		left = start.x;
		this.rotation = rotation;
		axisLength = length;
		showZeroTick = true;
		this.color = Color.fromString(color);
		this.tickInfo = tickInfo;
		id = idName;
		startPoint = start;
	}

	override function onResized() {
		axisLength = width * 0.9;
		if (rotation == 270) {
			axisLength = height * 0.9;
		}
		super.onResized();
	}

	/**
	 * Only needed at the beginning of creating the chart, to correctly center the startpoint.
	 */
	public function centerStartPoint(alternateWidth:Float = 0, alternateHeight:Float = 0) {
		var marginLeft = (width - axisLength) / 2;
		var marginTop = (height - axisLength) / 2;

		if (width == 0) {
			marginLeft = (alternateWidth - axisLength) / 2;
		}
		if (height == 0) {
			marginTop = (alternateHeight - axisLength) / 2;
		}
		if (linkedAxes != null) {
			var lengthPerRotation:Float = 0;
			if (rotation == 270) {
				lengthPerRotation = axisLength;
			}
			for (key in linkedAxes.keys()) {
				var linkedAxis = linkedAxes.get(key);
				switch (key) {
					case "y":
						startPoint = new Point(lengthPerRotation + marginLeft, linkedAxis.ticks[linkedAxis.tickInfo.zeroIndex].top);
					case "x":
						startPoint = new Point(linkedAxis.ticks[linkedAxis.tickInfo.zeroIndex].left, lengthPerRotation + marginTop);
					case "both":
					default:
						startPoint = new Point(40, 40);
				}
			}
		}
	}
}

@:dox(hide) @:noCompletion
private class Layout extends DefaultLayout {
	public override function repositionChildren() {
		var axis = cast(_component, Axis);
	}

	override function resizeChildren() {
		super.resizeChildren();
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
			if (axis.endPoint == null) {
				axis.endPoint = AxisTools.positionEndpoint(axis.startPoint, axis.rotation, axis.axisLength);
			}
			canvas.componentGraphics.lineTo(axis.endPoint.x, axis.endPoint.y);
			for (tick in axis.ticks) {
				var tickLength = tick.tickLength;
				var middlePoint = new Point(tick.left, tick.top);
				var start = AxisTools.positionEndpoint(middlePoint, tick.rotation, tickLength / 2);
				var end = AxisTools.positionEndpoint(middlePoint, tick.rotation + 180, tickLength / 2);
				canvas.componentGraphics.moveTo(start.x, start.y);
				canvas.componentGraphics.lineTo(end.x, end.y);
			}
			for (tick in axis.sub_ticks) {
				tick.showLabel = false;
				var tickLength = tick.subTickLength;
				var middlePoint = new Point(tick.left, tick.top);
				var start = AxisTools.positionEndpoint(middlePoint, tick.rotation, tickLength / 2);
				var end = AxisTools.positionEndpoint(middlePoint, tick.rotation + 180, tickLength / 2);
				canvas.componentGraphics.moveTo(start.x, start.y);
				canvas.componentGraphics.lineTo(end.x, end.y);
			}
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
		var tickInfo:TickInfo = param;
		axis = cast(_component, Axis);
		start = axis.startPoint;
		end = axis.endPoint;
		ticks = axis.ticks;
		sub_ticks = axis.sub_ticks;
		layer = _component.findComponent(null, Absolute);
		setTickPosition(tickInfo);
		return null;
	}

	private function setTickPosition(tickInfo:TickInfo) {
		axis.ticks = [];
		axis.sub_ticks = [];
		var start = axis.startPoint;
		var tickNum = tickInfo.tickNum;
		if (Std.isOfType(tickInfo, StringTickInfo)) {
			// Increase tickNum size so that positioning centers the ticks.
			tickNum++;
		}

		var tickPos = (axis.axisLength - 2 * axis.tickMargin) / (tickNum - 1);
		var subTicksPerTick = 0;
		if (tickInfo.useSubTicks) {
			subTicksPerTick = tickInfo.subTicksPerPart;
		}
		var subIndex = 0;
		for (i in 0...tickInfo.tickNum) {
			var tick = new Ticks(false, axis.rotation);
			var tickPoint = AxisTools.positionEndpoint(start, axis.rotation, axis.tickMargin + i * tickPos);
			tick.left = tickPoint.x;
			tick.top = tickPoint.y;
			if (tickInfo.zeroIndex == i && !axis.showZeroTick) {
				tick.hidden = true;
			}
			if (tickInfo.zeroIndex == i && axis.zeroTickPosition != null) {
				tick.labelPosition = axis.zeroTickPosition;
			}
			tick.text = tickInfo.labels[i];
			axis.ticks.push(tick);
			layer.addComponent(tick);
			for (j in 0...subTicksPerTick) {
				if (i == (tickInfo.tickNum - 1)) {
					break;
				}
				var tick = new Ticks(true, axis.rotation);
				var tickPoint = AxisTools.positionEndpoint(tickPoint, axis.rotation, (j + 1) * tickPos / (subTicksPerTick + 1));
				tick.left = tickPoint.x;
				tick.top = tickPoint.y;
				tick.text = tickInfo.subLabels[subIndex];
				tick.labelPosition = tickInfo.labelPosition;
				subIndex++;
				axis.sub_ticks.push(tick);
				layer.addComponent(tick);
			}
		}
	}
}

@:dox(hide) @:noCompletion
private class UpdateTicks extends Behaviour {
	var axis:Axis;
	var start:Point;
	var end:Point;

	var is_y:Bool;
	var ticks:Array<Ticks>;
	var sub_ticks:Array<Ticks>;

	var layer:Absolute;

	public override function call(param:Any = null):Variant {
		var tickInfo:TickInfo = param;
		axis = cast(_component, Axis);
		start = axis.startPoint;
		end = axis.endPoint;
		ticks = axis.ticks;
		sub_ticks = axis.sub_ticks;
		if (ticks.length == 0) {
			return null;
		}
		layer = _component.findComponent(null, Absolute);
		setTickPosition(tickInfo);
		return null;
	}

	private function setTickPosition(tickInfo:TickInfo) {
		var start = axis.startPoint;
		var tickNum = tickInfo.tickNum;
		if (Std.isOfType(tickInfo, StringTickInfo)) {
			// Increase tickNum size so that positioning centers the ticks.
			tickNum++;
		}

		var tickPos = (axis.axisLength - 2 * axis.tickMargin) / (tickNum - 1);
		var subTicksPerTick = 0;
		if (tickInfo.useSubTicks) {
			subTicksPerTick = tickInfo.subTicksPerPart;
		}
		var subIndex = 0;
		for (i in 0...tickInfo.tickNum) {
			var tick = axis.ticks[i];
			var tickPoint = AxisTools.positionEndpoint(start, axis.rotation, axis.tickMargin + i * tickPos);
			tick.left = tickPoint.x;
			tick.top = tickPoint.y;
			if (tickInfo.zeroIndex == i && !axis.showZeroTick) {
				tick.hidden = true;
			}
			if (tickInfo.zeroIndex == i && axis.zeroTickPosition != null) {
				tick.labelPosition = axis.zeroTickPosition;
			}
			tick.text = tickInfo.labels[i];
			for (j in 0...subTicksPerTick) {
				if (i == (tickInfo.tickNum - 1)) {
					break;
				}
				var tick = axis.sub_ticks[j];
				var tickPoint = AxisTools.positionEndpoint(tickPoint, axis.rotation, (j + 1) * tickPos / (subTicksPerTick + 1));
				tick.left = tickPoint.x;
				tick.top = tickPoint.y;
				tick.text = tickInfo.subLabels[subIndex];
				subIndex++;
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
		_tickLabelLayer = new Absolute();
		_tickCanvasLayer = new Canvas();
		_axis.addComponent(_tickCanvasLayer);
		_axis.addComponent(_tickLabelLayer);
	}

	override function validateComponentData() {
		_tickCanvasLayer.componentGraphics.clear();
		_tickLabelLayer.removeAllComponents();

		if (_axis.startPoint == null) {
			_axis.startPoint = new Point(40, 40);
		}

		_axis.endPoint = AxisTools.positionEndpoint(_axis.startPoint, _axis.rotation, _axis.axisLength);
		_axis.setTicks(_axis.tickInfo);

		_tickCanvasLayer.percentWidth = 100;
		_tickLabelLayer.percentWidth = 100;
		_tickCanvasLayer.percentHeight = 100;
		_tickLabelLayer.percentHeight = 100;
		drawAxis();
	}

	override function validateComponentLayout():Bool {
		_tickCanvasLayer.componentGraphics.clear();
		if (_axis.startPoint == null) {
			_axis.startPoint = new Point(40, 40);
		}

		_axis.centerStartPoint();
		_axis.endPoint = AxisTools.positionEndpoint(_axis.startPoint, _axis.rotation, _axis.axisLength);
		_axis.updateTicks(_axis.tickInfo);
		drawAxis();
		return super.validateComponentLayout();
	}

	function drawAxis() {
		var axis = _axis;
		var canvas = _tickCanvasLayer;
		if (canvas != null) {
			canvas.componentGraphics.strokeStyle(axis.color);
			canvas.componentGraphics.moveTo(axis.startPoint.x, axis.startPoint.y);
			if (axis.endPoint == null) {
				axis.endPoint = AxisTools.positionEndpoint(axis.startPoint, axis.rotation, axis.axisLength);
			}
			canvas.componentGraphics.lineTo(axis.endPoint.x, axis.endPoint.y);
			for (tick in axis.ticks) {
				var tickLength = tick.tickLength;
				var middlePoint = new Point(tick.left, tick.top);
				var start = AxisTools.positionEndpoint(middlePoint, tick.rotation, tickLength / 2);
				var end = AxisTools.positionEndpoint(middlePoint, tick.rotation + 180, tickLength / 2);
				canvas.componentGraphics.moveTo(start.x, start.y);
				canvas.componentGraphics.lineTo(end.x, end.y);
			}
			for (tick in axis.sub_ticks) {
				tick.showLabel = false;
				var tickLength = tick.subTickLength;
				var middlePoint = new Point(tick.left, tick.top);
				var start = AxisTools.positionEndpoint(middlePoint, tick.rotation, tickLength / 2);
				var end = AxisTools.positionEndpoint(middlePoint, tick.rotation + 180, tickLength / 2);
				canvas.componentGraphics.moveTo(start.x, start.y);
				canvas.componentGraphics.lineTo(end.x, end.y);
			}
		}
	}
}
