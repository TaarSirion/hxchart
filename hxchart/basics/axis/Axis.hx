package hxchart.basics.axis;

import hxchart.basics.utils.Statistics;
import haxe.ui.styles.elements.Directive;
import haxe.ui.styles.elements.RuleElement;
import haxe.ui.components.Label;
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
	@:optional public var values:Array<Any>;
	public var rotation:Int;
	@:optional public var start:Point;
	@:optional public var length:Null<Float>;
	@:optional public var showZeroTick:Null<Bool>;
	@:optional public var zeroTickOrientation:CompassOrientation;
	@:optional public var title:String;

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

		rotation = rotation > 360 ? 0 : (rotation >= 180 ? rotation - 180 : rotation);

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
	@:call(SetTicks) public function setTicks(data:Bool):Void;

	/**
	 * Draw the axis and ticks on the canvas.
	 */
	@:call(Draw) public function drawAxis():Void;

	/**
	 * Information on the axes.
	 */
	public var axesInfo(default, set):Array<AxisInfo>;

	private function set_axesInfo(info:Array<AxisInfo>) {
		return axesInfo = info;
	}

	public var ticksPerInfo(default, set):Array<Array<Ticks>>;

	private function set_ticksPerInfo(ticks:Array<Array<Ticks>>) {
		return ticksPerInfo = ticks;
	}

	/**
	 * Color of the axis. Can be set via stylesheet, or by hand.
	 */
	public var axisColor(default, set):Color;

	private function set_axisColor(color:Color) {
		return axisColor = color;
	}

	/**
	 * Axis Style Sheet. This is needed because it is not possible to directly set the styleSheet in the constructor of Axis, as it gets overwritten in the 
	 * composition build step.
	 */
	public var axisStyleSheet(default, set):StyleSheet;

	private function set_axisStyleSheet(styleSheet:StyleSheet) {
		return axisStyleSheet = styleSheet;
	}

	public var zeroPoint(default, set):Point;

	private function set_zeroPoint(point:Point) {
		return zeroPoint = point;
	}

	public function new(id:String, axisInfo:Array<AxisInfo>, ?styleSheet:StyleSheet) {
		if (axisInfo == null || axisInfo.length == 0) {
			throw new Exception("No AxisInfo found.");
		}

		if (Statistics.any(axisInfo, info -> info.type == null)) {
			throw new Exception("Axis cannot be created without type. You can generate the type via setAxisInfo in AxisInfo or provide one by hand.");
		}

		if (Statistics.any(axisInfo, info -> info.tickInfo == null)) {
			throw new Exception("Axis cannot be created without TickInfo. You can generate the TickInfo via setAxisInfo in AxisInfo or provide one by hand.");
		}

		axisColor = 0x000000;
		if (styleSheet != null) {
			axisStyleSheet = styleSheet;
			var rule = styleSheet.findRule(".axis");
			var colorRule = rule.directives.get("background-color");
			if (colorRule != null) {
				axisColor = Color.fromString(colorRule.value.getParameters()[0]);
			}
		}

		axesInfo = axisInfo;
		ticksPerInfo = [];

		for (info in axisInfo) {
			ticksPerInfo.push([]);
		}

		super();
		this.id = id;
	}

	override function onResized() {
		// axisLength = width * 0.9;
		// if (axisRotation == 270) {
		// 	axisLength = height * 0.9;
		// }
		super.onResized();
	}

	final axisMarginLeft:Float = 30;
	final axisMarginTop:Float = 30;

	public final titleMargin:Float = 30;

	/**
	 * Centers the startpoint at the beginning and positions it according to its linked axes on update.
	 */
	public function centerStartPoint(alternateWidth:Float = 0, alternateHeight:Float = 0) {
		this.zeroPoint = new Point(axisMarginLeft + (this.width - axisMarginLeft * 2) / 2, axisMarginTop + (this.height - axisMarginTop * 2) / 2);
		var xaxesNum:Int = 0;
		var yaxesNum:Int = 0;
		for (info in this.axesInfo) {
			var rotation = info.rotation;
			switch (rotation) {
				case 0:
					if (xaxesNum == 0) {
						this.zeroPoint.x = info.tickInfo.zeroIndex * (this.width - axisMarginLeft * 2) / (info.tickInfo.tickNum - 1) + axisMarginLeft;
					}
					info.length = this.width - axisMarginLeft * 2;
					xaxesNum++;
				case 90:
					if (yaxesNum == 0) {
						this.zeroPoint.y = this.height
							- info.tickInfo.zeroIndex * (this.height - axisMarginTop * 2) / (info.tickInfo.tickNum - 1)
							- axisMarginTop;
					}
					info.length = this.height - axisMarginTop * 2;
					yaxesNum++;
				case _:
			}
		}

		var xaxesTitle = 0;
		var yaxesTitle = 0;
		var newHeight = height - axisMarginTop * 2;
		var newWidth = width - axisMarginLeft * 2;
		for (info in this.axesInfo) {
			switch (info.rotation) {
				case 0:
					if (info.title == null) {
						continue;
					}
					if (zeroPoint.y >= (height - axisMarginTop)) {
						newHeight = height - axisMarginTop * 2 - titleMargin;
						zeroPoint.y = height - axisMarginTop - titleMargin;
					} else {
						newHeight = height - axisMarginTop * 2;
					}
				case 90:
					if (info.title == null) {
						continue;
					}
					if (zeroPoint.x <= (axisMarginLeft)) {
						newWidth = width - axisMarginLeft * 2 - titleMargin;
						zeroPoint.x = axisMarginLeft + titleMargin;
					} else {
						newWidth = width - axisMarginLeft * 2;
					}
				case _:
			}
		}

		for (info in this.axesInfo) {
			var rotation = info.rotation;
			if (info.start == null) {
				info.start = new Point(0, 0);
			}
			switch (rotation) {
				case 0:
					if (info.length != newWidth) {
						info.length = newWidth;
						info.start.x = zeroPoint.x;
					} else {
						info.start.x = axisMarginLeft;
					}
					info.start.y = zeroPoint.y;

				// if (info.title != null) {
				// 	xaxesTitle++;
				// 	if (this.zeroPoint.y >= (this.height - marginTop - titleMargin)) {
				// 		info.start = new Point(marginLeft, this.zeroPoint.y - titleMargin);
				// 		this.zeroPoint.y -= titleMargin;
				// 		continue;
				// 	}
				// }
				// if (yaxesTitle > 0) {
				// 	info.length -= titleMargin;
				// 	if (this.zeroPoint.x <= (marginLeft + titleMargin)) {
				// 		info.start = new Point(this.zeroPoint.x + titleMargin, this.height - marginTop);
				// 		continue;
				// 	}
				// }
				// info.start = new Point(marginLeft, this.zeroPoint.y);
				case 90:
					if (info.length != newHeight) {
						info.length = newHeight;
						info.start.y = zeroPoint.y;
					} else {
						info.start.y = height - axisMarginTop;
					}
					info.start.x = zeroPoint.x;
				// if (info.title != null) {
				// 	yaxesTitle++;
				// 	if (this.zeroPoint.x <= (marginLeft + titleMargin)) {
				// 		info.start = new Point(this.zeroPoint.x + titleMargin, this.height - marginTop);
				// 		zeroPoint.x += titleMargin;
				// 		continue;
				// 	}
				// }
				// if (xaxesTitle > 0) {
				// 	info.length = this.height - marginTop * 2 - titleMargin;
				// 	if (this.zeroPoint.y >= (this.height - marginTop - titleMargin)) {
				// 		info.start = new Point(this.zeroPoint.x, this.zeroPoint.y - titleMargin);
				// 		continue;
				// 	}
				// }
				// info.start = new Point(this.zeroPoint.x, this.height - marginTop);
				case _:
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
		if (canvas == null) {
			return null;
		}

		for (i => info in axis.axesInfo) {
			canvas.componentGraphics.strokeStyle(axis.axisColor);
			var endPoint = AxisTools.positionEndpoint(info.start, info.rotation, info.length);
			canvas.componentGraphics.moveTo(info.start.x, info.start.y);
			canvas.componentGraphics.lineTo(endPoint.x, endPoint.y);
			if (info.title != null) {
				var titles = axis.findComponents("axis-title", Label);
				for (title in titles) {
					if (title.text != info.title) {
						continue;
					}

					var x = Math.abs(info.start.x - endPoint.x);
					var y = Math.abs(info.start.y - endPoint.y);
					title.left = x == 0 ? (info.start.x + axis.titleMargin) : x / 2;
					title.top = y == 0 ? (info.start.y + axis.titleMargin) : y / 2;
				}
			}

			for (tick in axis.ticksPerInfo[i]) {
				var tickLength = tick.tickLength;
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
		var isUpdate:Bool = param;

		var axis = cast(_component, Axis);
		var layer = _component.findComponent("axis-label-container", Absolute, true, "css");
		if (layer == null) {
			return null;
		}
		for (i => info in axis.axesInfo) {
			var tickInfo = info.tickInfo;
			if (!isUpdate) {
				axis.ticksPerInfo[i] = [];
				// axis.sub_ticks = [];
			}
			var tickNum = tickInfo.tickNum;
			if (Std.isOfType(tickInfo, StringTickInfo)) {
				// Increase tickNum size so that positioning centers the ticks. Necessary because StringTickInfo has no zero Tick.
				tickNum++;
			}
			var labelPosition:CompassOrientation = S;
			switch (info.rotation) {
				case 0:
					labelPosition = S;
				case 90:
					labelPosition = W;
				case _:
					labelPosition = S;
			}

			var tickPos = (info.length - 2 * info.tickMargin) / (tickNum - 1);
			var subTicksPerTick = 0;
			if (tickInfo.useSubTicks) {
				subTicksPerTick = tickInfo.subTicksPerPart;
			}
			var subIndex = 0;
			for (j in 0...tickInfo.tickNum) {
				var tick = new Ticks(false, info.rotation);
				if (isUpdate) {
					tick = axis.ticksPerInfo[i][j];
				}
				var tickPoint = AxisTools.positionEndpoint(info.start, info.rotation, info.tickMargin + j * tickPos);
				tick.left = tickPoint.x;
				tick.top = tickPoint.y;
				if (tickInfo.zeroIndex == j && !info.showZeroTick) {
					tick.hidden = true;
				}
				if (tickInfo.zeroIndex == j && info.zeroTickOrientation != null) {
					tick.labelPosition = info.zeroTickOrientation;
				} else {
					tick.labelPosition = labelPosition;
				}

				tick.text = tickInfo.labels[j];
				if (!isUpdate) {
					axis.ticksPerInfo[i].push(tick);
					layer.addComponent(tick);
				}
				// for (j in 0...subTicksPerTick) {
				// 	if (i == (tickInfo.tickNum - 1)) {
				// 		break;
				// 	}
				// 	var tick = axis.sub_ticks[j];
				// 	var tickPoint = AxisTools.positionEndpoint(tickPoint, axis.axisRotation, (j + 1) * tickPos / (subTicksPerTick + 1));
				// 	tick.left = tickPoint.x;
				// 	tick.top = tickPoint.y;
				// 	tick.text = tickInfo.subLabels[subIndex];
				// 	subIndex++;
				// 	if (!ticksInAxis.isUpdate) {
				// 		axis.sub_ticks.push(tick);
				// 		layer.addComponent(tick);
				// 	}
				// }
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
		_tickLabelLayer = new Absolute();
		var tickLayer = new Absolute();
		tickLayer.percentWidth = 100;
		tickLayer.percentHeight = 100;
		tickLayer.addClass("axis-label-container");
		var titleLayer = new Absolute();
		titleLayer.percentWidth = 100;
		titleLayer.percentHeight = 100;
		_tickLabelLayer.addComponent(tickLayer);
		_tickLabelLayer.addComponent(titleLayer);
		for (info in _axis.axesInfo) {
			if (info.title != null) {
				var title = new Label();
				title.text = info.title;
				title.addClass("axis-title");
				titleLayer.addComponent(title);
			}
		}
		_tickCanvasLayer = new Canvas();
		_tickCanvasLayer.percentWidth = 100;
		_tickLabelLayer.percentWidth = 100;
		_tickCanvasLayer.percentHeight = 100;
		_tickLabelLayer.percentHeight = 100;
		_axis.addComponent(_tickCanvasLayer);
		_axis.addComponent(_tickLabelLayer);
		setStyleSheet();
	}

	override function validateComponentData() {
		_tickCanvasLayer.componentGraphics.clear();
		_tickLabelLayer.childComponents[0].removeAllComponents();
		// _tickLabelLayer.childComponents[1].removeAllComponents();
		// _axis.endPoint = AxisTools.positionEndpoint(_axis.startPoint, _axis.axisRotation, _axis.axisLength);
		trace("VALID");
		_axis.centerStartPoint();
		_axis.setTicks(false);
		_axis.drawAxis();
	}

	override function validateComponentLayout():Bool {
		_tickCanvasLayer.componentGraphics.clear();
		trace("VALID 2");
		_axis.centerStartPoint();
		// _axis.endPoint = AxisTools.positionEndpoint(_axis.startPoint, _axis.axisRotation, _axis.axisLength);
		_axis.setTicks(true);
		_axis.drawAxis();
		return super.validateComponentLayout();
	}

	function setStyleSheet() {
		if (_axis.axisStyleSheet != null) {
			_axis.styleSheet = _axis.axisStyleSheet;
			return;
		}
		_axis.styleSheet = new StyleSheet();
		_axis.styleSheet.addRule(new RuleElement(".axis-title", [
			new Directive("text-align", VString("center")),
			new Directive("font-size", VDimension(PX(17))),
			new Directive("color", VColor(0x000000))
		]));
		_axis.styleSheet.addRule(new RuleElement(".axis-subtitle", [
			new Directive("text-align", VString("center")),
			new Directive("font-size", VDimension(PX(15))),
			new Directive("color", VColor(0x000000))
		]));
		// _axis.startPoint =
	}
}
