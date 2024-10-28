package hxchart.basics.axis;

import hxchart.basics.ticks.Ticks.CompassOrientation;

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

	public var subTickNum:Int;
	public var subLabels:Array<String>;
	public var subTicksPerPart:Int;
	public var labelPosition:CompassOrientation;

	function calcTickNum():Void;
	function setLabels(values:Array<String>):Void;
}
