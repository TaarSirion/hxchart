package hxchart.basics.axis;

import haxe.ds.Vector;
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
#if haxeui_html5
import js.Browser;
import js.html.Element;
#end

enum AxisTypes {
	linear;
	categorical;
}

/**
 * Information for drawing the axis title.
 * 
 * @param text Text of the title.
 * @param position Optional. Position of the title. If not provided, it will be centered underneath the axis.
 * @param rotation Optional. Rotation of the title. Will default to the axis rotation.
 */
typedef AxisTitle = {
	var text:String;
	@:optional var position:Point;
	@:optional var rotation:Int;
}

/**
 * Axis information. For each drawn axis.
 * Attention: The Axis object is a combination of multiple axis informations. Each axis information
 * draws a line on the canvas.
 * 
 * When supplying `values` beware of these differences based on `type`:
 * - linear: Only the first two values in the array will be used, to represent the min and max values of the axis.
 * - categorical: All values will be used.
 * 
 * The `setAxisInfo` function will try to automatically set the axis type, tick information and rotation. 
 * If no values are provided, it will throw an exception.
 * 
 * @param id ID of the axis.
 * @param rotation Rotation of the axis. Can be anything between 0 and 179. 0 is a horizontal axis, 90 is a vertical axis. 
 * Values equal or higher than 180 will be converted to 0-179. This happens to ensure no backwards drawn axes appear.
 * @param type Optional. Type of axis. The positioning of data depends on this. 
 * @param values Optional. Values the axis should have. Depending on the type, this will work differently.
 * @param tickInfo Optional. See hxchart.basics.axis.TickInfo for more information.
 * @param start Optional. The startpoint of the axis. This will get overwritten by the `positionStartPoint` function.
 * @param length Optional. The length of the drawn axis. This will get overwritten by the `positionStartPoint` function.
 * @param title Optional. A title for the drawn axis.
 * @param subTitle Optional. A subtitle for the drawn axis. Automatic positioning will place the subtitle centered below the title, 
 * before any rotation is applied to the title. This means it is possible for the subtitle to be not centered, after rotation.
 * @param tickMargin Optional. Margin in between ticks.
 * @param showZeroTick Optional. If the zero tick should be shown.
 */
