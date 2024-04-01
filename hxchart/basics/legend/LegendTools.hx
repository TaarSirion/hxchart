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
				var y = margin;
				var x = chart_width - margin - width;
				return new Point(x, y);
			case topleft:
				var y = margin;
				var x = margin;
				return new Point(x, y);
		}
	}
}
