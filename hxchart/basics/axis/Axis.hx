package hxchart.basics.axis;

import haxe.Exception;
import haxe.ui.styles.StyleSheet;
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

typedef TicksInAxis = {
	tickInfo:TickInfo,
	isUpdate:Bool,
}

/**
 * Axis information. Usually used in the first trail.
 * 
 * When only `type` is set, the corresponding trail will calculate its own axis.
 * 
 * When supplying `values` beware of these differences based on `type`:
 * - linear: Only the first two values in the array will be used, the represent the min and max values of the axis.
 * - categorical: All values will be used.
 * 
 * @param type Type of axis. The positioning of data depends on this. 
 * @param axis Optional. A full axis object. If this is supplied, the trail will use this axis instead trying to generate its own.
 * @param values Optional. Values the axis should have. Depending on the type, this will work differently.
 */
@:structInit class AxisInfo {
	public var id:String;
	@:optional public var tickInfo:TickInfo;
	@:optional public var type:AxisTypes;
	@:optional public var axis:Axis;
	@:optional public var values:Array<Any>;
	@:optional public var rotation:Int;
	@:optional public var start:Point;
	@:optional public var length:Float;
	@:optional public var showZeroTick:Bool;
	@:optional public var zeroTickOrientation:CompassOrientation;

	@:optional public var tickMargin:Float;

	public function setAxisInfo(trailValues:Array<Any>) {
		if (trailValues.length == 0) {
			throw new Exception("Cannot set AxisInfo without values.");
		}

		if (type == null) {
			var firstValue = trailValues[0];
			if (firstValue is Int || firstValue is Float) {
				type = linear;
			} else if (firstValue is String) {
				type = categorical;
			}
		}

		if (tickInfo != null) {
			return;
		}

		switch (type) {
			case linear:
				var min:Float = 0;
				var max:Float = 0;
				if (values != null && values.length >= 2) {
					min = values[0];
					max = values[1];
				}
				var dataValues = trailValues.copy();
				dataValues.sort(Reflect.compare);
				min = dataValues[0];
				max = dataValues[dataValues.length - 1];
				tickInfo = new NumericTickInfo(["min" => [min], "max" => [max]]);
			case categorical:
				var values:Array<String> = [];
				if (values == null || values.length == 0) {
					for (val in trailValues) {
						values.push(val);
					}
				} else {
					for (val in values) {
						values.push(val);
					}
				}
				tickInfo = new StringTickInfo(values);
		}
	}
}

@:composite(AxisBuilder, Layout)
class Axis extends Absolute {
	/**
	 * Set and update tick positions on the axis.
	 * @param data Contains TickInfo and if it should update the positions, or set new ones.
	 */
	@:call(SetTicks) public function setTicks(data:TicksInAxis):Void;

	/**
	 * Draw the axis and ticks on the canvas.
	 */
	@:call(Draw) public function drawAxis():Void;

	/**
	 * Information on the axis.
	 */
	public var axisInfo(default, set):AxisInfo;

	private function set_axisInfo(info:AxisInfo) {
		return axisInfo = info;
	}

	/**
	 * Rotation of an axis in degrees.
	 */
	public var axisRotation(default, set):Int;

	private function set_axisRotation(rotation:Int) {
		return this.axisRotation = rotation;
	}

	/**
	 * Start Point of an axis. Will not be calculated dynamically.
	 * Updates ticks when set.
	 */
	public var startPoint(default, set):Point;

	function set_startPoint(point:Point) {
		if (startPoint == null) {
			startPoint = point;
			setTicks({tickInfo: tickInfo, isUpdate: false});
		} else {
			startPoint = point;
			setTicks({tickInfo: tickInfo, isUpdate: true});
		}
		return startPoint;
	}

	/**
	 * Array of all linked axes. Will be used to position this axis in accordance to the linked axes.
	 * Currently this only works with linking one axis to "x" or "y".
	 */
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

	/**
	 * Array of all ticks on the axis.
	 */
	public var ticks(default, set):Array<Ticks>;

	private function set_ticks(ticks:Array<Ticks>) {
		return this.ticks = ticks;
	}

	/**
	 * Information on the ticks.
	 */
	public var tickInfo(default, set):TickInfo;