@:structInit class AxisInfo {
	public var id:String;
	@:optional public var tickInfo:TickInfo;
	@:optional public var type:AxisTypes;
	@:optional public var values:Array<Any> = [];
	public var rotation:Int;
	@:optional public var start:Point;
	@:optional public var length:Null<Float>;
	@:optional public var showZeroTick:Null<Bool>;
	@:optional public var title:AxisTitle;
	@:optional public var subTitle:AxisTitle;

	@:optional public var tickMargin:Float = 10;

	public function setAxisInfo(trailValues:Array<Any>) {
		if (trailValues.length == 0 && values.length == 0) {
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
		var moduloRotation = Math.round(Math.abs(rotation % 360));
		rotation = moduloRotation >= 180 ? moduloRotation - 180 : moduloRotation;
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
				} else {
					var dataValues = trailValues.copy();
					dataValues.sort(Reflect.compare);
					min = dataValues[0];
					max = dataValues[dataValues.length - 1];
				}
				tickInfo = new NumericTickInfo(["min" => [min], "max" => [max]]);
			case categorical:
				var dataValues:Array<String> = [];
				if (values == null || values.length == 0) {
					for (val in trailValues) {
						dataValues.push(val);
					}
				} else {
					for (val in values) {
						dataValues.push(val);
					}
				}
				tickInfo = new StringTickInfo(dataValues);
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

	/**
	 * Ticks per drawn axis. 
	 */
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

	/**
	 * Zero Point of all axes.
	 */
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

	/**
	 * Left margin for the Axis object.
	 */
	@:allow(hxchart.tests)
	final axisMarginLeft:Float = 30;

	/**
	 * Top margin for the Axis object.
	 */
	@:allow(hxchart.tests)
	final axisMarginTop:Float = 30;

	/**
	 * Title margin for each individual axis. 
	 */
	public final titleMargin:Float = 30;

	/**
	 * Positions the startpoints of the axes according to the other axes, titles and margins.
	 */
	public function positionStartPoint() {
		this.zeroPoint = new Point(axisMarginLeft + (this.width - axisMarginLeft * 2) / 2, axisMarginTop + (this.height - axisMarginTop * 2) / 2);
		// First position zero point according to axes information. Only the first two axes will be considered.
		var xaxesNum:Int = 0;
		var yaxesNum:Int = 0;
		for (info in this.axesInfo) {
			var rotation = info.rotation;
			switch (rotation) {
				case 0:
					if (xaxesNum == 0) {
						this.zeroPoint.x = info.tickInfo.zeroIndex * (this.width - axisMarginLeft * 2) / (info.tickInfo.tickNum - 1)
							+ axisMarginLeft
							+ info.tickMargin;
					}
					info.length = this.width - axisMarginLeft * 2;
					xaxesNum++;
				case 90:
					if (yaxesNum == 0) {
						this.zeroPoint.y = this.height
							- info.tickInfo.zeroIndex * (this.height - axisMarginTop * 2) / (info.tickInfo.tickNum - 1)
							- axisMarginTop
							- info.tickMargin;
					}
					info.length = this.height - axisMarginTop * 2;
					yaxesNum++;
				case _:
			}
		}
		// Then we change the height of the axes and position of zeroPoint according to present titles.
		var newHeight = height - axisMarginTop * 2;
		var newWidth = width - axisMarginLeft * 2;
		for (info in this.axesInfo) {
			switch (info.rotation) {
				case 0:
					if (info.title == null) {
						continue;
					}
					if (info.title.position != null) {
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
					if (info.title.position != null) {
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
		// Repeat for subtitles
		for (info in this.axesInfo) {
			switch (info.rotation) {
				case 0:
					if (info.subTitle == null) {
						continue;
					}
					if (info.subTitle.position != null) {
						continue;
					}
					if (zeroPoint.y >= (height - axisMarginTop - titleMargin)) {
						newHeight = height - axisMarginTop * 2 - titleMargin * 2;
						zeroPoint.y = height - axisMarginTop - titleMargin * 2;
					}
				case 90:
					if (info.subTitle == null) {
						continue;
					}
					if (info.subTitle.position != null) {
						continue;
					}
					if (zeroPoint.x <= (axisMarginLeft + titleMargin)) {
						newWidth = width - axisMarginLeft * 2 - titleMargin * 2;
						zeroPoint.x = axisMarginLeft + titleMargin * 2;
					}
				case _:
			}
		}
		// Lastly set the start positions of the axes according to zeroPoint and newWidth or newHeight
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
				case 90:
					if (info.length != newHeight) {
						info.length = newHeight;
						info.start.y = zeroPoint.y;
					} else {
						info.start.y = height - axisMarginTop;
					}
					info.start.x = zeroPoint.x;
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
			var titlePos = info.start;
			var titleEnd = endPoint;
			var x = Math.round(Math.abs(info.start.x - endPoint.x));
			var y = Math.round(Math.abs(info.start.y - endPoint.y));
			if (info.title != null) {
				var titles = axis.findComponents("axis-title", Label);
				for (title in titles) {
					if (title.text != info.title.text) {
						continue;
					}
					setTitleRotation(title, info.title, info.rotation);
					if (info.title.position != null) {
						title.left = info.title.position.x;
						title.top = info.title.position.y;
						titlePos = new Point(title.left, title.top);
						titleEnd = new Point(title.width, title.height);
						break;
					}

					title.left = x == 0 ? (info.start.x - axis.titleMargin) : x / 2;
					title.top = y == 0 ? (info.start.y + axis.titleMargin) : y / 2;
					titlePos = new Point(title.left, title.top);
					titleEnd = new Point(title.width, title.height);
				}
			}
			if (info.subTitle != null) {
				var titles = axis.findComponents("axis-subtitle", Label);
				for (title in titles) {
					if (title.text != info.subTitle.text) {
						continue;
					}
					setTitleRotation(title, info.subTitle, info.rotation);
					if (info.subTitle.position != null) {
						title.left = info.subTitle.position.x;
						title.top = info.subTitle.position.y;
						break;
					}
					if (info.title == null) {
						title.left = x == 0 ? (info.start.x - axis.titleMargin) : x / 2;
						title.top = y == 0 ? (info.start.y + axis.titleMargin) : y / 2;
					} else {
						title.left = x == 0 ? titlePos.x - axis.titleMargin : titlePos.x - titleEnd.x / 2;
						title.top = y == 0 ? titlePos.y + axis.titleMargin : titlePos.y - titleEnd.y / 2;
					}
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

	function setTitleRotation(title:Label, titleInfo:AxisTitle, rotation:Int) {
		var titleRotation = titleInfo.rotation != null ? titleInfo.rotation : rotation;
		#if haxeui_heaps
		title.rotate(titleRotation * Math.PI / 180);
		#elseif haxeui_html5
		title.element.style.transform = "rotate(" + titleRotation + "deg)";
		title.element.style.transformOrigin = "0 0";
		#end
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
			var tickNum = tickInfo.tickNum;
			if (Std.isOfType(tickInfo, StringTickInfo)) {
				// Increase tickNum size so that positioning centers the ticks. Necessary because StringTickInfo has no zero Tick.
				tickNum++;
			}

			if (!isUpdate) {
				axis.ticksPerInfo[i] = [];
				// for (j in 0...tickInfo.tickNum) {
				// 	axis.ticksPerInfo[i].push(new Ticks());
				// }
				// axis.sub_ticks = [];
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
				var tick:Ticks = null;
				if (isUpdate) {
					tick = axis.ticksPerInfo[i][j];
				} else {
					tick = new Ticks(false, info.rotation);
				}
				var tickPoint = AxisTools.positionEndpoint(info.start, info.rotation, info.tickMargin + j * tickPos);
				tick.left = tickPoint.x;
				tick.top = tickPoint.y;
				if (tickInfo.zeroIndex == j && !info.showZeroTick) {
					tick.hidden = true;
				}
				tick.labelPosition = labelPosition;

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
				title.text = info.title.text;
				title.addClass("axis-title");
				titleLayer.addComponent(title);
			}
			if (info.subTitle != null) {
				var title = new Label();
				title.text = info.subTitle.text;
				title.addClass("axis-subtitle");
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
		_axis.positionStartPoint();
		_axis.setTicks(false);
		_axis.drawAxis();
	}

	override function validateComponentLayout():Bool {
		_tickCanvasLayer.componentGraphics.clear();
		_axis.positionStartPoint();
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
	}
}
