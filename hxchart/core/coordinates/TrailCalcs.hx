package hxchart.core.coordinates;

import hxchart.core.tick.Tick;
import hxchart.core.trails.Bar.BarDataRec;

class TrailCalcs {
	public static function transformValueBetweenTicks(tickLow:Float, tickHigh:Float, value:Float, min:Float, max:Float) {
		return tickLow + (tickHigh - tickLow) * (value - min) / (max - min);
	}

	public static function calcBarCoordinates(ticks:Array<Tick>, value:Float, zeroIndex:Int, useY:Bool) {
		var largerTicks = ticks.filter(tick -> Std.parseFloat(tick.text) >= value);
		var max = Std.parseFloat(largerTicks[0].text);
		var maxIndex = ticks.indexOf(largerTicks[0]);
		var tickHigh = useY ? ticks[maxIndex].middlePos.y : ticks[maxIndex].middlePos.x;
		var tickLow = useY ? ticks[zeroIndex].middlePos.y : ticks[zeroIndex].middlePos.x;
		return transformValueBetweenTicks(tickLow, tickHigh, value, 0, max);
	}
}
