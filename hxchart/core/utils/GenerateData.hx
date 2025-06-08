package hxchart.core.utils;

class GenerateData {
	static public function generateNumericData(n:Int, min:Array<Float>, max:Array<Float>, ?groups:Array<String>) {
		var xCol:Array<Float> = [];
		var yCol:Array<Float> = [];
		var groupCol:Array<String> = [];
		var yIndex = min.length > 1 ? 1 : 0;
		for (i in 0...n) {
			var x = min[0] + Math.random() * (max[0] - min[0]);
			xCol.push(x);

			var y = min[yIndex] + Math.random() * (max[yIndex] - min[yIndex]);
			yCol.push(y);
		}
		if (groups != null) {
			for (i in 0...n) {
				var group = groups[Math.floor(Math.random() * groups.length)];
				groupCol.push(group);
			}
		}
		return {x: xCol, y: yCol, groups: groupCol};
	}
}
