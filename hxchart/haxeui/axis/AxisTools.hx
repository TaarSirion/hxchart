package hxchart.haxeui.axis;

import haxe.ui.containers.Absolute;
import haxe.ui.geom.Point;

class AxisTools {
	public static function addAxisToParent(axis:Axis, parent:Absolute) {
		var comp = parent.findComponent(axis.id);
		if (comp == null) {
			parent.addComponent(axis);
		}
	}

	public static function replaceAxisInParent(axis:Axis, parent:Absolute) {
		var comp = parent.findComponent(axis.id);
		if (comp == null) {
			parent.addComponent(axis);
		} else {
			parent.removeComponent(comp);
			parent.addComponent(axis);
		}
	}
}
