package hxchart.basics.axis;

import hxchart.basics.ticks.Ticks.CompassOrientation;

class StringTickInfo implements TickInfo {
	public var tickNum:Int;
	public var tickDist:Float;
	public var zeroIndex:Int;
	public var labels:Array<String>;
	public var useSubTicks:Bool;
	public var subTickNum:Int;
	public var subLabels:Array<String>;
	public var subTicksPerPart:Int;
	public var labelPosition:CompassOrientation;

	public function new(values:Array<String>) {
		labels = [];
		labels.push("");
		zeroIndex = 0;
		setLabels(values);
		calcTickNum();
	}

	public function calcTickNum() {
		tickNum = labels.length;
	}

	public function setLabels(values:Array<String>) {
		for (label in values) {
			if (labels.indexOf(label) == -1) {
				labels.push(label);
			}
		}
	}
}