	private function set_tickInfo(tickInfo:TickInfo) {
		return this.tickInfo = tickInfo;
	}

	/**
	 * Array of all subticks on the axis.
	 */
	public var sub_ticks(default, set):Array<Ticks>;

	private function set_sub_ticks(ticks:Array<Ticks>) {
		return this.sub_ticks = ticks;
	}

	/**
	 * Show the zero tick. Default is true.
	 */
	public var showZeroTick(default, set):Bool;

	private function set_showZeroTick(show:Bool) {
		return showZeroTick = show;
	}

	/**
	 * Orientation of the zero tick label. Default is south, meaning below the axis and the tick. 
	 */
	public var zeroTickOrientation(default, set):CompassOrientation;

	private function set_zeroTickOrientation(pos:CompassOrientation) {
		return zeroTickOrientation = pos;
	}

	/**
	 * Color of the axis. Can be set via stylesheet, or by hand.
	 */
	public var axisColor(default, set):Color;

	private function set_axisColor(color:Color) {
		return axisColor = color;
	}

	/**
	 * Margin between the ticks on the axis.
	 */
	public var tickMargin(default, set):Float;

	private function set_tickMargin(margin:Float) {
		return tickMargin = margin;
	}

	public function new(axisInfo:AxisInfo, ?styleSheet:StyleSheet) {
		super();

		if (axisInfo == null) {
			throw new Exception("No AxisInfo found.");
		}

		if (axisInfo.type == null) {
			throw new Exception("Axis cannot be created without type. You can generate the type via setAxisInfo in AxisInfo or provide one by hand.");
		}

		if (axisInfo.tickInfo == null) {
			throw new Exception("Axis cannot be created without TickInfo. You can generate the TickInfo via setAxisInfo in AxisInfo or provide one by hand.");
		}
		tickInfo = axisInfo.tickInfo;
		id = axisInfo.id;

		if (axisInfo.showZeroTick == null) {
			showZeroTick = true;
		} else {
			showZeroTick = axisInfo.showZeroTick;
		}

		if (axisInfo.zeroTickOrientation == null) {
			zeroTickOrientation = S;
		} else {
			zeroTickOrientation = axisInfo.zeroTickOrientation;
		}

		if (axisInfo.length == null) {
			axisLength = 100;
		} else {
			axisLength = axisInfo.length;
		}

		if (axisInfo.rotation == null) {
			axisRotation = 0;
		} else {
			axisRotation = axisInfo.rotation;
		}

		if (axisInfo.tickMargin == null) {
			tickMargin = 10;
		} else {
			tickMargin = axisInfo.tickMargin;
		}

		if (styleSheet != null) {
			var rule = styleSheet.findRule(".axis");
			axisColor = Color.fromString(rule.directives.get("background-color").value.getParameters()[0]);
		} else {
			axisColor = 0x000000;
		}

		if (axisInfo.start == null) {
			top = 0;
			left = 0;
			startPoint = new Point(0, 0);
		} else {
			top = axisInfo.start.y;
			left = axisInfo.start.x;
			startPoint = axisInfo.start;
		}
	}

	override function onResized() {
		axisLength = width * 0.9;
		if (axisRotation == 270) {
			axisLength = height * 0.9;
		}
		super.onResized();
	}

