package hxchart.basics.legend;

import haxe.ui.containers.HBox;
import haxe.ui.components.Canvas;
import haxe.ui.containers.VBox;
import haxe.ui.themes.ThemeManager;
import haxe.ui.styles.Style;
import haxe.ui.styles.elements.MediaQuery;
import haxe.ui.styles.elements.ImportElement;
import haxe.ui.styles.elements.RuleElement;
import haxe.ui.styles.StyleSheet;
import haxe.ui.Toolkit;
import haxe.ui.core.TextDisplay;
import haxe.ui.styles.StyleLookupMap;
import haxe.ui.util.Color;
import haxe.ui.components.Label;
import hxchart.basics.Options;
import haxe.ui.containers.Absolute;

class Legend extends VBox {
	private var options:Options;
	private var texts:Array<Label> = [];
	private var max_textlength:Float = 0;
	private var legend_title(default, set):String;

	function set_legend_title(title:String) {
		return legend_title = title;
	}

	private var legend_title_label:Label;
	private var legend_text_container:VBox;
	private var legend_symbol_container:Canvas;

	public function new(options:Options) {
		super();
		this.options = options;
		legend_text_container = new VBox();
		this.addClass("legendClass", true);
		this.styleSheet = new StyleSheet();
		this.styleSheet.parse(".legendClass{ 
				border: 1px solid black; 
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
		legend_title_label = new Label();
		legend_title_label.text = "Groups";
		legend_title_label.customStyle.fontSize = 20;
		legend_title_label.addClass("legendTitle");

		var x = new TextDisplay();
		x.parentComponent = legend_title_label;
		x.text = text;
		max_textlength = Math.max(max_textlength, x.textWidth * 2);
	}

	public function addGroups(groups:Map<String, Int>) {
		for (key in groups.keys()) {
			addText(key);
		}
	}

	public function addText(text:String) {
		var label = new Label();
		label.customStyle.fontSize = 16;
		label.text = text;
		texts.push(label);
		var x = new TextDisplay();
		x.parentComponent = label;
		x.text = text;
		max_textlength = Math.max(max_textlength, x.textWidth * 1.6);
	}

	public function calcPosition(layer:Absolute) {
		var coords = LegendTools.calcPosition(width, height, layer.width, layer.height, options.legend_margin, options.legend_padding, options.legend_align);
		this.left = coords.x;
		this.top = coords.y;
		legend_title_label.width = width - 2 * options.legend_padding;
	}

	public function draw(chart:Absolute) {
		this.removeAllComponents(false);
		chart.addComponent(this);
		this.addComponent(legend_title_label);
		calcPosition(chart);

		for (i => label in texts) {
			var label_box = new HBox();
			label.customStyle.textAlign = "left";
			var canvas = new Canvas();
			canvas.width = 10;
			canvas.height = 16 * 1.25 + 4;
			label_box.addComponent(canvas);
			label_box.addComponent(label);
			this.addComponent(label_box);
			canvas.componentGraphics.fillStyle(options.point_color[i]);
			canvas.componentGraphics.circle(5, (16 * 1.25 + 4) / 2, 3);
		}
	}
}
