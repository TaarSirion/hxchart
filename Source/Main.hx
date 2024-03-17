package;

import haxe.ui.core.Screen;
import basics.Chart;
import haxe.ui.components.Canvas;
import haxe.ui.Toolkit;
import haxe.ui.HaxeUIApp;
import haxe.ui.geom.Point;
import basics.Axis;
import haxe.ui.util.Color;

class Main {
	public static function main() {
		Toolkit.init();
		var app = new HaxeUIApp();
		// var axis = new Axis(new Point(0, 0), new Point(0, 10), true, Color.fromString("black"));
		// var canvas = new Canvas();
		// canvas.width = 500;
		// canvas.height = 500;
		// axis.draw(canvas.componentGraphics);
		var chart = new Chart();
		chart.setChart([0.5, -1, 2, -0.5], [0.5, 1, -2, -1]);
		chart.setOptions([{name: point_size, value: 2}, {name: color, value: Color.fromString("blue")}]);

		app.ready(function() {
			app.addComponent(chart.draw());
			app.start();
		});
	}
}
