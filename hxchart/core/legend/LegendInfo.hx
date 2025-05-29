package hxchart.core.legend;

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
		if (!useLegend) {
			return;
		}
		if (data == null) {
			return;
		}
		if (nodeStyle == null) {
			for (node in data) {
				if (node.style.symbolColor == null) {
					node.style.symbolColor = 0x000000;
				}
				if (node.style.symbol == null) {
					node.style.symbol = LegendSymbols.rectangle;
				}
			}
			return;
		}

		for (node in data) {
			if (node.style.symbolColor == null) {
				node.style.symbolColor = nodeStyle.symbolColor == null ? 0x000000 : nodeStyle.symbolColor;
			}
			if (node.style.symbol == null) {
				node.style.symbol = nodeStyle.symbol == null ? LegendSymbols.rectangle : nodeStyle.symbol;
			}
		}
	}
}
