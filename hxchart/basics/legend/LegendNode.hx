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

	@:clonable @:behaviour(DefaultBehaviour, "point") public var symbol:String;

	@:clonable @:behaviour(TextBehaviour) public var text:String;

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
		color = value.color;
		fontSize = value.fontSize;
		_data = value;
		return value;
	}

	public function drawSymbol() {
		canvas.componentGraphics.clear();
		// if (legend.optionsDS.get(0).legend_symbol_filled) {
		// 	canvas.componentGraphics.rectangle(2, 2, 6, 6);
		// 	return;
		// }
		// switch legend.optionsDS.get(0).legend_symbol_type {
		// 	case point:

		canvas.componentGraphics.circle(5, (fontSize * 1.25 + 4) / 2, 3);
		// 	case line:
		// 		canvas.componentGraphics.moveTo(2, 5);
		// 		canvas.componentGraphics.lineTo(8, 5);
		// }
	}
}

@:dox(hide) @:noCompletion
private class LegendLayout extends DefaultLayout {
	override function resizeChildren() {
		super.resizeChildren();
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

	private function new(legendNode:LegendNode) {
		super(legendNode);
		_legendNode = legendNode;
		_legendNode.fontSize = 16;
		var label = new Label();
		label.addClass("legend-text");
		label.text = "Legend Text";
		label.customStyle.textAlign = "left";
		_legendNode.canvas = new Canvas();
		_legendNode.canvas.addClass("legend-text-symbol");
		_legendNode.canvas.height = _legendNode.fontSize * 1.25 + 4;
		_legendNode.addComponent(_legendNode.canvas);
		_legendNode.addComponent(label);
	}

	override function applyStyle(style:Style) {
		super.applyStyle(style);
		_legendNode.canvas.height = _legendNode.childComponents[1].height;
		var canvas = _component.findComponent("legend-text-symbol", Canvas, null, "css");
		if (canvas != null) {
			var node = cast(_component, LegendNode);
			canvas.componentGraphics.fillStyle(_legendNode.color);
			node.drawSymbol();
		}
	}
}
