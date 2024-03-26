package hxchart.basics.legend;

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

class Legend extends Absolute {
	private var options:Options;
	private var texts:Array<Label> = [];
	private var max_textlength:Float = 0;
	private var legend_title(default, set):String;
	private var colors:Array<Color> = [
		Color.fromString("black"),
		Color.fromString("blue"),
		Color.fromString("red"),
		Color.fromString("green"),
		Color.fromString("yellow"),
		Color.fromString("cyan")
	];

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
		legend_symbol_container = new Canvas();
		this.addClass("legendClass", true);
		this.styleSheet = new StyleSheet();
		this.styleSheet.parse(".legendClass{ 
				border: 1px solid black; 
				background-color: rgb(245, 245, 245);
			}
			.legendTitle {
				text-align: center;
			}
		");
		addComponent(legend_symbol_container);
		addComponent(legend_text_container);
		legend_title_label = new Label();
		legend_title_label.text = "Groups";
		legend_title_label.customStyle.fontSize = 20;
		legend_title_label.addClass("legendTitle");

		var x = new TextDisplay();
		x.parentComponent = legend_title_label;
		x.text = text;
		max_textlength = Math.max(max_textlength, x.textWidth);
	}

	public function addText(text:String) {
		var label = new Label();
		label.text = text;
		texts.push(label);
		var x = new TextDisplay();
		x.parentComponent = label;
		x.text = text;
		max_textlength = Math.max(max_textlength, x.textWidth);
	}

	public function draw(chart:Absolute) {
		legend_text_container.removeAllComponents();
		legend_symbol_container.componentGraphics.clear();
		var x = new TextDisplay();
		x.parentComponent = texts[0];
		x.text = text;

		width = LegendTools.calcWidth(max_textlength, chart.width, options.legend_padding);
		height = LegendTools.calcHeight(20, 16, texts.length, options.legend_padding);
		legend_text_container.height = height - 2 * options.legend_padding;
		legend_text_container.width = width - 2 * options.legend_padding;
		legend_text_container.left = options.legend_padding;
		legend_text_container.top = options.legend_padding;
		legend_symbol_container.height = this.height;
		legend_symbol_container.width = this.width;
		legend_title_label.width = legend_text_container.width;

		var coords = LegendTools.calcPosition(width, height, chart.width, chart.height, options.legend_margin, options.legend_padding, options.legend_align);
		this.left = coords.x;
		this.top = coords.y;

		chart.addComponent(this);
		legend_text_container.addComponent(legend_title_label);
		for (i => label in texts) {
			label.width = legend_text_container.width / 2;
			label.customStyle.fontSize = 16;
			label.customStyle.textAlign = "center";
			legend_text_container.addComponent(label);
			legend_symbol_container.componentGraphics.fillStyle(colors[i]);
			legend_symbol_container.componentGraphics.circle(options.legend_padding + 1 + legend_text_container.width / 8,
				options.legend_padding + 20 * 1.25 + 1.25 * 12 * (i + 1), 2);
		}
	}
}
