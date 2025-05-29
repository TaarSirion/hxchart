package hxchart.core.axis;

import hxchart.core.tickinfo.StringTickInfo;
import hxchart.core.tickinfo.NumericTickInfo;
import haxe.Exception;
import hxchart.core.utils.Point;
import hxchart.core.tickinfo.TickInfo;

/**
 * Axis information. For each drawn axis.
 * Attention: The Axis object is a combination of multiple axis informations. Each axis information
 * draws a line on the canvas.
 * 
 * When supplying `values` beware of these differences based on `type`:
 * - linear: Only the first two values in the array will be used, to represent the min and max values of the axis.
 * - categorical: All values will be used.
 * 
 * The `setAxisInfo` function will try to automatically set the axis type, tick information and rotation. 
 * If no values are provided, it will throw an exception.
 * 
 * @param id ID of the axis.
 * @param rotation Rotation of the axis. Can be anything between 0 and 179. 0 is a horizontal axis, 90 is a vertical axis. 
 * Values equal or higher than 180 will be converted to 0-179. This happens to ensure no backwards drawn axes appear.
 * @param type Optional. Type of axis. The positioning of data depends on this. 
 * @param values Optional. Values the axis should have. Depending on the type, this will work differently.
 * @param tickInfo Optional. See hxchart.basics.axis.TickInfo for more information.
 * @param start Optional. The startpoint of the axis. This will get overwritten by the `positionStartPoint` function.
 * @param length Optional. The length of the drawn axis. This will get overwritten by the `positionStartPoint` function.
 * @param title Optional. A title for the drawn axis.
 * @param subTitle Optional. A subtitle for the drawn axis. Automatic positioning will place the subtitle centered below the title, 
 * before any rotation is applied to the title. This means it is possible for the subtitle to be not centered, after rotation.
 * @param tickMargin Optional. Margin in between ticks.
 * @param showZeroTick Optional. If the zero tick should be shown.
 */
@:structInit class AxisInfo {
	public var id:String;
	@:optional public var tickInfo:TickInfo;
	@:optional public var type:AxisTypes;
	@:optional public var values:Array<Any> = [];
	public var rotation:Int;
	@:optional public var start:Point;
	@:optional public var end:Point;
	@:optional public var length:Null<Float>;
	@:optional public var showZeroTick:Null<Bool>;
	@:optional public var title:AxisTitle;
	@:optional public var subTitle:AxisTitle;

	@:optional public var tickMargin:Float = 10;

	public function setAxisInfo(trailValues:Array<Any>) {
		if (trailValues.length == 0 && values.length == 0) {
			throw new Exception("Cannot set AxisInfo without values.");
		}
		trace(trailValues);
		if (type == null) {
			var firstValue = trailValues[0];
			if (firstValue is Int || firstValue is Float) {
				type = linear;
			} else if (firstValue is String) {
				type = categorical;
			}
		}
		var moduloRotation = Math.round(Math.abs(rotation % 360));
		rotation = moduloRotation >= 180 ? moduloRotation - 180 : moduloRotation;
		if (tickInfo != null) {
			return;
		}

		switch (type) {
			case linear:
				var min:Float = 0;
				var max:Float = 0;
				if (values != null && values.length >= 2) {
					min = values[0];
					max = values[1];
				} else {
					var dataValues = trailValues.copy();
					dataValues.sort(Reflect.compare);
					min = dataValues[0];
					max = dataValues[dataValues.length - 1];
				}
				tickInfo = new NumericTickInfo(["min" => [min], "max" => [max]]);
			case categorical:
				var dataValues:Array<String> = [];
				if (values == null || values.length == 0) {
					for (val in trailValues) {
						dataValues.push(val);
					}
				} else {
					for (val in values) {
						dataValues.push(val);
					}
				}
				tickInfo = new StringTickInfo(dataValues);
		}
	}
}
