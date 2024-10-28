package hxchart.basics.axis;

import hxchart.basics.plot.Plot.TrailStyle;
import hxchart.basics.plot.Plot.AxisInfo;
import hxchart.basics.data.Data2D;
import haxe.ui.containers.Absolute;

interface AxisLayer {
	public var axes:Array<Axis>;
	public var parent:Absolute;

	public function positionAxes(axisInfo:Array<AxisInfo>, data:Array<Data2D>, style:TrailStyle):Void;
}
