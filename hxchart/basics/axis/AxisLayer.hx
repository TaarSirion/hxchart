package hxchart.basics.axis;

import hxchart.basics.plot.Chart.TrailStyle;
import hxchart.basics.axis.Axis.AxisInfo;
import hxchart.basics.data.Data2D;
import haxe.ui.containers.Absolute;

interface AxisLayer {
	public var axes:Array<Axis>;
	public var parent:Absolute;

	public function positionAxes(axisInfo:Array<AxisInfo>, data:Array<Data2D>, style:TrailStyle):Void;
}
