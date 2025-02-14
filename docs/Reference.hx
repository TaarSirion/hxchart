package docs;

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

@:build(haxe.ui.macros.ComponentMacros.build("reference.xml"))
class Reference extends HBox {
	public function new() {
		super();
		trace("HH");
		dataInfo.dataSource.add({text: "data.values"});
		dataInfo.dataSource.add({text: "type"});
		dataInfo.dataSource.add({text: "axisInfo.type"});
		dataInfo.dataSource.add({text: "axisInfo.axis"});
		dataInfo.dataSource.add({text: "axisInfo.values"});
		dataInfo.dataSource.add({text: "style.groups"});
		dataInfo.dataSource.add({text: "style.colorPalette"});
		dataInfo.dataSource.add({text: "style.positionOption"});
		dataInfo.dataSource.add({text: "style.size"});
		dataInfo.dataSource.add({text: "style.alpha"});
		dataInfo.dataSource.add({text: "style.borderStyle"});
		dataInfo.dataSource.add({text: "events"});
		dataInfo.dataSource.add({text: "optimizationInfo"});

		var dataValues = new Label();
		dataValues.addClass("markdown-content");
		dataValues.htmlText = "<h1>data.values</h1>";

		infoBody.addComponent(dataValues);
	}

	public static function main() {
		Toolkit.init({
			container: Browser.document.getElementById("reference-body")
		});
		var app = new HaxeUIApp();
		var ref = new Reference();
		ref.percentHeight = 100;
		app.ready(function() {
			app.addComponent(ref);
			app.start();
		});
	}
}
