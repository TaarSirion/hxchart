package hxchart.haxeui.trails;

import hxchart.core.coordinates.CoordinateSystem;
import hxchart.haxeui.utils.ConvertCoords;
import hxchart.core.chart.ChartStatus;
import hxchart.core.styling.PositionOptions;
import hxchart.core.tick.Tick;
import hxchart.core.utils.ChartTools;
import hxchart.core.utils.CompassOrientation;
import haxe.ui.geom.Point;
import hxchart.core.tickinfo.StringTickInfo;
import hxchart.core.tickinfo.NumericTickInfo;
import hxchart.core.tickinfo.TickInfo;
import haxe.Exception;
import hxchart.core.styling.TrailStyle;
import hxchart.haxeui.axis.Axis;
import haxe.ui.util.Color;
import haxe.ui.components.Canvas;
import hxchart.core.data.Data2D;
import haxe.ui.containers.Absolute;
import hxchart.core.trails.TrailInfo;
import hxchart.core.data.DataLayer;
import hxchart.core.axis.AxisLayer;
import hxchart.core.trails.Bar in BarCalc;

using hxchart.core.utils.ArrayTools;
using Lambda;

class Bar {
	public var id:String;

	public var parent:Absolute;
	public var dataCanvas:Canvas;
	public var colors:Array<Color>;
	public var axes:Axis;

	public var trailInfo:TrailInfo;
	public var axisID:String;

	public var barCalc:BarCalc;

	public function new(trailInfo:TrailInfo, axes:Axis, parent:Absolute, id:String, axisID:String, coordSystem:CoordinateSystem) {
		barCalc = new BarCalc(trailInfo, axes.axisCalc, coordSystem);
		barCalc.validateChart();

		valueGroups = [];
		xValues = [];
		yValues = [];

		this.parent = parent;
		dataCanvas = new Canvas();
		dataCanvas.id = id;
		dataCanvas.percentHeight = 100;
		dataCanvas.percentWidth = 100;
		this.id = id;
		if (axes != null) {
			this.axes = axes;
		}
		this.axisID = axisID;
		this.trailInfo = trailInfo;
	}

	public function validateChart(status:ChartStatus) {
		var canvasComponent = parent.findComponent(id, Canvas);
		if (canvasComponent != null) {
			dataCanvas = canvasComponent;
		}
		render(trailInfo.style);
	}

	var isXCategoric:Bool = false;
	var valueGroups:Array<Dynamic>;
	var xValues:Array<Dynamic>;
	var yValues:Array<Dynamic>;
	var groupNum:Int;

	public function render(style:TrailStyle):Void {
		var coordSystem = {
			zero: new Point(0, 0),
			width: parent.width,
			height: parent.height
		}
		dataCanvas.componentGraphics.clear();
		for (group in barCalc.dataByGroup) {
			for (dataRec in group) {
				if (!dataRec.allowed) {
					continue;
				}
				var coord = ConvertCoords.convertFromCore(barCalc.coordSystem, coordSystem, dataRec.coord);
				var width = ConvertCoords.convertSize(barCalc.coordSystem.start.x, barCalc.coordSystem.end.x, coordSystem.width, dataRec.width);
				var height = ConvertCoords.convertSize(barCalc.coordSystem.start.y, barCalc.coordSystem.end.y, coordSystem.height, dataRec.height);
				dataCanvas.componentGraphics.fillStyle(dataRec.color, dataRec.alpha);
				dataCanvas.componentGraphics.strokeStyle(dataRec.borderColor, dataRec.borderWidth, dataRec.borderAlpha);
				if (dataRec.values.x is Float) {
					dataCanvas.componentGraphics.rectangle(coord.x - width, coord.y - height, width, height);
				} else {
					dataCanvas.componentGraphics.rectangle(coord.x, coord.y, width, height);
				}
			}
		}
		var canvasComponent = parent.findComponent(id);
		if (canvasComponent == null) {
			parent.addComponent(dataCanvas);
		}
	};
}
