package hxchart.core.styling;

/**
 * Styling of a trail
 * @param colorPalette Color values in integer form. The length should be equal or greater than the length of `groups`. 
 * @param groups Mapping of groups from the data, 
 * @param positionOption Option on how to position data
 * @param size Optional. Set the size of points, pies etc.
 * @param alpha Optional. Alpha value of the color.
 * @param borderStyle Optional. Set this to use a border
 */
@:structInit class TrailStyle {
	@:optional public var colorPalette:Array<Int>;
	@:optional public var groups:Map<String, Int>;
	@:optional public var positionOption:PositionOption;
	@:optional public var size:Any;
	@:optional public var alpha:Any = 1;
	@:optional public var borderStyle:BorderStyle;
}
