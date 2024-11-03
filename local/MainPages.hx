package;

import haxe.ui.containers.HBox;
import haxe.ui.containers.ScrollView;
import haxe.ui.core.Screen;
import hxchart.basics.plot.Plot;
import hxchart.basics.plot.Plot.TrailInfo;
import haxe.ui.containers.Box;
import haxe.ui.HaxeUIApp;
import haxe.ui.Toolkit;
import haxe.ui.containers.TabView;
import haxe.ui.containers.ListView;
import haxe.ui.containers.Stack;

class MainPages {
	public static function main() {
		Toolkit.init();
		var app = new HaxeUIApp();

		var tabs = new TabView();

		// Create Scatter Plots
		var scatterBox = new HBox();
		scatterBox.text = "Scatter Plots";
		scatterBox.width = Screen.instance.width;
		scatterBox.height = 1000;

		var scatterStack = new Stack();
		scatterStack.percentWidth = 80;
		scatterStack.percentHeight = 100;

		var scatterListView = new ListView();
		scatterListView.percentWidth = 20;
		scatterListView.dataSource.add("Simple Scatter");
		scatterListView.selectedIndex = 0;
		scatterListView.onChange = function(e) {
			scatterStack.selectedIndex = scatterListView.selectedIndex;
		};

		var simpleScatterScroll = new ScrollView();
		simpleScatterScroll.percentWidth = 100;
		simpleScatterScroll.height = 700;
		scatterStack.addComponent(simpleScatterScroll);

		var simpleScatterInfo:TrailInfo = {
			data: {
				xValues: [0, 1, 2],
				yValues: [0, 1, 2]
			},
			axisInfo: [
				{
					type: linear
				},
				{
					type: linear
				}
			],
			type: scatter
		};

		var scatterPlot = new Plot(simpleScatterInfo, Screen.instance.width, 500);
		scatterPlot.left = 0;
		scatterPlot.top = 0;
		scatterPlot.width = 500;
		scatterPlot.height = 500;
		simpleScatterScroll.addComponent(scatterPlot);

		scatterBox.addComponent(scatterListView);
		scatterBox.addComponent(scatterStack);
		tabs.addComponent(scatterBox);

		app.ready(function() {
			app.addComponent(tabs);
			app.start();
		});
	}
}
