package basics.legend;

import haxe.ui.util.Color;
import haxe.ui.components.Label;
import basics.Options;
import haxe.ui.containers.Absolute;

class Legend extends Absolute {
	var options:Options;
	var texts:Array<Label> = [];
	var max_textlength:Float = 0;

	public function new(options:Options) {
		super();
		this.options = options;
	}

	public function addText(text:String) {
		var label = new Label();
		label.text = text;
		texts.push(label);
		max_textlength = Math.max(max_textlength, label.width);
	}

	public function draw(chart:Absolute) {
		removeAllComponents();
		var coords = LegendTools.calcPosition(max_textlength, texts[0].height, texts.length, chart.width, chart.height, options.legend_margin,
			options.legend_padding, options.legend_align);
		this.left = coords.x;
		this.top = coords.y;
		width = max_textlength + 2 * options.legend_padding;
		height = texts[0].height * texts.length + 2 * options.legend_padding;
		customStyle.borderSize = 1;
		customStyle.borderColor = Color.fromString("black").toInt();

		for (i => label in texts) {
			label.left = options.legend_padding;
			label.top = options.legend_padding + label.height * i;
			addComponent(label);
		}
	}
}
