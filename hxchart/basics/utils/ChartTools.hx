package hxchart.basics.utils;

typedef AxisDist = {
	pos_dist:Float,
	neg_dist:Float,
}

class ChartTools {
	public static function calcAxisDists(min_coord:Float, max_coord:Float, pos_ratio:Float):AxisDist {
		var dist = max_coord - min_coord;
		var pos_dist = dist * pos_ratio;
		var neg_dist = dist - pos_dist;
		return {pos_dist: pos_dist, neg_dist: neg_dist};
	}
}
