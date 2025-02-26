package hxchart.basics.legend;

import haxe.ui.components.Spacer;
import hxchart.basics.legend.LegendNode.LegendNodeStyling;
import haxe.ui.components.Button;
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
import haxe.ui.behaviours.DefaultBehaviour;

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
	text:String,
	?fontSize:Null<Int>,
	?color:Color
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
				if (node.style.textColor == null) {
					node.style.textColor = Color.fromString("black");
				}
				if (node.style.symbolColor == null) {
					node.style.symbolColor = Color.fromString("black");
				}
				if (node.style.fontSize == null) {
					node.style.fontSize = 16;
				}
				if (node.style.symbol == null) {
					node.style.symbol = LegendSymbols.rectangle;
				}
			}
			return;
		}

		for (node in data) {
			if (node.style.textColor == null) {
				node.style.textColor = nodeStyle.textColor == null ? Color.fromString("black") : nodeStyle.textColor;
			}
			if (node.style.symbolColor == null) {
				node.style.symbolColor = nodeStyle.symbolColor == null ? Color.fromString("black") : nodeStyle.symbolColor;
			}
			if (node.style.fontSize == null) {
				node.style.fontSize = nodeStyle.fontSize == null ? 16 : nodeStyle.fontSize;
			}
			if (node.style.symbol == null) {
				node.style.symbol = nodeStyle.symbol == null ? LegendSymbols.rectangle : nodeStyle.symbol;
			}
		}
	}
}

@:composite(Builder, LegendLayout)
class Legend extends VBox {
	@:clonable @:behaviour(DefaultBehaviour, 20) public var fontSizeTitle:Null<Int>;
	@:clonable @:behaviour(DefaultBehaviour, 18) public var fontSizeSubTitle:Null<Int>;

	@:clonable @:behaviour(DefaultBehaviour, 0x000000) public var colorTitle:Null<Int>;
	@:clonable @:behaviour(DefaultBehaviour, 0x000000) public var colorSubTitle:Null<Int>;

	@:clonable @:behaviour(TitleBehaviour) public var legendTitle:String;
	@:clonable @:behaviour(SubTitleBehaviour) public var legendSubTitle:String;

	// public var legendTitle:String;
	// public var legendSubTitle:String;

	@:call(AddNode) public function addNode(data:LegendNodeData):LegendNode;

	public var childNodes:Array<String>;

	public var legendPosition:LegendPosition = right;

	public function new(info:LegendInfo) {
		if (info.position != null) {
			legendPosition = info.position;
		}
		super();
		if (info.title != null) {
			fontSizeTitle = info.title.fontSize == null ? fontSizeTitle : info.title.fontSize;
			colorTitle = info.title.color == null ? colorTitle : info.title.color;
			legendTitle = info.title.text;
		}

		if (info.subTitle != null) {
			fontSizeSubTitle = info.subTitle.fontSize == null ? fontSizeSubTitle : info.subTitle.fontSize;
			colorSubTitle = info.subTitle.color == null ? colorSubTitle : info.subTitle.color;
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
		if (Std.isOfType(child, LegendNode)) {
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
		_legend.styleSheet = new StyleSheet();
		_legend.styleSheet.parse("
			.legend-class{ 
				border: 1px solid #000000;
				background-color: #f5f5f5;
				padding: 10px;
				font-family: Arial;
			}
			.legend-title {
				text-align: center;
				font-size: "
			+ _legend.fontSizeTitle
			+ "px;
				color: "
			+ _legend.colorTitle
			+ ";
			}
			.legend-sub-title {
				text-align: center;
				font-size: "
			+ _legend.fontSizeSubTitle
			+ "px;
			color: "
			+ _legend.colorSubTitle
			+ ";
			}
		");
	}

	override function applyStyle(style:Style) {
		super.applyStyle(style);
		// _legend.top += style.marginTop;
		// _legend.height -= style.marginBottom;
	}

	override function validateComponentLayout():Bool {
		trace("AMM");
		super.validateComponentLayout();
		trace("here");
		// switch (_legend.legendPosition) {
		// 	case left:
		// 		var height = _legend.paddingBottom + _legend.paddingTop;
		// 		for (child in _legend.childComponents[0].childComponents) {
		// 			height += child.height + child.marginTop + child.marginBottom + 5;
		// 		}
		// 		_legend.height = height;
		// 	case right:
		// 		var height = _legend.paddingBottom + _legend.paddingTop;
		// 		for (child in _legend.childComponents[0].childComponents) {
		// 			height += child.height + child.marginTop + child.marginBottom + 5;
		// 		}
		// 		_legend.height = height;
		// 	case top:
		// 		// var width = _legend.paddingLeft + _legend.paddingRight;
		// 		// for (child in _legend.childComponents[0].childComponents) {
		// 		// 	width += child.width + child.marginLeft + child.marginRight + 5;
		// 		// }
		// 		// _legend.width = width;
		// 		var fullLength = _legend.childComponents[0].width;
		// 		for (child in _legend.childComponents[0].childComponents) {
		// 			if (child.numComponents == 0) {
		// 				fullLength -= child.width;
		// 				continue;
		// 			}
		// 			child.width = fullLength / _legend.childNodes.length;
		// 		}
		// 	case bottom:
		// 		var width = _legend.paddingLeft + _legend.paddingRight;
		// 		for (child in _legend.childComponents[0].childComponents) {
		// 			width += child.width + child.marginLeft + child.marginRight + 5;
		// 		}
		// 		_legend.width = width;
		// 	// var fullLength = _legend.childComponents[0].width;
		// 	// for (child in _legend.childComponents[1].childComponents) {
		// 	// 	if (child.numComponents == 0) {
		// 	// 		fullLength -= child.width;
		// 	// 		continue;
		// 	// 	}
		// 	// 	child.width = fullLength / _legend.childNodes.length;
		// 	// }
		// 	case Point(x, y, vertical):
		// 		if (vertical) {
		// 			var height = _legend.paddingBottom + _legend.paddingTop;
		// 			for (child in _legend.childComponents[0].childComponents) {
		// 				trace(child.height, child.width);
		// 				height += child.height + child.marginTop + child.marginBottom + 5;
		// 			}
		// 			_legend.height = height;
		// 		} else {
		// 			var width = _legend.paddingLeft + _legend.paddingRight;
		// 			for (child in _legend.childComponents[0].childComponents) {
		// 				width += child.width + child.marginLeft + child.marginRight + 5;
		// 			}
		// 			_legend.width = width;
		// 		}
		// }
		return true;
	}
}
