package hxchart.core.axis;

import hxchart.core.utils.Point;

/**
 * Information for drawing the axis title.
 * 
 * @param text Text of the title.
 * @param position Optional. Position of the title. If not provided, it will be centered underneath the axis.
 * @param rotation Optional. Rotation of the title. Will default to the axis rotation.
 */
typedef AxisTitle = {
	var text:String;
	@:optional var position:Point;
	@:optional var rotation:Int;
}
