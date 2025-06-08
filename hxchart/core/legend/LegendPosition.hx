package hxchart.core.legend;

enum LegendPosition {
	left;
	right;
	top;
	bottom;
	Point(x:Float, y:Float, vertical:Bool);
}
