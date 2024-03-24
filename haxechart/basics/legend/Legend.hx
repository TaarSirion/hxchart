package basics.legend;

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
import basics.Options;
import haxe.ui.containers.Absolute;

@:build(haxe.ui.ComponentBuilder.build("Assets/legend.xml"))
class Legend extends Absolute {
	var options:Options;
	var texts:Array<Label> = [];
	var max_textlength:Float = 0;
	var legend_title:Label;

	public function new(options:Options) {
		super();
		this.options = options;
		legend_title = new Label();
		legend_title.text = "Groups";
		legend_title.customStyle.fontSize = 20;
		var x = new TextDisplay();
		x.parentComponent = legend_title;
		x.text = text;
		trace(x.textHeight);
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
		legendContainer.removeAllComponents();
		var x = new TextDisplay();
		x.parentComponent = texts[0];
		x.text = text;

		width = LegendTools.calcWidth(max_textlength, chart.width, options.legend_padding);
		height = LegendTools.calcHeight(legend_title.customStyle.fontSize, 16, texts.length, options.legend_padding);
		var coords = LegendTools.calcPosition(width, height, chart.width, chart.height, options.legend_margin, options.legend_padding, options.legend_align);
		this.left = coords.x;
		this.top = coords.y;

		chart.addComponent(this);
		legendContainer.addComponent(legend_title);
		for (i => label in texts) {
			// label.left = options.legend_padding;
			// label.top = options.legend_padding + label.height * i;
			label.customStyle.fontSize = 16;
			legendContainer.addComponent(label);
			trace("Text Display", label.getTextDisplay().width, label.getTextDisplay().textWidth, label.width, label.componentWidth);
		}
	}
}
