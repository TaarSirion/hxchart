package hxchart.basics.legend;

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

@:composite(Builder)
class Legend extends VBox {
	public var options(default, null):Options;

	@:call(AddNode) public function addNode(data:LegendNodeData):LegendNode;

	private var texts:Array<Label> = [];
	private var legend_texts:Array<String> = [];
	private var max_textlength:Float = 0;

	private var legend_title_label:Label;
	private var legend_text_container:VBox;

	public function new(options:Options) {
		super();
		if (!options.use_legend) {
			return;
		}
		this.options = options;
		legend_text_container = new VBox();
		this.addClass("legendClass", true);
		setStyleSheet();
		addComponent(legend_text_container);
		setTitle("Groups");
	}

	public function setTitle(title:String) {
		legend_title_label = new Label();
		legend_title_label.text = title;
		legend_title_label.customStyle.fontSize = options.legend_title_fontsize;
		legend_title_label.addClass("legendTitle");

		var x = new TextDisplay();
		x.parentComponent = legend_title_label;
		x.text = text;
		max_textlength = Math.max(max_textlength, x.textWidth * (options.legend_title_fontsize / 10));
	}

	public function setOptions(legend_options:LegendOptions) {
		options.setLegendOptions(legend_options);
		setStyleSheet();
	}

	private function setStyleSheet() {
		this.styleSheet = new StyleSheet();
		this.styleSheet.parse(".legendClass{ 
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
			}
			.legendTitle {
				text-align: center;
			}
		");
	}

	public function setGroups(groups:Map<String, Int>) {
		texts = [];
		for (key in groups.keys()) {
			addText(key);
		}
	}

	public function addGroups(groups:Map<String, Int>) {
		for (key in groups.keys()) {
			addText(key);
		}
	}

	public function addText(text:String) {
		var label = new Label();
		label.customStyle.fontSize = options.legend_text_fontsize;
		label.text = text;
		trace("Text ", text, options.legend_text_fontsize);
		texts.push(label);
		var x = new TextDisplay();
		x.parentComponent = label;
		x.text = text;
		max_textlength = Math.max(max_textlength, x.textWidth * (options.legend_text_fontsize / 10));
	}

	public function calcPosition(layer:Absolute) {
		var coords = LegendTools.calcPosition(width, height, layer.width, layer.height, options.legend_margin, options.legend_padding, options.legend_align);
		this.left = coords.x;
		this.top = coords.y;
		legend_title_label.width = width - 2 * options.legend_padding;
	}

	public function draw(chart:Absolute) {
		if (!options.use_legend) {
			return;
		}
		this.removeAllComponents(false);
		chart.addComponent(this);
		this.addComponent(legend_title_label);
		calcPosition(chart);

		for (i => label in texts) {
			var label_box = new HBox();
			label.customStyle.textAlign = "left";
			var canvas = new Canvas();
			canvas.width = 10;
			canvas.height = options.legend_text_fontsize * 1.25 + 4;
			label_box.addComponent(canvas);
			label_box.addComponent(label);
			this.addComponent(label_box);
			// drawSymbol(canvas, i);
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
		_text_container = new VBox();
		_legend.addComponent(_text_container);
	}

	public override function onReady() {
		var width = _legend.width;
		var height = _legend.height;
		var layer = _legend.parentComponent;
		var options = _legend.options;
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
