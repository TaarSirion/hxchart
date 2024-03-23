package basics.legend;

import haxe.ui.geom.Point;

enum LegendPosition {
	left;
	right;
}

class LegendTools {
	public static function calcPosition(text_width:Float, text_height:Float, group_num:Int, chart_width:Float, chart_height:Float, margin:Float,
			padding:Float, align:LegendPosition) {
		var comp_height = (text_height + 3) * group_num + padding * 2;
		var y = chart_height / 2 - comp_height / 2;
		switch align {
			case right:
				var x = chart_width - margin - 2 * padding - text_width;
				return new Point(x, y);
			case left:
				var x = margin + padding;
				return new Point(x, y);
		}
	}
}
