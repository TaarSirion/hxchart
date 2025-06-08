package hxchart.haxeui.axis;

import hxchart.haxeui.utils.ConvertCoords;
import hxchart.core.utils.Trigonometry;
import haxe.ds.Vector;
import hxchart.core.utils.ArrayTools;
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
import hxchart.core.tick.Tick;
import haxe.ui.geom.Point;
import haxe.ui.behaviours.DefaultBehaviour;
import hxchart.core.axis.Axis in AxisCalc;
import hxchart.haxeui.utils.ConvertCoords.HaxeUICoords;
import hxchart.core.axis.AxisTitle;
import hxchart.core.axis.AxisInfo;
import hxchart.core.coordinates.CoordinateSystem;
#if haxeui_html5
import js.Browser;
import js.html.Element;
#end

@:composite(AxisBuilder, Layout)
class Axis extends Absolute {
	public var axisCalc:AxisCalc;

	public final TICKLENGTH:Int = 7;
	public final SUBTICKLENGTH:Int = 4;
	public final TICKFONTSIZE:Int = 10;
	public final SUBTICKFONTSIZE:Int = 6;

	/**
	 * Draw the axis and ticks on the canvas.
	 */
	@:call(Draw) public function drawAxis():Void;

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

	public function new(id:String, axisInfo:Array<AxisInfo>, coordSystem:CoordinateSystem, ?styleSheet:StyleSheet) {
		axisCalc = new AxisCalc(axisInfo, coordSystem);
		axisCalc.positionStartPoint();
		axisCalc.setTicks(false);

		axisColor = 0x000000;
		if (styleSheet != null) {
			axisStyleSheet = styleSheet;
			var rule = styleSheet.findRule(".axis");
			var colorRule = rule.directives.get("background-color");
			if (colorRule != null) {
				axisColor = Color.fromString(colorRule.value.getParameters()[0]);
			}
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

		var coordSystem = {
			zero: new Point(0, 0),
			width: axis.width,
			height: axis.height
		}

		for (i => info in axis.axisCalc.axesInfo) {
			var start = ConvertCoords.convertFromCore(axis.axisCalc.coordSystem, coordSystem, info.start);
			canvas.componentGraphics.strokeStyle(axis.axisColor);
			var endPoint = ConvertCoords.convertFromCore(axis.axisCalc.coordSystem, coordSystem, info.end);

			canvas.componentGraphics.moveTo(start.x, start.y);
			canvas.componentGraphics.lineTo(endPoint.x, endPoint.y);
			var titlePos = start;
			var titleEnd = endPoint;
			var x = Math.round(Math.abs(start.x - endPoint.x));
			var y = Math.round(Math.abs(start.y - endPoint.y));
			if (info.title != null) {
				var titles = axis.findComponents("axis-title", Label);
				for (title in titles) {
					if (title.text != info.title.text) {
						continue;
					}
					setTitleRotation(title, info.title, info.rotation);
					if (info.title.position != null) {
						var pos = ConvertCoords.convertFromCore(axis.axisCalc.coordSystem, coordSystem, info.title.position);
						title.left = pos.x;
						title.top = pos.y;
						titlePos = new Point(title.left, title.top);
						titleEnd = new Point(title.width, title.height);
						break;
					}

					title.left = x == 0 ? (start.x - axis.titleMargin) : x / 2;
					title.top = y == 0 ? (start.y + axis.titleMargin) : y / 2;
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
						var pos = ConvertCoords.convertFromCore(axis.axisCalc.coordSystem, coordSystem, info.subTitle.position);
						title.left = pos.x;
						title.top = pos.y;
						break;
					}
					if (info.title == null) {
						title.left = x == 0 ? (start.x - axis.titleMargin) : x / 2;
						title.top = y == 0 ? (start.y + axis.titleMargin) : y / 2;
					} else {
						title.left = x == 0 ? titlePos.x - axis.titleMargin : titlePos.x - titleEnd.x / 2;
						title.top = y == 0 ? titlePos.y + axis.titleMargin : titlePos.y - titleEnd.y / 2;
					}
				}
			}

			for (tick in axis.axisCalc.ticksPerInfo[i]) {
				if (tick.hidden) {
					continue;
				}
				var tickLength = tick.isSub ? axis.SUBTICKLENGTH : axis.TICKLENGTH;
				var convertedMiddle = ConvertCoords.convertFromCore(axis.axisCalc.coordSystem, coordSystem, tick.middlePos);
				var middlePoint = new hxchart.core.utils.Point(convertedMiddle.x, convertedMiddle.y);
				var start = Trigonometry.positionEndpoint(middlePoint, tick.tickRotation, tickLength / 2);
				var end = Trigonometry.positionEndpoint(middlePoint, tick.tickRotation + 180, tickLength / 2);
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
		for (info in _axis.axisCalc.axesInfo) {
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

	function addTicksToLayer() {
		for (i => info in _axis.axisCalc.axesInfo) {
			for (tick in _axis.axisCalc.ticksPerInfo[i]) {
				var label = new Label();
				label.text = tick.text;
				_tickLabelLayer.childComponents[0].addComponent(label);
			}
		}
	}

	override function validateComponentData() {
		_tickCanvasLayer.componentGraphics.clear();
		if (_axis.axisCalc.firstGen) {
			addTicksToLayer();
			_axis.axisCalc.firstGen = false;
		}
		var coordSystem = {
			zero: new Point(0, 0),
			width: _axis.width,
			height: _axis.height
		}
		var index = 0;
		for (i => info in _axis.axisCalc.axesInfo) {
			for (tick in _axis.axisCalc.ticksPerInfo[i]) {
				var label = cast(_tickLabelLayer.childComponents[0].childComponents[index], Label);
				positionTickLabel(tick, label, coordSystem);
				index++;
			}
		}
		_axis.drawAxis();
	}

	override function validateComponentLayout():Bool {
		_tickCanvasLayer.componentGraphics.clear();
		var coordSystem = {
			zero: new Point(0, 0),
			width: _axis.width,
			height: _axis.height
		}
		var index = 0;
		for (i => info in _axis.axisCalc.axesInfo) {
			for (tick in _axis.axisCalc.ticksPerInfo[i]) {
				var label = cast(_tickLabelLayer.childComponents[0].childComponents[index], Label);
				positionTickLabel(tick, label, coordSystem);
				index++;
			}
		}
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

	function positionTickLabel(_tick:Tick, _label:Label, coordSystem:HaxeUICoords) {
		var is_sub = _tick.isSub;
		var tickLength = is_sub ? _axis.SUBTICKLENGTH : _axis.TICKLENGTH;
		var tickFontsize = is_sub ? _axis.SUBTICKFONTSIZE : _axis.TICKFONTSIZE;
		var labelDistance = 8;

		var convertedMiddle = ConvertCoords.convertFromCore(_axis.axisCalc.coordSystem, coordSystem, _tick.middlePos);
		var middlePoint = new hxchart.core.utils.Point(convertedMiddle.x, convertedMiddle.y);

		_label.customStyle.fontSize = tickFontsize;
		switch (_tick.labelPosition) {
			case S:
				var labelPoint = Trigonometry.positionEndpoint(middlePoint, 90, tickLength / 2 + labelDistance);
				_label.left = labelPoint.x - _label.width / 2;
				_label.top = labelPoint.y - _label.height / 2;
			case N:
				var labelPoint = Trigonometry.positionEndpoint(middlePoint, 270, tickLength / 2 + labelDistance);
				_label.left = labelPoint.x - _label.width / 2;
				_label.top = labelPoint.y + _label.height;
			case E:
				var labelPoint = Trigonometry.positionEndpoint(middlePoint, 0, tickLength / 2 + labelDistance);
				_label.left = labelPoint.x + _label.width / 2;
				_label.top = labelPoint.y - _label.height / 2;
			case W:
				var labelPoint = Trigonometry.positionEndpoint(middlePoint, 180, tickLength / 2 + labelDistance);
				_label.left = labelPoint.x - _label.width / 2;
				_label.top = labelPoint.y - _label.height / 2;
			case NE:
				var labelPoint = Trigonometry.positionEndpoint(middlePoint, 90, tickLength / 2 + labelDistance);
				_label.left = labelPoint.x + _label.width / 2;
				_label.top = labelPoint.y + _label.height;
			case NW:
				var labelPoint = Trigonometry.positionEndpoint(middlePoint, 90, tickLength / 2 + labelDistance);
				_label.left = labelPoint.x - _label.width;
				_label.top = labelPoint.y + _label.height;
			case SE:
				var labelPoint = Trigonometry.positionEndpoint(middlePoint, 270, tickLength / 2 + labelDistance);
				_label.left = labelPoint.x + _label.width / 2;
				_label.top = labelPoint.y - _label.height / 2;
			case SW:
				var labelPoint = Trigonometry.positionEndpoint(middlePoint, 270, tickLength / 2 + labelDistance);
				_label.left = labelPoint.x - _label.width;
				_label.top = labelPoint.y - _label.height / 2;
		}
		_label.hidden = _tick.hidden;
	}
}
