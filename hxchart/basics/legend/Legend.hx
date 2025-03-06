package hxchart.basics.legend;

import haxe.ui.styles.elements.Directive;
import haxe.ui.styles.elements.RuleElement;
import haxe.ui.components.Spacer;
import hxchart.basics.legend.LegendNode.LegendNodeStyling;
import haxe.ui.containers.HBox;
import haxe.ui.util.Color;
import haxe.ui.styles.Style;
import haxe.ui.layouts.DefaultLayout;
import hxchart.basics.legend.LegendNode.LegendNodeData;
import haxe.ui.core.Component;
import haxe.ui.util.Variant;
import haxe.ui.behaviours.Behaviour;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.containers.VBox;
import haxe.ui.styles.StyleSheet;
import haxe.ui.components.Label;

enum LegendSymbols {
	point;
	line;
	rectangle;
}

enum LegendPosition {
	left;
	right;
	top;
	bottom;
	Point(x:Float, y:Float, vertical:Bool);
}

typedef LegendTitle = {
	text:String
}

/**
 * Information about a plot legend.
 * 
 * Legends are always plot specific and not trail specific. Meaning multiple trails in a plot share the same legend.
 * @param title Optional. Title displayed on top of the legend. Will default to `"Legend"`.
 * @param nodeFontSize Optional. Fontsize for all legend nodes.
 * @param useLegend Optional. If a legend should be used. Per default a legend will be used.
 */
@:structInit class LegendInfo {
	@:optional public var title:LegendTitle;
	@:optional public var subTitle:LegendTitle;
	@:optional public var data:Array<LegendNodeData>;
	@:optional public var nodeStyle:LegendNodeStyling;
	@:optional public var position:LegendPosition;
	public var useLegend:Bool;

	public function validate() {
		if (data == null) {
			return;
		}
		if (nodeStyle == null) {
			for (node in data) {
				if (node.style.symbolColor == null) {
					node.style.symbolColor = Color.fromString("black");
				}
				if (node.style.symbol == null) {
					node.style.symbol = LegendSymbols.rectangle;
				}
			}
			return;
		}

		for (node in data) {
			if (node.style.symbolColor == null) {
				node.style.symbolColor = nodeStyle.symbolColor == null ? Color.fromString("black") : nodeStyle.symbolColor;
			}
			if (node.style.symbol == null) {
				node.style.symbol = nodeStyle.symbol == null ? LegendSymbols.rectangle : nodeStyle.symbol;
			}
		}
	}
}

@:composite(Builder, LegendLayout)
class Legend extends VBox {
	@:clonable @:behaviour(TitleBehaviour) public var legendTitle:String;
	@:clonable @:behaviour(SubTitleBehaviour) public var legendSubTitle:String;

	@:call(AddNode) public function addNode(data:LegendNodeData):LegendNode;

	public var childNodes:Array<String>;

	public var legendPosition:LegendPosition = right;
	public var legendStyleSheet:StyleSheet;

	public function new(info:LegendInfo, ?styleSheet:StyleSheet) {
		if (info == null) {
			info = {
				title: {
					text: "Legend",
				},
				useLegend: true,
				nodeStyle: {
					symbol: rectangle,
				}
			};
		} else {
			if (info.nodeStyle == null) {
				info.nodeStyle = {
					symbol: rectangle,
				};
			}
			if (info.nodeStyle.symbol == null) {
				info.nodeStyle.symbol = rectangle;
			}
		}

		if (info.position != null) {
			legendPosition = info.position;
		}
		legendStyleSheet = styleSheet;
		super();
		if (info.title != null) {
			legendTitle = info.title.text;
		}

		if (info.subTitle != null) {
			legendSubTitle = info.subTitle.text;
		}
	}
}

@:dox(hide) @:noCompletion
private class LegendLayout extends DefaultLayout {}

@:dox(hide) @:noCompletion
private class TitleBehaviour extends DataBehaviour {
	private override function validateData() {
		var label = new Label();
		label.text = _value;
		label.addClass("legend-title");
		var legend = cast(_component, Legend);
		var textContainer:Component = legend.findComponent("legend-title-container", Component, true, "css");
		if (textContainer != null) {
			textContainer.addComponentAt(label, 0);
		}
	}
}

@:dox(hide) @:noCompletion
private class SubTitleBehaviour extends DataBehaviour {
	private override function validateData() {
		var label = new Label();
		label.text = _value;
		label.addClass("legend-sub-title");
		var legend = cast(_component, Legend);
		var textContainer:Component = legend.findComponent("legend-title-container", Component, true, "css");
		if (textContainer != null) {
			textContainer.addComponentAt(label, 1);
		}
	}
}

