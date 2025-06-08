package hxchart.core.legend;

class Legend {
	public var title:String;
	public var subTitle:String;

	public var legendPosition:LegendPosition = right;

	public function new(info:LegendInfo) {
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
		if (info.title != null) {
			title = info.title.text;
		}

		if (info.subTitle != null) {
			subTitle = info.subTitle.text;
		}
	}
}
