package hxchart.tests;

import hxchart.core.tickinfo.StringTickInfo;
import hxchart.core.axis.AxisTypes;
import hxchart.core.tickinfo.NumericTickInfo;
import hxchart.core.axis.AxisInfo;
import utest.Assert;

class TestAxisInfo extends utest.Test {
	public function new() {
		super();
	}

	public function testSetAxisInfo_linearIntegers() {
		var axisInfo:AxisInfo = {id: "test", rotation: 0};
		axisInfo.setAxisInfo([1, 2, 3, 4, 5]);
		Assert.equals(AxisTypes.linear, axisInfo.type, "Type should be linear for integer data");
		Assert.isTrue(Std.isOfType(axisInfo.tickInfo, NumericTickInfo), "TickInfo should be NumericTickInfo for integer data");
		var numericTickInfo = cast(axisInfo.tickInfo, NumericTickInfo);
		Assert.equals(0, numericTickInfo.min, "Min value is incorrect");
		Assert.equals(5, numericTickInfo.max, "Max value is incorrect");
	}

	public function testSetAxisInfo_linearFloats() {
		var axisInfo:AxisInfo = {id: "test", rotation: 0};
		axisInfo.setAxisInfo([1.5, 2.5, 3.5, 4.5, 5.5]);
		Assert.equals(AxisTypes.linear, axisInfo.type, "Type should be linear for float data");
		Assert.isTrue(Std.isOfType(axisInfo.tickInfo, NumericTickInfo), "TickInfo should be NumericTickInfo for float data");
		var numericTickInfo = cast(axisInfo.tickInfo, NumericTickInfo);
		Assert.equals(0, numericTickInfo.min, "Min value is incorrect");
		Assert.equals(6, numericTickInfo.max, "Max value is incorrect");
	}

	public function testSetAxisInfo_categoricalStrings() {
		var axisInfo:AxisInfo = {id: "test", rotation: 0};
		axisInfo.setAxisInfo(["a", "b", "c"]);
		Assert.equals(AxisTypes.categorical, axisInfo.type, "Type should be categorical for string data");
		Assert.isTrue(Std.isOfType(axisInfo.tickInfo, StringTickInfo), "TickInfo should be StringTickInfo for string data");
		var stringTickInfo = cast(axisInfo.tickInfo, StringTickInfo);
		Assert.contains("a", stringTickInfo.labels, "a not in labels");
		Assert.contains("b", stringTickInfo.labels, "b not in labels");
		Assert.contains("c", stringTickInfo.labels, "c not in labels");
	}

	public function testSetAxisInfo_mixedData() {
		var axisInfo:AxisInfo = {id: "test", rotation: 0};
		// Assuming mixed data defaults to categorical
		axisInfo.setAxisInfo(["a", 1, "b", 2]);
		Assert.equals(AxisTypes.categorical, axisInfo.type, "Type should be categorical for mixed data");
		Assert.isTrue(Std.isOfType(axisInfo.tickInfo, StringTickInfo), "TickInfo should be StringTickInfo for mixed data");
		var stringTickInfo = cast(axisInfo.tickInfo, StringTickInfo);
		Assert.contains("a", stringTickInfo.labels, "a not in labels");
		Assert.contains("1", stringTickInfo.labels, "1 not in labels");
		Assert.contains("b", stringTickInfo.labels, "c not in labels");
		Assert.contains("2", stringTickInfo.labels, "2 not in labels");
	}

	public function testSetAxisInfo_emptyData() {
		var axisInfo:AxisInfo = {id: "test", rotation: 0};
		Assert.raises(function() {
			axisInfo.setAxisInfo([]);
		}, haxe.Exception, "Should throw an exception for empty data");
	}

	public function testSetAxisInfo_rotationNormalization() {
		var axisInfo1:AxisInfo = {id: "test1", rotation: 180};
		axisInfo1.setAxisInfo([1, 2]); // Needs some data to set type
		Assert.equals(0, axisInfo1.rotation, "Rotation 180 should normalize to 0");

		var axisInfo2:AxisInfo = {id: "test2", rotation: 270};
		axisInfo2.setAxisInfo([1, 2]);
		Assert.equals(90, axisInfo2.rotation, "Rotation 270 should normalize to 90");

		var axisInfo3:AxisInfo = {id: "test3", rotation: 360};
		axisInfo3.setAxisInfo([1, 2]);
		Assert.equals(0, axisInfo3.rotation, "Rotation 360 should normalize to 0");

		var axisInfo4:AxisInfo = {id: "test4", rotation: -90};
		axisInfo4.setAxisInfo([1, 2]);
		Assert.equals(90, axisInfo4.rotation, "Rotation -90 should normalize to 90 (becomes 270 then 90)");

		var axisInfo5:AxisInfo = {id: "test5", rotation: 45};
		axisInfo5.setAxisInfo([1, 2]);
		Assert.equals(45, axisInfo5.rotation, "Rotation 45 should remain 45");

		var axisInfo6:AxisInfo = {id: "test6", rotation: 179};
		axisInfo6.setAxisInfo([1, 2]);
		Assert.equals(179, axisInfo6.rotation, "Rotation 179 should remain 179");
	}

	public function testSetAxisInfo_valuesProvidedInConstructor() {
		var axisInfo:AxisInfo = {id: "test", rotation: 0, values: [10, 20]};
		axisInfo.setAxisInfo([]); // Call with empty trailValues, should use constructor values
		Assert.equals(AxisTypes.linear, axisInfo.type, "Type should be linear when values from constructor are used");
		Assert.isTrue(Std.isOfType(axisInfo.tickInfo, NumericTickInfo), "TickInfo should be NumericTickInfo");
		var numericTickInfo = cast(axisInfo.tickInfo, NumericTickInfo);
		Assert.equals(0, numericTickInfo.min, "Min value from constructor is incorrect");
		Assert.equals(20, numericTickInfo.max, "Max value from constructor is incorrect");
	}
}
