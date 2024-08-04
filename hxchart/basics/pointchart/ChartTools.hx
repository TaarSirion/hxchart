package hxchart.basics.pointchart;

typedef AxisDist = {
	pos_dist:Float,
	neg_dist:Float,
}

typedef ChartMinMax = {
	min_x:Float,
	max_x:Float,
	min_y:Float,
	max_y:Float
}

class ChartTools {
	public static function sortPoints(x_points:Array<Float>, y_points:Array<Float>):ChartMinMax {
		var x_points_copy = x_points.copy();
		var y_points_copy = y_points.copy();
		x_points_copy.sort(Reflect.compare);
		y_points_copy.sort(Reflect.compare);
		var min_x = x_points_copy.shift();
		var max_x = x_points_copy.pop();
		var min_y = y_points_copy.shift();
		var max_y = y_points_copy.pop();
		return {
			min_x: min_x,
			max_x: max_x,
			min_y: min_y,
			max_y: max_y
		};
	}

	public static function calcAxisLength(length:Float, marginStart:Float, marginEnd:Float) {
		return length - marginStart - marginEnd;
	}

	public static function setAxisStartPoint(marginStart:Float, axis_margin:Float, is_y:Bool, offset:Int = 15) {
		if (is_y) {
			return new haxe.ui.geom.Point(axis_margin + offset, marginStart);
		}
		return new haxe.ui.geom.Point(marginStart, axis_margin + offset);
	}

	public static function setAxisEndPoint(start_point:haxe.ui.geom.Point, axis_length:Float, is_y:Bool) {
		if (is_y) {
			return new haxe.ui.geom.Point(start_point.x, start_point.y + axis_length);
		}
		return new haxe.ui.geom.Point(start_point.x + axis_length, start_point.y);
	}

	public static function calcAxisDists(min_coord:Float, max_coord:Float, pos_ratio:Float):AxisDist {
		var dist = max_coord - min_coord;
		var pos_dist = dist * pos_ratio;
		var neg_dist = dist - pos_dist;
		return {pos_dist: pos_dist, neg_dist: neg_dist};
	}
}
