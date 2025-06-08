package hxchart.tests;

import utest.Test;
import utest.Assert;
import hxchart.core.utils.Trigonometry;
import hxchart.core.utils.Point; // Corrected path for Point

class TestTrigonometry extends Test {
	var tolerance:Float = 0.0001;

	function testAngles() {
		var startPoint:Point = new Point(0.0, 0.0);
		var length:Float = 10.0;

		// 0 degrees
		var endpoint = Trigonometry.positionEndpoint(startPoint, 0, length);
		Assert.floatEquals(10.0, endpoint.x, tolerance, "0 deg: x");
		Assert.floatEquals(0.0, endpoint.y, tolerance, "0 deg: y");

		// 90 degrees
		endpoint = Trigonometry.positionEndpoint(startPoint, 90, length);
		Assert.floatEquals(0.0, endpoint.x, tolerance, "90 deg: x");
		Assert.floatEquals(10.0, endpoint.y, tolerance, "90 deg: y");

		// 180 degrees
		endpoint = Trigonometry.positionEndpoint(startPoint, 180, length);
		Assert.floatEquals(-10.0, endpoint.x, tolerance, "180 deg: x");
		Assert.floatEquals(0.0, endpoint.y, tolerance, "180 deg: y");

		// 270 degrees
		endpoint = Trigonometry.positionEndpoint(startPoint, 270, length);
		Assert.floatEquals(0.0, endpoint.x, tolerance, "270 deg: x");
		Assert.floatEquals(-10.0, endpoint.y, tolerance, "270 deg: y");

		// 360 degrees
		endpoint = Trigonometry.positionEndpoint(startPoint, 360, length);
		Assert.floatEquals(10.0, endpoint.x, tolerance, "360 deg: x");
		Assert.floatEquals(0.0, endpoint.y, tolerance, "360 deg: y");
	}

	function testLengths() {
		var startPoint:Point = new Point(0.0, 0.0);
		var angle:Int = 0; // Keep angle constant for these tests

		// Positive length
		var lengthPositive:Float = 20.0;
		var endpoint = Trigonometry.positionEndpoint(startPoint, angle, lengthPositive);
		Assert.floatEquals(20.0, endpoint.x, tolerance, "Positive length: x");
		Assert.floatEquals(0.0, endpoint.y, tolerance, "Positive length: y");

		// Zero length
		var lengthZero:Float = 0.0;
		endpoint = Trigonometry.positionEndpoint(startPoint, angle, lengthZero);
		Assert.floatEquals(0.0, endpoint.x, tolerance, "Zero length: x");
		Assert.floatEquals(0.0, endpoint.y, tolerance, "Zero length: y");

		// Negative length
		// Assuming negative length means going in the opposite direction (equivalent to angle + 180 deg)
		var lengthNegative:Float = -15.0;
		endpoint = Trigonometry.positionEndpoint(startPoint, angle, lengthNegative);
		Assert.floatEquals(-15.0, endpoint.x, tolerance, "Negative length: x");
		Assert.floatEquals(0.0, endpoint.y, tolerance, "Negative length: y");
	}

	function testStartPoints() {
		var angle:Int = 45;
		var length:Float = 10.0;
		var cos45 = Math.cos(Math.PI / 4); // Math.PI / 4 is 45 degrees in radians
		var sin45 = Math.sin(Math.PI / 4);
		var deltaX = length * cos45;
		var deltaY = length * sin45;

		// Origin
		var startOrigin:Point = new Point(0.0, 0.0);
		var endpoint = Trigonometry.positionEndpoint(startOrigin, angle, length);
		Assert.floatEquals(deltaX, endpoint.x, tolerance, "Start at origin: x");
		Assert.floatEquals(deltaY, endpoint.y, tolerance, "Start at origin: y");

		// Positive coordinates
		var startPositive:Point = new Point(5.0, 5.0);
		endpoint = Trigonometry.positionEndpoint(startPositive, angle, length);
		Assert.floatEquals(startPositive.x + deltaX, endpoint.x, tolerance, "Start at positive coords: x");
		Assert.floatEquals(startPositive.y + deltaY, endpoint.y, tolerance, "Start at positive coords: y");

		// Negative coordinates
		var startNegative:Point = new Point(-5.0, -5.0);
		endpoint = Trigonometry.positionEndpoint(startNegative, angle, length);
		Assert.floatEquals(startNegative.x + deltaX, endpoint.x, tolerance, "Start at negative coords: x");
		Assert.floatEquals(startNegative.y + deltaY, endpoint.y, tolerance, "Start at negative coords: y");
	}
}
