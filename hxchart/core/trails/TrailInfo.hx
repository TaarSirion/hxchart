package hxchart.core.trails;

import haxe.Exception;
import hxchart.core.events.EventLayer.EventInfo;
import hxchart.haxeui.plot.Chart.OptimizationInfo;
import hxchart.core.axis.AxisInfo;
import hxchart.core.styling.TrailStyle;
import hxchart.core.data.DataLayer.TrailData;

/**
 * Information about a trail.
 * 
 * Beware `axisInfo` is mandatory for some types of trails:
 * - scatter
 * - bar
 * @param data The data that should be shown. 
 * @param type Type of trail that should be used.
 * @param x Optional. Key of the x values. This is necessary for `type = scatter` when only `data.values` is set.
 * @param y Optional. Key of the y values. This is necessary for `type = scatter` when only `data.values` is set.
 * @param style Optional. Style of the trail. Beware, this will reset if an additional trail is added to the plot, to keep styling consistent.
 * @param axisInfo Optional. Information about the axes. Technically it is possible to give every trail their own axes, resulting in multiple sub-plots (currently not implemented).
 * @param optimizationInfo Optional. Drawing large amounts of data might need some kind of optimization, which can be set through this info. Be careful with the usage, as some options might result in a different looking plot/chart.
 */
@:structInit class TrailInfo {
	public var data:TrailData;
	public final type:TrailTypes;
	@:optional public var style:TrailStyle;
	@:optional public var axisInfo:Null<Array<AxisInfo>>;
	@:optional public var optimizationInfo:OptimizationInfo;
	@:optional public var events:EventInfo;

	public function validate() {
		switch (type) {
			case scatter:
				if (data.values == null) {
					throw new Exception("No data available. Please set some data in trailInfo.data.values");
				}
				if (!data.values.exists("x") || !data.values.exists("y")) {
					throw new Exception("No data available. Please set 'x' and 'y' as keys in trailInfo.data.values.");
				}
				if (data.values.get("x").length != data.values.get("y").length) {
					throw new Exception("'x' and 'y' need to be the same length.");
				}
			case line:
				if (data.values == null) {
					throw new Exception("No data available. Please set some data in trailInfo.data.values");
				}
				if (!data.values.exists("x") || !data.values.exists("y")) {
					throw new Exception("No data available. Please set 'x' and 'y' as keys in trailInfo.data.values.");
				}
				if (data.values.get("x").length != data.values.get("y").length) {
					throw new Exception("'x' and 'y' need to be the same length.");
				}
			case bar:
				if (data.values == null) {
					throw new Exception("No data available. Please set some data in trailInfo.data.values");
				}
				if (!data.values.exists("x") || !data.values.exists("y")) {
					throw new Exception("No data available. Please set 'x' and 'y' as keys in trailInfo.data.values.");
				}
				if (data.values.get("x").length != data.values.get("y").length) {
					throw new Exception("'x' and 'y' need to be the same length.");
				}
			case pie:
		}
	}
}
