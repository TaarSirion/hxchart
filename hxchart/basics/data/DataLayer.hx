package hxchart.basics.data;

import hxchart.basics.axis.Axis;
import hxchart.basics.axis.TickInfo;
import haxe.ui.util.Color;
import haxe.ui.components.Canvas;
import haxe.ui.containers.Absolute;

typedef AddDataType = {
	xValues:Array<Dynamic>,
	yValues:Array<Dynamic>,
	?groups:Array<String>
}

interface DataLayer {
	public var id:String;
	public var data:Array<Data2D>;
	public var parent:Absolute;
	public var dataCanvas:Canvas;
	public var colors:Array<Color>;

	public function positionData():Void;
}
