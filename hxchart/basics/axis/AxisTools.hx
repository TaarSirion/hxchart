package hxchart.basics.axis;

import haxe.ui.containers.Absolute;
import haxe.ui.geom.Point;

class AxisTools {
	/**
	 * Generate and position the new endpoint according to a strting point, rotation around that starting point and length from starting point.
	 * @param startPoint 
	 * @param rotation 
	 * @param length 
	 * 
	 * @return Point
	 */
	public static function positionEndpoint(startPoint:Point, rotation:Int, length:Float) {
		var endPoint = startPoint.sum(new Point(length, 0));
		var rad = rotation * Math.PI / 180;
		var s = Math.sin(rad);
		var c = Math.cos(rad);
		endPoint.x -= startPoint.x;
		endPoint.y -= startPoint.y;
		var x = endPoint.x * c - endPoint.y * s;
		var y = endPoint.x * s + endPoint.y * c;
		return new Point(x + startPoint.x, startPoint.y - y);
	}

	public static function addAxisToParent(axis:Axis, parent:Absolute) {
		var comp = parent.findComponent(axis.id);
		if (comp == null) {
			parent.addComponent(axis);
		}
	}

	public static function replaceAxisInParent(axis:Axis, parent:Absolute) {
		var comp = parent.findComponent(axis.id);
		if (comp == null) {
			parent.addComponent(axis);
		} else {
			parent.removeComponent(comp);
			parent.addComponent(axis);
		}
	}
}
