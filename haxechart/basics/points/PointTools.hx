package basics.points;

import basics.ChartTools.AxisDist;

class PointTools {
	public static function calcXCoord(x_val:Float, max_num:Float, min_num:Float, zero_pos:Float, x_dist:AxisDist) {
		var x_ratio = x_val / max_num;
		var x = zero_pos + x_dist.pos_dist * x_ratio;
		if (x_val < 0) {
			x_ratio = x_val / min_num;
			x = zero_pos - x_dist.neg_dist * x_ratio;
		}
		return x;
	}

	public static function calcYCoord(y_val:Float, max_num:Float, min_num:Float, zero_pos:Float, y_dist:AxisDist) {
		var y_ratio = y_val / max_num;
		var y = zero_pos - y_dist.pos_dist * y_ratio;
		if (y_val < 0) {
			y_ratio = y_val / min_num;
			y = zero_pos + y_dist.neg_dist * y_ratio;
		}
		return y;
	}
}
