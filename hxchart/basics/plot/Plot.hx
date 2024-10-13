package hxchart.basics.plot;

import haxe.ui.util.Variant;
import haxe.ui.behaviours.Behaviour;
import hxchart.basics.axis.Axis;
import hxchart.basics.pointchart.Scatter;
import hxchart.basics.data.DataLayer.AddDataType;
import haxe.ui.core.CompositeBuilder;
import haxe.Exception;
import hxchart.basics.axis.Axis.AxisTypes;
import hxchart.basics.data.Data2D;
import hxchart.basics.legend.Legend;
import haxe.ui.containers.Absolute;

enum ChartTypes {
	scatter;
	bar;
	pie;
}

typedef AxisInfo = {
	type:AxisTypes,
	?axis:Axis,
	?values:Array<Dynamic>
}

typedef ChartInfo = {
	data:AddDataType,
	type:ChartTypes,
	?axisInfo:Array<AxisInfo>
}

@:composite(Builder)
class Plot extends Absolute {
	public var chartInfos:Array<ChartInfo>;

	public var plotBody:Absolute;
	public var axes:Map<String, Array<Axis>>;
	public var legend:Legend;

	public function new(chartInfo:ChartInfo, width:Float, height:Float, ?legend:Legend) {
		super();
		chartInfos = [];
		axes = new Map();
		chartInfos.push(chartInfo);
		if (legend != null) {
			this.legend = legend;
		}
	}

	@:call(AddChart) public function addChart(chartInfo:ChartInfo):Void;
}

@:dox(hide) @:noCompletion
private class AddChart extends Behaviour {
	public override function call(param:Any = null):Variant {
		var plot = cast(_component, Plot);
		var chartInfo:ChartInfo = param;
		trace(chartInfo);
		plot.chartInfos.push(chartInfo);
		trace("ADDED CHART INFO");
		return null;
	}
}

class Builder extends CompositeBuilder {
	var _plot:Plot;

	public function new(plot:Plot) {
		super(plot);
		_plot = plot;
		_plot.plotBody = new Absolute();
		_plot.plotBody.percentHeight = 100;
		_plot.plotBody.percentWidth = 100;
		_plot.addComponent(_plot.plotBody);
	}

	override function validateComponentData() {
		super.validateComponentData();
		_plot.axes = new Map();
		var axisID = "axis_0";
		trace(_plot.chartInfos);

		for (i => chartInfo in _plot.chartInfos) {
			var chartInfo = Reflect.copy(_plot.chartInfos[i]);
			var chartID = "chart_" + i;
			if (chartInfo.axisInfo != null) {
				axisID = "axis_" + i;
			}
			if (chartInfo.data.groups == null) {
				chartInfo.data.groups = [];
				for (j in 0...chartInfo.data.xValues.length) {
					chartInfo.data.groups.push(Std.string(i + 1));
				}
			}
			switch (chartInfo.type) {
				case scatter:
					if (chartInfo.axisInfo != null && chartInfo.axisInfo.length > 2) {
						throw new Exception("Not able to use more than 2 axes for scatterplot!");
					}
					if (_plot.axes.exists(axisID)) {
						trace("Exists?", axisID);
						chartInfo.axisInfo = [
							{
								type: linear,
								axis: _plot.axes.get(axisID)[0]
							},
							{
								type: linear,
								axis: _plot.axes.get(axisID)[1]
							}
						];
					}
					var scatter = new Scatter(chartInfo, _plot.plotBody, chartID, axisID);
					if (!_plot.axes.exists(axisID)) {
						trace(axisID, scatter.axes[0].ticks[1].text);
						_plot.axes.set(axisID, scatter.axes);
					}
				case bar:
					return;
				case pie:
					return;
			}
		}
	}

	override function validateComponentLayout():Bool {
		super.validateComponentLayout();
		_plot.left = _plot.marginLeft;
		_plot.top = _plot.marginTop;
		_plot.width -= _plot.marginLeft + _plot.marginRight;
		_plot.height -= _plot.marginTop + _plot.marginBottom;

		_plot.plotBody.left = _plot.paddingLeft;
		_plot.plotBody.top = _plot.paddingTop;
		_plot.plotBody.width -= _plot.paddingLeft + _plot.paddingRight;
		_plot.plotBody.height -= _plot.paddingTop + _plot.paddingBottom;
		return true;
	}
}
