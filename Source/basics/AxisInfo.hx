package basics;

import basics.ticks.Ticks;

typedef TickInfo = {
	num:Int,
	step:Int,
	min:Float,
	prec:Int,
	pos_ratio:Float,
	zero:Int,
}

typedef AxisInfo = {
	margin_bottom:Float,
	margin_left:Float,
	x_tick_info:TickInfo,
	y_tick_info:TickInfo,
	x_ticks:Array<Ticks>,
	y_ticks:Array<Ticks>,
}

typedef AxisDist = {
	pos_dist:Float,
	neg_dist:Float,
}

typedef AxisZeros = {
	x:Int,
	y:Int,
}
