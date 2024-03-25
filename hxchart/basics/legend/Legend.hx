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

		this.customStyle.backgroundColor = Color.fromComponents(240, 240, 240, 1).toInt();
		this.customStyle.borderSize = 1;
		this.customStyle.borderStyle = "dashed";
		this.customStyle.borderColor = Color.fromString("black").toInt();
		this.invalidateComponentStyle();
		trace(customStyle.hasBorder, customStyle.borderType);
		addComponent(legend_symbol_container);
		legend_symbol_container.height = this.height;
		legend_symbol_container.width = this.width;

		addComponent(legend_text_container);
		legend_title_label = new Label();
		legend_title_label.text = "Groups";
		legend_title_label.customStyle.fontSize = 20;
		legend_title_label.customStyle.textAlign = "center";
		legend_title_label.invalidateComponentStyle();

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
		var x = new TextDisplay();
		x.parentComponent = texts[0];
		x.text = text;

		width = LegendTools.calcWidth(max_textlength, chart.width, options.legend_padding);
		height = LegendTools.calcHeight(legend_title_label.customStyle.fontSize, 16, texts.length, options.legend_padding);
		var coords = LegendTools.calcPosition(width, height, chart.width, chart.height, options.legend_margin, options.legend_padding, options.legend_align);
		this.left = coords.x;
		this.top = coords.y;

		chart.addComponent(this);
		legend_text_container.addComponent(legend_title_label);
		for (i => label in texts) {
			// label.left = options.legend_padding;
			// label.top = options.legend_padding + label.height * i;
			label.customStyle.fontSize = 16;
			label.customStyle.textAlign = "right";
			label.invalidateComponentStyle();
			legend_text_container.addComponent(label);
		}
	}
}