	/**
	 * Centers the startpoint at the beginning and positions it according to its linked axes on update.
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
			if (axisRotation == 270) {
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
			canvas.componentGraphics.strokeStyle(axis.axisColor);
			canvas.componentGraphics.moveTo(axis.startPoint.x, axis.startPoint.y);
			if (axis.endPoint == null) {
				axis.endPoint = AxisTools.positionEndpoint(axis.startPoint, axis.axisRotation, axis.axisLength);
			}
			canvas.componentGraphics.lineTo(axis.endPoint.x, axis.endPoint.y);
			for (tick in axis.ticks) {
				var tickLength = tick.tickLength;
				var middlePoint = new Point(tick.left, tick.top);
				var start = AxisTools.positionEndpoint(middlePoint, tick.tickRotation, tickLength / 2);
				var end = AxisTools.positionEndpoint(middlePoint, tick.tickRotation + 180, tickLength / 2);
				canvas.componentGraphics.moveTo(start.x, start.y);
				canvas.componentGraphics.lineTo(end.x, end.y);
			}
			for (tick in axis.sub_ticks) {
				tick.showLabel = false;
				var tickLength = tick.subTickLength;
				var middlePoint = new Point(tick.left, tick.top);
				var start = AxisTools.positionEndpoint(middlePoint, tick.tickRotation, tickLength / 2);
				var end = AxisTools.positionEndpoint(middlePoint, tick.tickRotation + 180, tickLength / 2);
				canvas.componentGraphics.moveTo(start.x, start.y);
				canvas.componentGraphics.lineTo(end.x, end.y);
			}
		}
		return null;
	}
}

@:dox(hide) @:noCompletion
private class SetTicks extends Behaviour {
	public override function call(param:Any = null):Variant {
		var ticksInAxis:TicksInAxis = param;
		var tickInfo = ticksInAxis.tickInfo;
		var axis = cast(_component, Axis);
		var layer = _component.findComponent(null, Absolute);

		if (!ticksInAxis.isUpdate) {
			axis.ticks = [];
			axis.sub_ticks = [];
		}
		var tickNum = tickInfo.tickNum;
		if (Std.isOfType(tickInfo, StringTickInfo)) {
			// Increase tickNum size so that positioning centers the ticks. Necessary because StringTickInfo has no zero Tick.
			tickNum++;
		}

		var tickPos = (axis.axisLength - 2 * axis.tickMargin) / (tickNum - 1);
		var subTicksPerTick = 0;
		if (tickInfo.useSubTicks) {
			subTicksPerTick = tickInfo.subTicksPerPart;
		}
		var subIndex = 0;
		for (i in 0...tickInfo.tickNum) {
			var tick = new Ticks(false, axis.axisRotation);
			if (ticksInAxis.isUpdate) {
				tick = axis.ticks[i];
			}
			var tickPoint = AxisTools.positionEndpoint(axis.startPoint, axis.axisRotation, axis.tickMargin + i * tickPos);
			tick.left = tickPoint.x;
			tick.top = tickPoint.y;
			if (tickInfo.zeroIndex == i && !axis.showZeroTick) {
				tick.hidden = true;
			}
			if (tickInfo.zeroIndex == i && axis.zeroTickOrientation != null) {
				tick.labelPosition = axis.zeroTickOrientation;
			}
			tick.text = tickInfo.labels[i];
			if (!ticksInAxis.isUpdate) {
				axis.ticks.push(tick);
				layer.addComponent(tick);
			}
			for (j in 0...subTicksPerTick) {
				if (i == (tickInfo.tickNum - 1)) {
					break;
				}
				var tick = axis.sub_ticks[j];
				var tickPoint = AxisTools.positionEndpoint(tickPoint, axis.axisRotation, (j + 1) * tickPos / (subTicksPerTick + 1));
				tick.left = tickPoint.x;
				tick.top = tickPoint.y;
				tick.text = tickInfo.subLabels[subIndex];
				subIndex++;
				if (!ticksInAxis.isUpdate) {
					axis.sub_ticks.push(tick);
					layer.addComponent(tick);
				}
			}
		}
		return null;
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
		_tickCanvasLayer.percentWidth = 100;
		_tickLabelLayer.percentWidth = 100;
		_tickCanvasLayer.percentHeight = 100;
		_tickLabelLayer.percentHeight = 100;
		_axis.addComponent(_tickCanvasLayer);
		_axis.addComponent(_tickLabelLayer);
	}

	override function validateComponentData() {
		_tickCanvasLayer.componentGraphics.clear();
		_tickLabelLayer.removeAllComponents();
		_axis.endPoint = AxisTools.positionEndpoint(_axis.startPoint, _axis.axisRotation, _axis.axisLength);
		_axis.setTicks({tickInfo: _axis.tickInfo, isUpdate: false});
		_axis.drawAxis();
	}

	override function validateComponentLayout():Bool {
		_tickCanvasLayer.componentGraphics.clear();
		_axis.centerStartPoint();
		_axis.endPoint = AxisTools.positionEndpoint(_axis.startPoint, _axis.axisRotation, _axis.axisLength);
		_axis.setTicks({tickInfo: _axis.tickInfo, isUpdate: true});
		_axis.drawAxis();
		return super.validateComponentLayout();
	}
}
