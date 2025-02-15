package docs;

import hscript.Expr;
import hxchart.Utils;
import haxe.Serializer;
import haxe.Json;
import haxe.ui.core.TextInput;
import hxchart.basics.plot.Chart;
import haxe.ui.containers.HBox;
import haxe.ui.ComponentBuilder;
import haxe.ui.core.Component;
import haxe.ui.core.ItemRenderer;
import haxe.ui.containers.TreeView;
import haxe.ui.components.Label;
import haxe.ui.containers.ListView;
import haxe.ui.containers.menus.MenuBar;
import haxe.ui.containers.VBox;
import js.Browser;
import haxe.ui.HaxeUIApp;
import haxe.ui.Toolkit;

class TryOut {
	static var chart:Chart;

	public static function main() {
		Toolkit.init({
			container: Browser.document.getElementById("example")
		});
		var app = new HaxeUIApp();
		var box = new HBox();
		box.percentWidth = 100;
		box.percentHeight = 100;
		var interp = new hscript.Interp();
		var x = new hscript.Parser();
		var textInput = new haxe.ui.components.TextArea();
		textInput.percentWidth = 30;
		textInput.onChange = function(e) {
			try {
				var expr = x.parseString(textInput.text);
				var y:TrailInfo = interp.execute(expr);
				var info:TrailInfo = {
					data: {
						values: y.data.values
					},
					type: TrailTypes.createByName(Std.string(y.type))
				};

				chart = new Chart(info);
				chart.percentWidth = 70;
				chart.percentHeight = 100;
				box.removeComponent(chart);
				box.addComponent(chart);
			} catch (e) {
				trace(e.message);
			}
		}
		box.addComponent(textInput);

		app.ready(function() {
			app.addComponent(box);
			app.start();
		});
	}
}
