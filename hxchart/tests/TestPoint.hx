package hxchart.tests;

import hxchart.basics.ticks.Ticks;
import hxchart.basics.points.Point;
import utest.Assert;

class TestPoint extends utest.Test {
	function testCalcCoords() {
		var p = new Point(0, 0, 0);
		var t1 = new Ticks();
		t1.left = 0;
		t1.text = "0";
		t1.top = 0;
		var t2 = new Ticks();
		t2.left = 10;
		t2.text = "1";
		t2.top = 0;
		var x = p.calcXCoord([t1, t2], 0, {pos_dist: 10, neg_dist: 0});
		Assert.equals(0, x);
		var t1 = new Ticks();
		t1.left = 0;
		t1.text = "0";
		t1.top = 10;
		var t2 = new Ticks();
		t2.left = 0;
		t2.text = "1";
		t2.top = 0;
		var y = p.calcYCoord([t1, t2], 10, {pos_dist: 10, neg_dist: 0});
		Assert.equals(10, y);

		var p = new Point(0.5, 0, 0);
		var t1 = new Ticks();
		t1.left = 0;
		t1.text = "0";
		t1.top = 0;
		var t2 = new Ticks();
		t2.left = 10;
		t2.text = "1";
		t2.top = 0;
		var x = p.calcXCoord([t1, t2], 0, {pos_dist: 10, neg_dist: 0});
		Assert.equals(5, x);
		var t1 = new Ticks();
		t1.left = 0;
		t1.text = "0";
		t1.top = 10;
		var t2 = new Ticks();
		t2.left = 0;
		t2.text = "1";
		t2.top = 0;
		var y = p.calcYCoord([t1, t2], 10, {pos_dist: 10, neg_dist: 0});
		Assert.equals(10, y);

		var p = new Point(0.5, 0.5, 0);
		var t1 = new Ticks();
		t1.left = 0;
		t1.text = "0";
		t1.top = 0;
		var t2 = new Ticks();
		t2.left = 10;
		t2.text = "1";
		t2.top = 0;
		var x = p.calcXCoord([t1, t2], 0, {pos_dist: 10, neg_dist: 0});
		Assert.equals(5, x);
		var t1 = new Ticks();
		t1.left = 0;
		t1.text = "0";
		t1.top = 10;
		var t2 = new Ticks();
		t2.left = 0;
		t2.text = "1";
		t2.top = 0;
		var y = p.calcYCoord([t1, t2], 10, {pos_dist: 10, neg_dist: 0});
		Assert.equals(5, y);

		var p = new Point(0, 1, 0);
		var t1 = new Ticks();
		t1.left = 0;
		t1.text = "0";
		t1.top = 0;
		var t2 = new Ticks();
		t2.left = 10;
		t2.text = "1";
		t2.top = 0;
		var x = p.calcXCoord([t1, t2], 0, {pos_dist: 10, neg_dist: 0});
		Assert.equals(0, x);
		var t1 = new Ticks();
		t1.left = 0;
		t1.text = "0";
		t1.top = 10;
		var t2 = new Ticks();
		t2.left = 0;
		t2.text = "1";
		t2.top = 0;
		var y = p.calcYCoord([t1, t2], 10, {pos_dist: 10, neg_dist: 0});
		Assert.equals(0, y);
	}
}
