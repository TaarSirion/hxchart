package hxchart.basics.quadtree;

import haxe.ui.geom.Point;

class Region {
	public var x1:Float;
	public var x2:Float;
	public var y1:Float;
	public var y2:Float;

	public function new(x1:Float, x2:Float, y1:Float, y2:Float) {
		this.x1 = x1;
		this.x2 = x2;
		this.y1 = y1;
		this.y2 = y2;
	}

	public function containsPoint(point:Point):Bool {
		return (point.x >= x1 && point.x <= x2 && point.y >= y1 && point.y <= y2);
	}

	public function doesOverlap(region:Region):Bool {
		if (region.x2 < this.x1) {
			return false;
		}
		if (region.x1 > this.x2) {
			return false;
		}
		if (region.y1 > this.y2) {
			return false;
		}
		if (region.y2 < this.y1) {
			return false;
		}
		return true;
	}

	public function getQuadrant(quadrantIndex:Int):Null<Region> {
		var quadrantWidth:Float = (this.x2 - this.x1) / 2;
		var quadrantHeight = (this.y2 - this.y1) / 2;

		// 0=SW, 1=NW, 2=NE, 3=SE
		switch (quadrantIndex) {
			case 0:
				return new Region(x1, y1, x1 + quadrantWidth, y1 + quadrantHeight);
			case 1:
				return new Region(x1, y1 + quadrantHeight, x1 + quadrantWidth, y2);
			case 2:
				return new Region(x1 + quadrantWidth, y1 + quadrantHeight, x2, y2);
			case 3:
				return new Region(x1 + quadrantWidth, y1, x2, y1 + quadrantHeight);
		}
		return null;
	}
}

class Quadtree {
	public var area:Region;
	public var points:Array<Point>;
	public var quadTrees:Array<Quadtree>;

	final maxSize:Int = 3;

	public function new(area:Region) {
		this.area = area;
		points = [];
		quadTrees = [];
	}

	public function addPoint(point:Point):Bool {
		if (this.area.containsPoint(point)) {
			if (this.points.length < maxSize) {
				this.points.push(point);
				return true;
			}
			if (this.quadTrees.length == 0) {
				createQuadrants();
			}
			return addPointToOneQuadrant(point);
		}
		return false;
	}

	function addPointToOneQuadrant(point:Point):Bool {
		var isPointAdded:Bool = false;
		for (i in 0...4) {
			isPointAdded = this.quadTrees[i].addPoint(point);
			if (isPointAdded)
				return true;
		}
		return false;
	}

	function createQuadrants() {
		var region:Region;
		for (i in 0...4) {
			region = this.area.getQuadrant(i);
			quadTrees.push(new Quadtree(region));
		}
	}

	public function search(searchRegion:Region, matches:Array<Point>):Array<Point> {
		if (matches == null) {
			matches = [];
		}
		if (!this.area.doesOverlap(searchRegion)) {
			return matches;
		}
		for (point in points) {
			if (searchRegion.containsPoint(point)) {
				matches.push(point);
			}
		}
		if (this.quadTrees.length > 0) {
			for (i in 0...4) {
				quadTrees[i].search(searchRegion, matches);
			}
		}
		return matches;
	}
}
