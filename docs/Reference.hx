package docs;

import haxe.ui.containers.TreeView;
import haxe.ui.components.Label;
import haxe.ui.containers.ListView;
import haxe.ui.containers.menus.MenuBar;
import haxe.ui.containers.VBox;
import js.Browser;
import haxe.ui.HaxeUIApp;
import haxe.ui.Toolkit;

class Reference {
	public static function main() {
		Toolkit.init({
			container: Browser.document.getElementById("reference-body")
		});
		var app = new HaxeUIApp();

		var currentMenu = 0;

		var sidebar = new TreeView();
		sidebar.percentWidth = 20;
		sidebar.selectedNode = sidebar.getNodes()[0];
		sidebar.addNode({text: "TrailInfo"});

		app.ready(function() {
			app.addComponent(sidebar);
			app.start();
		});
	}
}
