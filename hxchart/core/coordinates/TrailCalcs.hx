package hxchart.core.coordinates;

import hxchart.core.utils.Point;
import hxchart.core.tick.Tick;

class TrailCalcs {
	/**
	 * Transforms a numerical value from a source range [min, max] to a target range [tickLow, tickHigh].
	 * This is essentially a linear interpolation. 
	 * Mostly used for interpolating a value from its original range to its coordinate position on one axis.
	 *
	 * @param tickLow The lower bound of the target range.
	 * @param tickHigh The upper bound of the target range.
	 * @param value The numerical value to transform.
	 * @param min The lower bound of the source range.
	 * @param max The upper bound of the source range.
	 * @return The transformed value in the target range.
	 */
	public static function transformValueBetweenTicks(tickLow:Float, tickHigh:Float, value:Float, min:Float, max:Float) {
		return tickLow + (tickHigh - tickLow) * (value - min) / (max - min);
	}

	/**
	 * Calculates the coordinate for a bar in a bar chart.
	 * It determines the position by interpolating the value between the zero-axis tick
	 * and the tick corresponding to the given value.
	 *
	 * @param ticks An array of `Tick` objects representing the axis ticks.
	 * @param value The numerical value for which to calculate the bar coordinate.
	 * @param zeroIndex The index of the tick that represents the zero value on the axis.
	 * @param useY A boolean indicating whether to calculate for the Y-axis (true) or X-axis (false).
	 * @return The calculated coordinate (either X or Y) for the bar.
	 */
	public static function calcBarCoordinates(ticks:Array<Tick>, value:Float, zeroIndex:Int, useY:Bool) {
		var largerTicks = ticks.filter(tick -> Std.parseFloat(tick.text) >= value);
		var max = Std.parseFloat(largerTicks[0].text);
		var maxIndex = ticks.indexOf(largerTicks[0]);
		var tickHigh = useY ? ticks[maxIndex].middlePos.y : ticks[maxIndex].middlePos.x;
		var tickLow = useY ? ticks[zeroIndex].middlePos.y : ticks[zeroIndex].middlePos.x;
		return transformValueBetweenTicks(tickLow, tickHigh, value, 0, max);
	}

	/**
	 * Calculates the coordinate for a point in a scatter plot.
	 * It determines the position by interpolating the value between the two nearest ticks
	 * that bracket the given value.
	 *
	 * @param ticks An array of `Tick` objects representing the axis ticks.
	 * @param value The numerical value for which to calculate the scatter plot coordinate.
	 * @param useY A boolean indicating whether to calculate for the Y-axis (true) or X-axis (false).
	 * @return The calculated coordinate (either X or Y) for the scatter plot point.
	 */
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

	/**
	 * Retrieves the middle position of a tick that corresponds to a given categoric value.
	 *
	 * @param value The string representation of the categoric value to find.
	 * @param ticks An array of `Tick` objects representing the axis ticks.
	 * @return A `Point` object representing the middle position (x, y) of the matching tick,
	 *         or `null` if no tick matches the given value.
	 */
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
