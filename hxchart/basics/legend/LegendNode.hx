package hxchart.basics.legend;

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
	@:clonable @:behaviour(ColorBehaviour) public var color:Color;

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
		if (value == _data) {
			return value;
		}

		_data = value;
		invalidateComponentData();
		return value;
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
			canvas.componentGraphics.fillStyle(_value);
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
		_legendNode.canvas.height = _legendNode.legend.options.legend_text_fontsize * 1.25 + 4;
		_legendNode.addComponent(_legendNode.canvas);
		_legendNode.addComponent(label);
	}
}
