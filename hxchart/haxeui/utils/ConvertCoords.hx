package hxchart.haxeui.utils;

import hxchart.core.utils.Point;
import hxchart.core.coordinates.CoordinateSystem;

typedef HaxeUICoords = {
	zero:haxe.ui.geom.Point,
	width:Float,
	height:Float
}

class ConvertCoords {
	public static function convertFromCore(coreCoords:CoordinateSystem, thisCoords:HaxeUICoords, point:Point):haxe.ui.geom.Point {
		var x = thisCoords.zero.x + thisCoords.width * (point.x - coreCoords.start.x) / (coreCoords.end.x - coreCoords.start.x);
		var y = (thisCoords.zero.y + thisCoords.height) - thisCoords.height * (point.y - coreCoords.start.y) / (coreCoords.end.y - coreCoords.start.y);
		return new haxe.ui.geom.Point(x, y);
	}

	public static function convertSize(oldMin:Float, oldMax:Float, thisMax:Float, size:Float):Float {
		return thisMax * (size - oldMin) / (oldMax - oldMin);
	}
}
