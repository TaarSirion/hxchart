# hxchart


`hxchart` is a library for creating charts. It is based on top of `haxeui` using its flexibility to allow easier creation of charts for different targets/backends.

It is still in early development and rather featureless, but will hopefully see a lot of development over the coming months.

For examples of charts look here: https://taarsirion.github.io/hxchart/

## Installation
```
haxelib install haxeui-core
haxelib install haxeui-html5
haxelib install hxchart
```

## Usage
```
import hxchart.basics.Chart;
import haxe.ui.Toolkit;
import haxe.ui.HaxeUIApp;
import haxe.ui.util.Color;
public static function main() {
    var app = new HaxeUIApp();
    // For an easy setup of all charts we set a TrailInfo object.
    var trailInfo:TrailInfo = {
			data: {                 // TrailInfos consist of three main components, data
				xValues: [1, 2, 3],
				yValues: [1, 2, 3]
			},
			axisInfo: [             // axisInfo, containing information of the axes
				{
					type: linear
				},
				{
					type: linear
				}
			],
			type: scatter           // and type, setting the chart type to render.
		};
    var plot = new Plot(trailInfo); // Then we create the Plot object. This is the container for the trailinfo. Theoretically a plot can consist of more than one trail.
    plot.left = 0;
    plot.top = 0;
    plot.percentWidth = 100; // Using percentageWidth or Height allows for responsive plots.
    plot.height = 500;
    app.ready(function() {
        app.addComponent(plot);
        app.start();
    });
}
```

### TrailInfo
The TrailInfo Object contains these subfields
- data:TrailData 
    - xValues:Array<Dynamic>
    - yValues:Array<Dynamic>
    - groups:Array<String>
- type Enum of all chart types.
- ?axisInfo:AxisInfo This is technically optional, but should always be set for the first trail in a plot. It is an array and needs two entries with at least the type set.
    - type:AxisTypes
	- ?axis:Axis Instead of letting the axis get calculated automatically, this will use an existing axis.
	- ?values:Array<Dynamic> Set the min and max values for the axis. This is only for advanced usage.
- ?style 
    - ?colorPalette:Array<Int> Colors to use for the trail. For simpler usage, use `ColorPalettes`.
	- ?positionOption:PositionOption 


# Roadmap for features
- Add grouping for values and a legend displaying the grouping. 
    - Groups can be `String` or `Int` values. 
    - Each group will have a color by default.
    - Customizing options for group color, legend title, legend position, legend fontsize, legend fontfamily, legend border (style, size, color), legend margin, legend padding.
- Increase customizing options. 
- Change size and color of points depending on a weight
- Add linechart
- Repeat x or y values, depending on the larger array
- Add Histogram 
- Add piechart