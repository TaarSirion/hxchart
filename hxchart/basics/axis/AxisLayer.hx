package hxchart.basics.axis;

import hxchart.basics.data.Data2D;
import haxe.ui.containers.Absolute;

interface AxisLayer {
	public var tickInfos:Array<TickInfo>;
	public var axes:Array<Axis>;
	public var axisLayer(default, set):Absolute;

	public function positionAxes(data:Array<Data2D>):Void;
	public function styleAxes():Void;
}