@:dox(hide) @:noCompletion
private class AddNode extends Behaviour {
	public override function call(param:Any = null):Variant {
		var legend = cast(_component, Legend);
		var node = new LegendNode(legend, param);
		var spacer = new Spacer();
		switch legend.legendPosition {
			case right:
			case left:
			case top:
				spacer.width = 40;
			case bottom:
				spacer.width = 40;
			case Point(x, y, vertical):
				if (!vertical) {
					spacer.width = 40;
				}
		}
		legend.addComponent(node);
		legend.addComponent(spacer);
		legend.childNodes.push(node.text);
		return node;
	}
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
class Builder extends CompositeBuilder {
	private var _legend:Legend;
	private var _legendContainer:Component;

	public function new(legend:Legend) {
		super(legend);
		_legend = legend;
		_legend.childNodes = [];
		_legend.addClass("legend-class");

		switch (_legend.legendPosition) {
			case left:
				_legendContainer = new VBox();
				_legendContainer.addClass("legend-node-container");
				_legendContainer.addClass("legend-title-container");
			case right:
				_legendContainer = new VBox();
				_legendContainer.addClass("legend-node-container");
				_legendContainer.addClass("legend-title-container");
			case top:
				_legendContainer = new VBox();
				var titleContainer = new HBox();
				titleContainer.addClass("legend-title-container");
				_legendContainer.addComponent(titleContainer);
				var nodeContainer = new HBox();
				nodeContainer.addClass("legend-node-container");
				_legendContainer.addComponent(nodeContainer);
			case bottom:
				_legendContainer = new VBox();
				var titleContainer = new HBox();
				titleContainer.addClass("legend-title-container");
				_legendContainer.addComponent(titleContainer);
				var nodeContainer = new HBox();
				nodeContainer.addClass("legend-node-container");
				_legendContainer.addComponent(nodeContainer);
			case Point(x, y, vertical):
				_legendContainer = new VBox();
				if (vertical) {
					_legendContainer.addClass("legend-node-container");
					_legendContainer.addClass("legend-title-container");
				} else {
					var titleContainer = new HBox();
					titleContainer.addClass("legend-title-container");
					_legendContainer.addComponent(titleContainer);
					var nodeContainer = new HBox();
					nodeContainer.addClass("legend-node-container");
					_legendContainer.addComponent(nodeContainer);
				}
		}
		_legendContainer.id = "legend-container";
		_legend.addComponent(_legendContainer);
		setStyleSheet();
	}

	public override function addComponent(child:Component):Component {
		if (child is LegendNode) {
			var container = _legend.findComponent("legend-node-container", Component, true, "css");
			return container.addComponent(child);
		}
		if (child is Spacer) {
			var container = _legend.findComponent("legend-node-container", Component, true, "css");
			return container.addComponent(child);
		}
		return null;
	}

	override function removeAllComponents(dispose:Bool = true):Bool {
		_legendContainer.removeAllComponents(dispose);
		return true;
	}

	private function setStyleSheet() {
		if (_legend.legendStyleSheet != null) {
			_legend.styleSheet = _legend.legendStyleSheet;
			return;
		}
		_legend.styleSheet = new StyleSheet();
		_legend.styleSheet.addRule(new RuleElement(".legend-class", [
			new Directive("border-size", VDimension(PX(1))),
			new Directive("border-color", VColor(0x000000)),
			new Directive("border-style", VString("solid")),
			new Directive("background-color", VColor(0xf5f5f5)),
			new Directive("padding", VDimension(PX(10)))
		]));
		_legend.styleSheet.addRule(new RuleElement(".legend-title", [
			new Directive("text-align", VString("center")),
			new Directive("font-size", VDimension(PX(20))),
			new Directive("color", VColor(0x000000))
		]));
		_legend.styleSheet.addRule(new RuleElement(".legend-subtitle", [
			new Directive("text-align", VString("center")),
			new Directive("font-size", VDimension(PX(17))),
			new Directive("color", VColor(0x000000))
		]));
		_legend.styleSheet.addRule(new RuleElement(".legend-text", [
			new Directive("text-align", VString("left")),
			new Directive("font-size", VDimension(PX(15))),
			new Directive("color", VColor(0x000000))
		]));
		switch (_legend.legendPosition) {
			case left:
				_legend.styleSheet.addRule(new RuleElement(".legend-class", [
					new Directive("vertical-align", VString("center")),
					new Directive("margin-left", VDimension(PX(10))),
					new Directive("margin-right", VDimension(PX(10)))
				]));
			case right:
				_legend.styleSheet.addRule(new RuleElement(".legend-class", [
					new Directive("vertical-align", VString("center")),
					new Directive("margin-left", VDimension(PX(10))),
					new Directive("margin-right", VDimension(PX(10)))
				]));

			case top:
				_legend.styleSheet.addRule(new RuleElement(".legend-class", [new Directive("horizontal-align", VString("center"))]));
			case bottom:
				_legend.styleSheet.addRule(new RuleElement(".legend-class", [new Directive("horizontal-align", VString("center"))]));
			case Point(x, y, vertical):
		}
	}

	override function applyStyle(style:Style) {
		super.applyStyle(style);
	}

	override function validateComponentLayout():Bool {
		super.validateComponentLayout();
		return true;
	}
}
