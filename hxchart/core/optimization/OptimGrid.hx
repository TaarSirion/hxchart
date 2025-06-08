package hxchart.core.optimization;

class OptimGrid {
	public var grid:Array<Array<Bool>>;

	public function new(width:Float, height:Float, step:Float) {
		var xs = Math.round(width / step);
		var ys = Math.round(height / step);
		grid = [];
		grid.resize(xs);
		for (i => column in grid) {
			grid[i] = [];
			grid[i].resize(ys);
			for (j => val in grid[i]) {
				grid[i][j] = false;
			}
		}
	}
}
