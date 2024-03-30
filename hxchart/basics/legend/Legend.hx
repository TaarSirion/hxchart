package hxchart.basics.legend;

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

class Legend extends VBox {
	private var options:Options;

	private var texts:Array<Label> = [];
	private var max_textlength:Float = 0;

	private var legend_title_label:Label;
	private var legend_text_container:VBox;
	private var legend_symbol_container:Canvas;

	public function new(options:Options) {
		super();
		if (!options.use_legend) {
			return;
		}
		this.options = options;
		legend_text_container = new VBox();
		this.addClass("legendClass", true);
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
			drawSymbol(canvas, i);
		}
	}

	private function drawSymbol(canvas:Canvas, i:Int) {
		canvas.componentGraphics.fillStyle(options.point_color[i]);
		if (options.legend_symbol_filled) {
			canvas.componentGraphics.rectangle(2, 2, 6, 6);
			return;
		}
		switch options.legend_symbol_type {
			case point:
				canvas.componentGraphics.circle(5, (options.legend_text_fontsize * 1.25 + 4) / 2, 3);
			case line:
				canvas.componentGraphics.moveTo(2, 5);
				canvas.componentGraphics.lineTo(8, 5);
		}
	}
}
