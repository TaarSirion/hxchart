package hxchart.haxeui.utils;

import hxchart.core.utils.Point;
import hxchart.core.utils.CoordinateSystem;

typedef HaxeUICoords = {
	zero:haxe.ui.geom.Point,
	width:Float,
	height:Float
}

class ConvertCoords {
	public static function convertFromCore(coreCoords:CoordinateSystem, thisCoords:HaxeUICoords, point:Point):haxe.ui.geom.Point {
		var x = thisCoords.zero.x + thisCoords.width * (point.x - coreCoords.left) / (coreCoords.width - coreCoords.left);
		var y = (thisCoords.zero.y + thisCoords.height) - thisCoords.height * (point.y - coreCoords.bottom) / (coreCoords.height - coreCoords.bottom);
		return new haxe.ui.geom.Point(x, y);
	}
}
