package hxchart.basics.legend;

import haxe.ui.geom.Point;

enum LegendPosition {
	topleft;
	topright;
}

class LegendTools {
	public static function calcPosition(width:Float, height:Float, chart_width:Float, chart_height:Float, align:LegendPosition) {
		switch align {
			case topright:
				var y = 0;
				var x = chart_width - width;
				return new Point(x, y);
			case topleft:
				var y = 0;
				var x = 0;
				return new Point(x, y);
		}
	}
}
