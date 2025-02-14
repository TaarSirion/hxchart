package;

import haxe.ui.containers.menus.Menu;
import haxe.ui.containers.menus.MenuBar;
import haxe.ui.ComponentBuilder;
import haxe.ui.components.Label;
import haxe.ui.containers.VBox;
import hxchart.basics.utils.GenerateData;
import hxchart.basics.colors.ColorPalettes;
import haxe.ui.containers.HBox;
import haxe.ui.containers.ScrollView;
import haxe.ui.core.Screen;
import hxchart.basics.plot.Chart;
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

		var currentMenu = 0;
		var body = new VBox();
		body.percentHeight = 100;
		body.percentWidth = 100;

		var menuBar = new MenuBar();
		menuBar.percentWidth = 100;
		menuBar.percentHeight = 10;

		var getStartedMenu = new Menu();
		getStartedMenu.text = "Get Started";
		getStartedMenu.onClick = function(e) {}

		menuBar.addComponent(getStartedMenu);

		var bodyScroll = new ScrollView();
		// getStartedScroll.percentHeight = 100;
		bodyScroll.percentWidth = 100;
		bodyScroll.percentHeight = 90;
		bodyScroll.percentContentWidth = 100;

		var getStartedBody = new VBox();
		getStartedBody.percentWidth = 100;

		var getStartedText = new Label();
		getStartedText.percentWidth = 100;
		getStartedText.htmlText = "<p>This package allows you to create charts with Haxe.</p>"
			+ "<h1>How to install?</h1>"
			+ "<h3>Stable version:</h3>"
			+ "haxelib install hxchart"
			+ "<h3> Or get the development version:</h3>"
			+ "haxelib install hxchart https://github.com/TaarSirion/hxchart"
			+ "<h1>How to create your first chart?</h1>"
			+ "Creating your first chart is quite easy."
			+ "Because hxchart uses haxeui you first have to make sure to select the backend you want to work with. "
			+
			"For this tutorial we will use html-5. Setup your project like you would do with haxeui <a href='https://haxeui.org/api/getting-started/installing-haxeui.html'>(see here)</a>."
			+
			"<div>Now we can create our chart. A chart consists of one or multiple trails, which contain the data. So to draw our data we start by describing our trail:</div>"
			+ "<pre> <code> var trailinfo = { data: { values: ['x' => [1,2], 'y' => [1,2]]},type: scatter}</code></pre>"
			+ "There is a lot of options we can set for our chart, the most important ones are type and data."
			+ "Then create a chart object and give it the trailinfo. Then you can add the chart to the app and see the magic happen."
			+ "<pre>
	<code>
		var chart = new Chart(trailinfo);
		app.ready(function() {
			app.addComponent(chart);
		});
	</code>
</pre>"
			+ "<h1>Performance</h1>"
			+ "Under this link (Good to know) you will find more information regarding performance, but here is a little outlook. 
			For the most amounts of data this library will perform fine, but especially for big data (upwards of 10k datapoints) this library will struggle with performance. 
			That is mostly a problem with the nature of the library design, as it uses the power of haxe to be versatile it loses the power to be specialised. 
			In web this is probably the most offensive, because it cannot leverage webgl (at least currently) which will result in slower drawing. 
To make this clear, the problem is not the calculation, but the drawing. 
Therefore a small tip, always think about the necessity of drawing so many points. 
Usually it is not helpful from an analysis perspective, to have a cluster of 10k points sitting all on top of each other. ";

		getStartedBody.addComponent(getStartedText);
		bodyScroll.addComponent(getStartedBody);

		body.addComponent(menuBar);
		body.addComponent(bodyScroll);
		app.ready(function() {
			app.addComponent(body);
			app.start();
		});
	}
}
