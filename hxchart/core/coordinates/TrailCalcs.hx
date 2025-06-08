package hxchart.core.coordinates;

import hxchart.core.utils.Point;
import hxchart.core.tick.Tick;

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

	public static function calcScatterCoordinates(ticks:Array<Tick>, value:Float, useY:Bool) {
		var largerTicks = ticks.filter(tick -> Std.parseFloat(tick.text) >= value);
		var max = Std.parseFloat(largerTicks[0].text);
		var maxIndex = ticks.indexOf(largerTicks[0]);
		var minIndex = maxIndex == 0 ? 0 : maxIndex - 1;
		var min = Std.parseFloat(ticks[minIndex].text);
		if (max == min) {
			return useY ? ticks[minIndex].middlePos.y : ticks[minIndex].middlePos.x;
		}
		var tickLow = useY ? ticks[minIndex].middlePos.y : ticks[minIndex].middlePos.x;
		var tickHigh = useY ? largerTicks[0].middlePos.y : largerTicks[0].middlePos.x;
		return transformValueBetweenTicks(tickLow, tickHigh, value, min, max);
	}

	public static function getCategoricPosFromTick(value:String, ticks:Array<Tick>):Point {
		var ticksFiltered = ticks.filter(x -> {
			return x.text == value;
		});
		if (ticksFiltered == null || ticksFiltered.length == 0) {
			return null;
		}
		return ticksFiltered[0].middlePos;
	}
}
