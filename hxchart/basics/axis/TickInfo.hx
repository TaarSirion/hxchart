package hxchart.basics.axis;

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

	function calcTickNum():Void;
	function setLabels(values:Array<String>):Void;
}
