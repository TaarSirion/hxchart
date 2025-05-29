package hxchart.core.utils;

class Trigonometry {
	/**
	 * Generate and position the new endpoint according to a strting point, rotation around that starting point and length from starting point.
	 * @param startPoint 
	 * @param rotation 
	 * @param length 
	 * 
	 * @return Point
	 */
	public static function positionEndpoint(startPoint:Point, rotation:Int, length:Float) {
		var endPoint = new Point(startPoint.x + length, startPoint.y + 0);
		var rad = rotation * Math.PI / 180;
		var s = Math.sin(rad);
		var c = Math.cos(rad);
		endPoint.x -= startPoint.x;
		endPoint.y -= startPoint.y;
		var x = endPoint.x * c - endPoint.y * s;
		var y = endPoint.x * s + endPoint.y * c;
		return new Point(x + startPoint.x, y + startPoint.y);
	}
}
