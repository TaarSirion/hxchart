package hxchart.basics.trails;

import haxe.Exception;
import hxchart.basics.plot.Plot.AxisInfo;
import hxchart.basics.plot.Plot.TrailStyle;
import hxchart.basics.axis.Axis;
import haxe.ui.util.Color;
import haxe.ui.components.Canvas;
import hxchart.basics.data.Data2D;
import haxe.ui.containers.Absolute;
import hxchart.basics.plot.Plot.TrailInfo;
import hxchart.basics.data.DataLayer;
import hxchart.basics.axis.AxisLayer;

class Bar implements AxisLayer implements DataLayer {
	public var id:String;
	public var data:Array<Data2D>;
	public var parent:Absolute;
	public var dataCanvas:Canvas;
	public var colors:Array<Color>;
	public var axes:Array<Axis>;

	public var trailInfo:TrailInfo;

	public function new(trailInfo:TrailInfo, parent:Absolute, id:String, axisID:String) {
		if (trailInfo.axisInfo[0].type == linear && trailInfo.axisInfo[1].type == linear) {
			throw new Exception("It is not possible to use two 'linear' axes for a bar-chart. Please change one of them to 'categorical'.");
		}

		this.parent = parent;
		dataCanvas = new Canvas();
		dataCanvas.id = id;
		dataCanvas.percentHeight = 100;
		dataCanvas.percentWidth = 100;
		this.id = id;
		this.axisID = axisID;
		this.trailInfo = trailInfo;
	}

	public function setData(newData:TrailData, style:TrailStyle) {};

	public function positionData(style:TrailStyle):Void;

	public function positionAxes(axisInfo:Array<AxisInfo>, data:Array<Data2D>):Void;
}
