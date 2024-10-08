package hxchart.basics.points;

import hxchart.basics.pointchart.Chart.ChartInfo;
import hxchart.basics.axis.AxisInfo;
import haxe.ui.util.Variant;
import haxe.ui.behaviours.Behaviour;
import haxe.ui.components.Canvas;
import haxe.ui.core.CompositeBuilder;

@:composite(Builder)
class Points extends Canvas {
	@:call(AddPoint) public function addPoint(data:Point):Void;

	public var points:Array<Point>;

	public function new() {
		super();
		points = [];
	}

	public function setInfo(chartInfo:ChartInfo) {
		componentGraphics.clear();
		for (point in points) {
			point.setPosition(chartInfo);
			point.draw(this.componentGraphics);
		}
	}

	public function sortPoints() {
		var x_points = points.map(function(p) {
			return p.x_val;
		});
		var y_points = points.map(function(p) {
			return p.y_val;
		});
		return hxchart.basics.pointchart.ChartTools.sortPoints(x_points, y_points);
	}
}

class AddPoint extends Behaviour {
	public override function call(param:Any = null):Variant {
		var pointlayer:Points = cast(_component, Points);
		var point:Point = param;
		pointlayer.points.push(point);
		return null;
	}
}

class Builder extends CompositeBuilder {
	private var pointlayer:Points;

	public function new(_pointlayer:Points) {
		super(_pointlayer);
		pointlayer = _pointlayer;
	}
}
