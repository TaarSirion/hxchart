package hxchart.basics.axis;

import hxchart.basics.plot.Chart.TrailStyle;
import hxchart.basics.axis.Axis.AxisInfo;
import haxe.ui.containers.Absolute;

interface AxisLayer {
	public var axes:Array<Axis>;
	public var parent:Absolute;

	public function positionAxes(axisInfo:Array<AxisInfo>, data:Array<Any>, style:TrailStyle):Void;
}
