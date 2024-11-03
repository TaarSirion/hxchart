# hxchart

https://taarsirion.github.io/hxchart/

`hxchart` is a library for creating charts. It is based on top of `haxeui` using its flexibility to allow easier creation of charts for different targets/backends.

It is still in early development and rather featureless, but will hopefully see a lot of development over the coming months.

![Two point charts](/images/charts.png?raw=true "two point charts")
![Single point charts](/images/chart.png?raw=true "Single point charts")

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
    var chart = new Chart(0, 0, 100, 100); // First create a new Chart object with a position and size.
    chart.setPoints([1, 2], [1, 2]); // Add points to the chart. 
    chart.setOptions({name: point_color, value: Color.fromString("blue")}); // There are different options to be set for customizing your chart.
    app.ready(function() {
        app.addComponent(new MainView());
        app.addComponent(chart.draw()); // Currently it is still explicitly necessary to call the draw() method. This will probably change in the near future.
        app.start();
    });
}
```

### Options
`margin`
Margin sets the margin for width and height. Is a `Float` value. Defaults to 50.

`color`
Color sets the color for the chart. This will change the color of points and ticks. Is a `haxe.ui.util.Color` type. Defaults to black.

`point_color`
Sets the color of the points. Will override the option set in color. Is a `haxe.ui.util.Color` type. Defaults to black.

`point_size`
Sets the initial size of the points. Is a `Float` value. Defaults to 1.

`tick_length`
Sets the length of the big ticks. Is a `Float` value. Defaults to 5.

`tick_margin`
Sets the distance of the first and last tick to the beginning and end of the axis line. Is a `Float` value. Defaults to 10.

`tick_fontsize`
Sets the fontsize of the big ticks. Is a `Float` value. Defaults to 10.

`tick_color`
Sets the color of the ticks and its labels. Is a `haxe.ui.util.Color` type. Defaults to black.

# Roadmap for features
- Add grouping for values and a legend displaying the grouping. 
    - Groups can be `String` or `Int` values. 
    - Each group will have a color by default.
    - Customizing options for group color, legend title, legend position, legend fontsize, legend fontfamily, legend border (style, size, color), legend margin, legend padding.
- Increase customizing options. 
- Change size and color of points depending on a weight
- Add linechart
- Add Barchart
- Repeat x or y values, depending on the larger array
- Add Histogram 
- Add piechart