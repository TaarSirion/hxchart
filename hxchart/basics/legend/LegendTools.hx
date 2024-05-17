package hxchart.basics.legend;

import haxe.ui.geom.Point;

enum LegendPosition {
	topleft;
	topright;
}

class LegendTools {
	public static function calcPosition(width:Float, height:Float, chart_width:Float, chart_height:Float, align:LegendPosition, marginTop:Float = 0,
			marginLeft:Float = 0, marginRight:Float = 0) {
		switch align {
			case topright:
				var y = marginTop;
				var x = chart_width - width - marginLeft;
				return new Point(x, y);
			case topleft:
				var y = marginTop;
				var x = marginRight;
				return new Point(x, y);
		}
	}
}
