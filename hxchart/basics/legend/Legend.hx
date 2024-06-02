package hxchart.basics.legend;

import haxe.ui.util.Color;
import haxe.ui.styles.Style;
import haxe.ui.layouts.DefaultLayout;
import hxchart.basics.legend.LegendNode.LegendNodeData;
import haxe.ui.core.Component;
import haxe.ui.util.Variant;
import haxe.ui.behaviours.Behaviour;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.core.CompositeBuilder;
import hxchart.basics.legend.LegendTools.LegendPosition;
import haxe.ui.containers.VBox;
import haxe.ui.styles.StyleSheet;
import haxe.ui.components.Label;
import haxe.ui.behaviours.DefaultBehaviour;

enum LegendSymbols {
	point;
	line;
}

@:composite(Builder, LegendLayout)
class Legend extends VBox {
	@:clonable @:behaviour(DefaultBehaviour, 1) public var align:Null<Int>;
	@:clonable @:behaviour(DefaultBehaviour, 20) public var fontSizeTitle:Null<Int>;
	@:clonable @:behaviour(DefaultBehaviour, 16) public var fontSizeEntry:Null<Int>;

	@:clonable @:behaviour(TitleBehaviour) public var legendTitle:String;
	@:clonable @:behaviour(TextsBehaviour) public var legendTexts:Array<String>;

	@:call(AddNode) public function addNode(data:LegendNodeData):LegendNode;

	public var childNodes:Array<LegendNode>;

	public function new() {
		super();
	}
}

@:dox(hide) @:noCompletion
private class LegendLayout extends DefaultLayout {
	public override function repositionChildren() {
		var _legend:Legend = cast(_component, Legend);
		var width = _legend.width;
		var height = _legend.height;
		var layer = _legend.parentComponent;
		var coords = LegendTools.calcPosition(width, height, layer.width, layer.height, LegendPosition.createAll()[_legend.align]);
		_legend.left = coords.x;
		_legend.top = coords.y;
		trace("Repositin legend");
	}

	public override function resizeChildren() {
		trace("RESIZE LEGEND");
		var _legend:Legend = cast(_component, Legend);
		var width = _legend.width;
		var height = _legend.height;
		var layer = _legend.parentComponent;
		var coords = LegendTools.calcPosition(width, height, layer.width, layer.height, LegendPosition.createAll()[_legend.align]);
		_legend.left = coords.x;
		_legend.top = coords.y;
	}

	override function marginLeft(child:Component):Float {
		return super.marginLeft(child);
		trace("SETTING MARGIN LEFT");
	}

	override function set_component(value:Component):Component {
		return super.set_component(value);
		trace("Set component");
	}
}

@:dox(hide) @:noCompletion
private class TitleBehaviour extends DataBehaviour {
	private override function validateData() {
		var label = new Label();
		label.text = _value;
		label.addClass("legend-title");
		var textContainer = _component.findComponent("legend-container", VBox);
		if (textContainer != null) {
			textContainer.addComponentAt(label, 0);
		}
	}
}

@:dox(hide) @:noCompletion
private class TextsBehaviour extends DataBehaviour {
	private override function validateData() {
		var legend = cast(_component, Legend);
		if (legend != null) {
			for (i => value in _value.toArray()) {
				legend.addNode({text: value, color: Color.fromString("black"), fontSize: legend.fontSizeEntry});
			}
		}
	}
}

@:dox(hide) @:noCompletion
private class AddNode extends Behaviour {
	public override function call(param:Any = null):Variant {
		var legend = cast(_component, Legend);
		var node = new LegendNode(legend);
		node.data = param;
		legend.addComponent(node);
		legend.childNodes.push(node);
		return node;
	}
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
class Builder extends CompositeBuilder {
	private var _legend:Legend;
	private var _text_container:VBox;

	public function new(legend:Legend) {
		super(legend);
		_legend = legend;
		_legend.childNodes = [];
		_legend.addClass("legend-class");
		_text_container = new VBox();
		_text_container.id = "legend-container";
		_legend.addComponent(_text_container);
		setStyleSheet();
	}

	public override function addComponent(child:Component):Component {
		if (child is LegendNode) {
			return _text_container.addComponent(child);
		}
		return null;
	}

	private function setStyleSheet() {
		_legend.styleSheet = new StyleSheet();
		_legend.styleSheet.parse("
			.legend-class{ 
				border: 1px solid #000000;
				background-color: rgb(245, 245, 245);
				padding: 10px;
				font-family: Arial;
			}
			.legend-title {
				text-align: center;
				font-size: "
			+ _legend.fontSizeTitle
			+ "px;
			}
		");
	}

	override function applyStyle(style:Style) {
		super.applyStyle(style);
	}

	override function validateComponentLayout():Bool {
		return super.validateComponentLayout();
	}

	override function validateComponentData() {
		super.validateComponentData();
		var width = _legend.width;
		var height = _legend.height;
		var layer = _legend.parentComponent;
		var coords = LegendTools.calcPosition(width, height, layer.width, layer.height, LegendPosition.createAll()[_legend.align], _legend.marginTop,
			_legend.marginLeft, _legend.marginRight);
		_legend.left = coords.x;
		_legend.top = coords.y;
	}
}
