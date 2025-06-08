package hxchart.core.tickinfo;

import hxchart.core.utils.CompassOrientation;

interface TickInfo {
	public var tickNum:Int;
	public var tickDist:Float;
	public var zeroIndex:Int;

	/**
	 * Tick Labels. Depending on the info type, this will be set automatically or has to be set manually.
	 */
	public var labels:Array<String>;

	/**
	 * If subticks should be used.
	 */
	public var useSubTicks:Bool;

	/**
	 * Number of subticks.
	 */
	public var subTickNum:Int;

	/**
	 * Subtick labels.
	 */
	public var subLabels:Array<String>;

	/**
	 * Number of subticks per tick.
	 */
	public var subTicksPerPart:Int;

	/**
	 * Orientation of the labels. South means directly below the tick, while East means to the right of the tick, and so forth.
	 */
	public var labelPosition:CompassOrientation;

	/**
	 * Calculate the number of ticks.
	 */
	function calcTickNum():Void;

	/**
	 * Set the labels of ticks
	 * @param values Depending on the implementation, this can be an array of strings or empty.
	 */
	function setLabels(values:Array<String>):Void;
}
