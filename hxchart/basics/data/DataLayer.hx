package hxchart.basics.data;

import hxchart.basics.plot.Plot.TrailStyle;
import haxe.ui.util.Color;
import haxe.ui.components.Canvas;
import haxe.ui.containers.Absolute;

/**
 * Structure for data that can be used in a chart. Each data point is represented by one or multiple values.
 * 
 * This means the same index in the arrays corresponds to the same data point. So `xValues[0]` and `yValues[0]` are two values of the same data point.
 * @param xValues X values of the data. When this is not set it tries to get the values from `values` via the key specified in `chartinfo.x`. 
 * If neither are set, will throw an error.
 * @param yValues Y values of the data. When this is not set it tries to get the values from `values` via the key specified in `chartinfo.y`. 
 * If neither are set, will throw an error.
 * @param groups Group values. When this is not set it tries to get values from `values` via the key `groups`. If neither are set, it automaticall sets every entry to `"1"`.
 * @param values A map of data values. This is a map, because the keys can be used as information in the charts. Basically this mimics a table with named columns.
 */
typedef TrailData = {
	?xValues:Array<Dynamic>,
	?yValues:Array<Dynamic>,
	?groups:Array<String>,
	?values:Map<String, Array<Dynamic>>
}

interface DataLayer {
	public var id:String;
	public var data:Array<Data2D>;
	public var parent:Absolute;
	public var dataCanvas:Canvas;
	public var colors:Array<Color>;

	public function setData(newData:TrailData, style:TrailStyle):Void;
	public function positionData(style:TrailStyle):Void;
}
