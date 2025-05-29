package hxchart.haxeui.legend;

import haxe.ui.components.Spacer;
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
import hxchart.core.legend.LegendSymbols;

@:composite(Builder, LegendLayout)
class LegendNode extends HBox {
	@:style(layout) public var fontSize:Null<Float>;

	/**
	 * Symbol of the node. Default is rectangle.
	 */
	@:clonable @:behaviour(SymbolBehaviour, "rectangle") public var symbol:String;

	@:clonable @:behaviour(TextBehaviour) public var text:String;

	public var legendCanvas:Canvas;

	private var legend:Component;

	public var symbolColor:Color;
	public var textColor:Color;

	public function new(parent:Component, data:LegendNodeData) {
		legend = parent;
		super();

		text = data.text;
		symbolColor = data.style.symbolColor;
		symbol = data.style.symbol.getName();
	}

	private var _data:LegendNodeData = null;

	public var data(get, set):LegendNodeData;

	private function get_data():LegendNodeData {
		return _data;
	}

	private function set_data(value:LegendNodeData):LegendNodeData {
		text = value.text;
		symbolColor = value.style.symbolColor;
		symbol = value.style.symbol.getName();
		_data = value;
		return value;
	}

	public function drawSymbol(symbol:LegendSymbols) {
		legendCanvas.componentGraphics.clear();
		legendCanvas.componentGraphics.fillStyle(symbolColor);
		switch (symbol) {
			case LegendSymbols.point:
				legendCanvas.componentGraphics.circle(5, (fontSize * 1.25 + 4) / 2, 3);
			case LegendSymbols.rectangle:
				legendCanvas.componentGraphics.rectangle(2, 2, 8, 8);
			case LegendSymbols.line:
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
		node.drawSymbol(LegendSymbols.createByName(_value));
	}
}

@:dox(hide) @:noCompletion
private class TextBehaviour extends DataBehaviour {
	private override function validateData() {
		var label = _component.findComponent("legend-text", Label, null, "css");
		if (label != null) {
			label.text = _value;
			label.htmlText = _value;
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
		_label = new Label();
		_label.addClass("legend-text");
		_legendNode.legendCanvas = new Canvas();
		_legendNode.legendCanvas.addClass("legend-text-symbol");
		_legendNode.legendCanvas.height = 10;
		_legendNode.legendCanvas.width = 10;
		_legendNode.addComponent(_legendNode.legendCanvas);
		var spacer = new Spacer();
		spacer.width = 5;
		_legendNode.addComponent(spacer);
		_legendNode.addComponent(_label);
	}

	override function applyStyle(style:Style) {
		super.applyStyle(style);
		_legendNode.drawSymbol(LegendSymbols.createByName(_legendNode.symbol));
	}

	override function validateComponentData() {
		super.validateComponentData();
	}
}
