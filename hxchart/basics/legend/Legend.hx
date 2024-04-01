package hxchart.basics.legend;

import haxe.ui.layouts.DefaultLayout;
import haxe.ui.data.ListDataSource;
import haxe.ui.data.DataSource;
import hxchart.basics.legend.LegendNode.LegendNodeData;
import haxe.ui.core.Component;
import haxe.ui.util.Variant;
import haxe.ui.behaviours.Behaviour;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.util.Color;
import hxchart.basics.legend.LegendTools.LegendPosition;
import haxe.ui.containers.HBox;
import haxe.ui.components.Canvas;
import haxe.ui.containers.VBox;
import haxe.ui.styles.StyleSheet;
import haxe.ui.core.TextDisplay;
import haxe.ui.components.Label;
import hxchart.basics.Options;
import haxe.ui.containers.Absolute;

enum LegendSymbols {
	point;
	line;
}

typedef LegendOptions = {
	?alignment:LegendPosition,
	?border_style:String,
	?border_size:Int,
	?border_color:Color,
	?title_fontsize:Int,
	?text_fontsize:Int,
	?fontfamily:String,
	?symbold_filled:Bool,
	?symbol_type:LegendSymbols,
	?margin:Float,
	?padding:Float
}

@:composite(Builder, LegendLayout)
class Legend extends VBox {
	@:behaviour(OptionsBehaviour) public var optionsDS:DataSource<Options>;
	@:behaviour(TitleBehaviour) public var legendTitle:String;

	@:call(AddNode) public function addNode(data:LegendNodeData):LegendNode;

	public function new(options:Options) {
		super();
		if (!options.use_legend) {
			return;
		}
		trace("Before Opt");
		optionsDS.add(options);
	}

	public function setOptions(legend_options:LegendOptions) {
		optionsDS.get(0).setLegendOptions(legend_options);
	}
}

@:dox(hide) @:noCompletion
private class LegendLayout extends DefaultLayout {
	public override function repositionChildren() {
		var _legend:Legend = cast(_component, Legend);
		var width = _legend.width;
		var height = _legend.height;
		var layer = _legend.parentComponent;
		var options = _legend.optionsDS.get(0);
		var coords = LegendTools.calcPosition(width, height, layer.width, layer.height, options.legend_margin, options.legend_padding, options.legend_align);
		_legend.left = coords.x;
		_legend.top = coords.y;
	}
}

@:dox(hide) @:noCompletion
private class OptionsBehaviour extends DataBehaviour {
	override function set(value:Variant) {
		trace("Value", value);
		super.set(value);
	}

	private override function validateData() {
		var optionDS:DataSource<Options> = _value;
		if (optionDS.get(0) != null) {
			setStyleSheet(optionDS.get(0));
		}
	}

	private function setStyleSheet(options:Options) {
		_component.styleSheet = new StyleSheet();
		_component.styleSheet.parse("
		.legend-class{ 
				border: "
			+ options.legend_border_size
			+ "px "
			+ options.legend_border_style
			+ " "
			+ options.legend_border_color.toHex()
			+ "; 
				background-color: rgb(245, 245, 245);
				margin: "
			+ options.legend_margin
			+ ";
				padding: "
			+ options.legend_padding
			+ ";
			font-family: "
			+ options.legend_fontfamily
			+ ";
			}
			.legend-title {
				text-align: center;
				font-size: "
			+ options.legend_title_fontsize
			+ ";
			}
			.legend-text {
				font-size: "
			+ options.legend_text_fontsize
			+ ";
			}
		");
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
private class AddNode extends Behaviour {
	public override function call(param:Any = null):Variant {
		var legend = cast(_component, Legend);
		var node = new LegendNode(legend);
		node.data = param;
		legend.addComponent(node);
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
		_legend.addClass("legend-class");
		_legend.optionsDS = new ListDataSource();
		_text_container = new VBox();
		_text_container.id = "legend-container";
		_legend.addComponent(_text_container);
	}

	public override function onReady() {
		var width = _legend.width;
		var height = _legend.height;
		var layer = _legend.parentComponent;
		var options = _legend.optionsDS.get(0);
		var coords = LegendTools.calcPosition(width, height, layer.width, layer.height, options.legend_margin, options.legend_padding, options.legend_align);
		_legend.left = coords.x;
		_legend.top = coords.y;
	}

	public override function addComponent(child:Component):Component {
		if (child is LegendNode) {
			return _text_container.addComponent(child);
		}
		return null;
	}
}
