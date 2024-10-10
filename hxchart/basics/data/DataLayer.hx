package hxchart.basics.data;

import haxe.ui.components.Canvas;
import haxe.ui.containers.Absolute;

typedef AddDataType = {
	xValues:Array<Dynamic>,
	yValues:Array<Dynamic>,
	?groups:Array<String>
}

interface DataLayer {
	public var data:Array<Data2D>;
	public var dataLayer:Absolute;
	public var dataCanvas:Canvas;

	public function addData(data:AddDataType):Void;
	public function positionData():Void;
}
