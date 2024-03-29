package hxchart.basics.legend;

import haxe.ui.geom.Point;

enum LegendPosition {
	topleft;
	topright;
}

class LegendTools {
	public static function calcPosition(width:Float, height:Float, chart_width:Float, chart_height:Float, margin:Float, padding:Float, align:LegendPosition) {
		switch align {
			case topright:
				var y = margin + height / 2;
				var x = chart_width - margin - width;
				return new Point(x, y);
			case topleft:
				var y = margin + height / 2;
				var x = margin;
				return new Point(x, y);
		}
	}

	public static function calcWidth(text_width:Float, chart_width:Float, padding:Float) {
		var init_width = text_width + 2 * padding;
		// if (init_width < (chart_width / 5)) {
		// 	return chart_width / 5;
		// }
		return init_width;
	}

	public static function calcHeight(title_height:Float, text_height:Float, group_num:Int, padding:Float):Float {
		var init_height = title_height * 1.25 + 8 + 1.25 * text_height * group_num + 8 * group_num + 2 * padding * 1.25;
		// if (init_height < 100) {
		// 	return 100;
		// }
		return init_height;
	}
}
