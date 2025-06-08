package hxchart.core.events;

import hxchart.core.utils.Point;
import hxchart.core.styling.BorderStyle;

@:structInit class EventHandler {
	@:optional public var hoverHandlers:Array<Any->Void>;
	@:optional public var clickHandlers:Array<Any->Void>;

	public function new() {
		hoverHandlers = [];
		clickHandlers = [];
	}
}

@:structInit class EventObject {
	public var coords:Array<Point>;
	public var color:Int;
	public var alpha:Float;
	public var border:BorderStyle;
	public var size:Float;
}

@:structInit class EventInfo {
	@:optional public var onHover:EventObject->EventObject;
	@:optional public var onClick:EventObject->EventObject;
}
