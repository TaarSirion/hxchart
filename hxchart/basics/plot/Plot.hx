package hxchart.basics.plot;

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
	?values:Array<Dynamic>
}

typedef ChartInfo = {
	data:AddDataType,
	type:ChartTypes,
	axisInfo:Array<AxisInfo>
}

@:composite(Builder)
class Plot extends Absolute {
	public var chartInfos:Array<ChartInfo>;

	public var plotBody:Absolute;
	public var legend:Legend;

	public function new(chartInfo:ChartInfo, width:Float, height:Float, ?legend:Legend) {
		super();
		chartInfos = [];
		chartInfos.push(chartInfo);
		if (legend != null) {
			this.legend = legend;
		}
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
		trace("TEST1");
		for (i => chartInfo in _plot.chartInfos) {
			var chartID = "chart_" + i;
			switch (chartInfo.type) {
				case scatter:
					if (chartInfo.axisInfo.length > 2) {
						throw new Exception("Not able to use more than 2 axes for scatterplot!");
					}
					var scatter = new Scatter(chartInfo, _plot.plotBody, chartID);
					return;
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
