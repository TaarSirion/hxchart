package hxchart.basics.axis;

class StringTickInfo extends TickInfo {
	public function new(values:Array<String>) {
		super();
		labels = [];
		labels.push("");
		zeroIndex = 0;
		getUniqueLabels(values);
		tickNum = labels.length;
	}

	public function getUniqueLabels(values:Array<String>) {
		for (label in values) {
			if (labels.indexOf(label) == -1) {
				labels.push(label);
			}
		}
	}
}
