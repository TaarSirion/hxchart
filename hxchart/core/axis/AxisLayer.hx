package hxchart.core.axis;

import hxchart.core.styling.TrailStyle;

interface AxisLayer {
	public var axes:Axis;

	public function positionAxes(axisInfo:Array<AxisInfo>, style:TrailStyle):Void;
}
