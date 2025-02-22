package hxchart.tests;

import hxchart.basics.data.DataLayer.TrailData;
import utest.Assert;
import utest.Test;

class TestDataLayer extends Test {
	function testSetGroups() {
		var data:TrailData = {
			values: ["x" => [1, 2, 3]]
		};
		data.setGroups(scatter, "1");
		Assert.equals("1", data.values.get("groups")[0]);
		Assert.equals("1", data.values.get("groups")[1]);
		Assert.equals("1", data.values.get("groups")[2]);

		var data:TrailData = {
			values: ["x" => [1, 2, 3], "groups" => ["1", "2", "3"]]
		};
		data.setGroups(scatter, "1");
		Assert.equals("1", data.values.get("groups")[0]);
		Assert.equals("2", data.values.get("groups")[1]);
		Assert.equals("3", data.values.get("groups")[2]);
	}
}
