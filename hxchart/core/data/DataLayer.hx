package hxchart.core.data;

import hxchart.core.utils.ArrayTools;
import hxchart.core.trails.TrailTypes;
import hxchart.core.styling.TrailStyle;

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
@:structInit class TrailData {
	public var values:Map<String, Array<Any>>;

	public function setGroups(type:TrailTypes, group:String) {
		if (!values.exists("groups")) {
			var x = values.get("x");
			#if (haxe == "4.1.5")
			var groups:Array<Any> = [];
			for (val in x) {
				groups.push(val);
			}
			#else
			var groups = ArrayTools.repeat(group, x.length);
			#end
			switch (type) {
				case scatter:
					values.set("groups", groups);
				case line:
					values.set("groups", groups);
				case bar:
					values.set("groups", groups);
				case pie:
			}
		}
	}
}

interface DataLayer {
	public var data:Array<Any>;

	public function setData(newData:TrailData, style:TrailStyle):Void;
	public function positionData(style:TrailStyle):Void;
}
