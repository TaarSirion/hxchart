package hxchart.basics.events;

import haxe.ui.events.MouseEvent;

@:structInit class EventHandler {
	@:optional public var hoverHandlers:Array<MouseEvent->Void>;
	@:optional public var clickHandlers:Array<MouseEvent->Void>;

	public function new() {
		hoverHandlers = [];
		clickHandlers = [];
	}
}
