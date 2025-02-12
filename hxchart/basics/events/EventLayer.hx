package hxchart.basics.events;

import haxe.ui.geom.Point;
import hxchart.basics.plot.Chart.BorderStyle;
import haxe.ui.util.Color;
import haxe.ui.events.MouseEvent;

@:structInit class EventHandler {
	@:optional public var hoverHandlers:Array<MouseEvent->Void>;
	@:optional public var clickHandlers:Array<MouseEvent->Void>;

	public function new() {
		hoverHandlers = [];
		clickHandlers = [];
	}
}

@:structInit class EventObject {
	public var coords:Array<Point>;
	public var color:Color;
	public var alpha:Float;
	public var border:BorderStyle;
	public var size:Float;
}

@:structInit class EventInfo {
	@:optional public var onHandle:EventObject->EventObject;
	@:optional public var onClick:EventObject->EventObject;
}
