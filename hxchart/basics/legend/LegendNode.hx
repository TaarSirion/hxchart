package hxchart.basics.legend;

import haxe.ui.components.Button;
import haxe.ui.core.TextDisplay;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.styles.Style;
import haxe.ui.util.Variant;
import haxe.ui.core.Component;
import haxe.ui.util.Color;
import haxe.ui.components.Canvas;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.components.Label;
import haxe.ui.containers.HBox;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;

typedef LegendNodeData = {
	text:String,
	color:Color,
	fontSize:Int
}

@:composite(Builder, LegendLayout)
class LegendNode extends HBox {
	@:style(layout) public var fontSize:Null<Float>;

	/**
	 * Symbol of the node. Default is point.
	 */
	@:clonable @:behaviour(SymbolBehaviour, "rectangle") public var symbol:String;

	@:clonable @:behaviour(TextBehaviour) public var text:String;

	public var legendCanvas:Canvas;

	private var legend:Legend;

	public function new(parent:Legend) {
		legend = parent;
		super();
	}

	private var _data:LegendNodeData = null;

	public var data(get, set):LegendNodeData;

	private function get_data():LegendNodeData {
		return _data;
	}

	private function set_data(value:LegendNodeData):LegendNodeData {
		text = value.text;
		#if !(haxeui_flixel || haxeui_heaps)
		color = value.color;
		#else
		backgroundColor = value.color;
		#end
		fontSize = value.fontSize;
		_data = value;
		return value;
	}

	public function drawSymbol(symbol:String) {
		legendCanvas.componentGraphics.clear();
		#if !(haxeui_flixel || haxeui_heaps)
		legendCanvas.componentGraphics.fillStyle(color);
		#else
		legendCanvas.componentGraphics.fillStyle(backgroundColor);
		#end
		switch (symbol) {
			case "point":
				legendCanvas.componentGraphics.circle(5, (fontSize * 1.25 + 4) / 2, 3);
			case "rectangle":
				legendCanvas.componentGraphics.rectangle(2, 2, 6, 6);
			default:
				legendCanvas.componentGraphics.circle(5, (fontSize * 1.25 + 4) / 2, 3);
		}
	}
}

@:dox(hide) @:noCompletion
private class LegendLayout extends DefaultLayout {
	override function resizeChildren() {
		super.resizeChildren();
	}
}

@:dox(hide) @:noCompletion
private class SymbolBehaviour extends DataBehaviour {
	private override function validateData() {
		var node = cast(_component, LegendNode);
		var symbol:String = _value;
		node.drawSymbol(symbol);
	}
}

@:dox(hide) @:noCompletion
private class TextBehaviour extends DataBehaviour {
	private override function validateData() {
		var label = _component.findComponent("legend-text", Label, null, "css");
		if (label != null) {
			label.text = _value;
			label.htmlText = _value;
			var legend = cast(_component, LegendNode);
			label.customStyle.fontSize = legend.fontSize;
		}
	}
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class Builder extends CompositeBuilder {
	private var _legendNode:LegendNode;
	private var _label:Label;

	private function new(legendNode:LegendNode) {
		super(legendNode);
		_legendNode = legendNode;
		_legendNode.fontSize = 16;
		_label = new Label();
		_label.addClass("legend-text");
		_label.text = "Legend Text";
		_label.customStyle.textAlign = "left";
		_legendNode.legendCanvas = new Canvas();
		_legendNode.legendCanvas.addClass("legend-text-symbol");
		_legendNode.legendCanvas.height = _legendNode.fontSize * 1.25 + 4;
		_legendNode.addComponent(_legendNode.legendCanvas);
		_legendNode.addComponent(_label);
	}

	override function applyStyle(style:Style) {
		super.applyStyle(style);
		_legendNode.legendCanvas.height = _legendNode.childComponents[1].height;
		_legendNode.drawSymbol(_legendNode.symbol);
	}

	override function validateComponentData() {
		super.validateComponentData();
	}
}
