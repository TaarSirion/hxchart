package hxchart.basics.legend;

import haxe.ui.util.Variant;
import haxe.ui.core.Component;
import haxe.ui.util.Color;
import haxe.ui.components.Canvas;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.components.Label;
import haxe.ui.containers.HBox;
import haxe.ui.behaviours.DataBehaviour;

typedef LegendNodeData = {
	text:String,
	color:Color
}

@:composite(Builder)
class LegendNode extends HBox {
	@:clonable @:behaviour(TextBehaviour) public var text:String;
	@:clonable @:behaviour(ColorBehaviour) public var symbolColor:String;

	public var canvas:Canvas;

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
		trace(value.color);
		symbolColor = value.color.toHex();
		_data = value;
		return value;
	}

	public function drawSymbol() {
		canvas.componentGraphics.clear();
		if (legend.options.legend_symbol_filled) {
			canvas.componentGraphics.rectangle(2, 2, 6, 6);
			return;
		}
		switch legend.options.legend_symbol_type {
			case point:
				canvas.componentGraphics.circle(5, (legend.options.legend_text_fontsize * 1.25 + 4) / 2, 3);
			case line:
				canvas.componentGraphics.moveTo(2, 5);
				canvas.componentGraphics.lineTo(8, 5);
		}
	}
}

@:dox(hide) @:noCompletion
private class TextBehaviour extends DataBehaviour {
	private override function validateData() {
		var label = _component.findComponent("legend-text", Label, null, "css");
		if (label != null) {
			label.text = _value;
		}
	}
}

@:dox(hide) @:noCompletion
private class ColorBehaviour extends DataBehaviour {
	private override function validateData() {
		var canvas = _component.findComponent("legend-text-symbol", Canvas, null, "css");
		if (canvas != null) {
			var node = cast(_component, LegendNode);
			canvas.componentGraphics.fillStyle(Color.fromString(_value));
			node.drawSymbol();
		}
	}
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class Builder extends CompositeBuilder {
	private var _legendNode:LegendNode;

	private function new(legendNode:LegendNode) {
		super(legendNode);
		_legendNode = legendNode;

		var label = new Label();
		label.addClass("legend-text");
		label.text = "Legend Text";
		label.customStyle.textAlign = "left";
		_legendNode.canvas = new Canvas();
		_legendNode.canvas.addClass("legend-text-symbol");
		_legendNode.canvas.width = 10;
		trace("L", label.height);
		_legendNode.canvas.height = _legendNode.legend.options.legend_text_fontsize * 1.25 + 4;
		_legendNode.addComponent(_legendNode.canvas);
		_legendNode.addComponent(label);
	}
}
