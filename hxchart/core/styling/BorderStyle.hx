package hxchart.core.styling;

/**
 * Styling of a border
 * 
 * @param thickness Optional. Thickness of the border.
 * @param alpha Optional. Alpha value of the color.
 * @param color Optional. Color
 */
@:structInit class BorderStyle {
	@:optional public var thickness:Any = 1;
	@:optional public var alpha:Any = 1;
	@:optional public var color:Any;
}
