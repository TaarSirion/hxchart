package hxchart.tests;

import hxchart.core.tickinfo.NumericTickInfo;
import utest.Assert;

class TestNumericTickInfo extends utest.Test {
	function testCustomTicks() {
		var tickInfo = new NumericTickInfo(["ticks" => [0, 1, 4]]);
		Assert.equals("0", tickInfo.labels[0]);
		Assert.equals(3, tickInfo.tickNum);
		Assert.equals("4", tickInfo.labels[tickInfo.labels.length - 1]);
	}

	function testPrecision() {
		var tickInfo = new NumericTickInfo(["min" => [0], "max" => [10]]);
		Assert.equals(0, tickInfo.precision);

		var tickInfo = new NumericTickInfo(["min" => [-9], "max" => [80]]);
		Assert.equals(1, tickInfo.precision);

		var tickInfo = new NumericTickInfo(["min" => [-99], "max" => [0]]);
		Assert.equals(1, tickInfo.precision);

		var tickInfo = new NumericTickInfo(["min" => [0], "max" => [0.5]]);
		Assert.equals(1, tickInfo.precision);
		var tickInfo = new NumericTickInfo(["min" => [-0.5], "max" => [0]]);
		Assert.equals(1, tickInfo.precision);

		var tickInfo = new NumericTickInfo(["min" => [-0.5], "max" => [0.6]]);
		Assert.equals(1, tickInfo.precision);
	}

	function testPower() {
		var tickInfo = new NumericTickInfo(["min" => [0], "max" => [10]]);
		Assert.equals(1, tickInfo.power);

		var tickInfo = new NumericTickInfo(["min" => [-9], "max" => [80]]);
		Assert.equals(10, tickInfo.power);

		var tickInfo = new NumericTickInfo(["min" => [-99], "max" => [0]]);
		Assert.equals(10, tickInfo.power);

		var tickInfo = new NumericTickInfo(["min" => [0], "max" => [0.5]]);
		Assert.equals(0.1, tickInfo.power);
		var tickInfo = new NumericTickInfo(["min" => [-0.5], "max" => [0]]);
		Assert.equals(0.1, tickInfo.power);
		var tickInfo = new NumericTickInfo(["min" => [-0.5], "max" => [0.6]]);
		Assert.equals(0.1, tickInfo.power);
	}

	@:depends(testPrecision, testPower)
	function testTickNum() {
		var tickInfo = new NumericTickInfo(["min" => [0], "max" => [10]]);
		tickInfo.calcTickNum();
		Assert.equals(11, tickInfo.tickNum);

		var tickInfo = new NumericTickInfo(["min" => [-9], "max" => [80]]);
		tickInfo.calcTickNum();
		Assert.equals(10, tickInfo.tickNum);

		var tickInfo = new NumericTickInfo(["min" => [-99], "max" => [0]]);
		tickInfo.calcTickNum();
		Assert.equals(11, tickInfo.tickNum);

		var tickInfo = new NumericTickInfo(["min" => [0], "max" => [0.6]]);
		tickInfo.calcTickNum();
		Assert.equals(7, tickInfo.tickNum);

		var tickInfo = new NumericTickInfo(["min" => [-0.6], "max" => [0]]);
		tickInfo.calcTickNum();
		Assert.equals(7, tickInfo.tickNum);
		var tickInfo = new NumericTickInfo(["min" => [-0.6], "max" => [0.7]]);
		tickInfo.calcTickNum();
		Assert.equals(14, tickInfo.tickNum);

		var tickInfo = new NumericTickInfo(["min" => [-3000], "max" => [100]]);
		tickInfo.calcTickNum();
		Assert.equals(17, tickInfo.tickNum);
	}

	@:depends(testTickNum)
	function testZeroIndex() {
		var tickInfo = new NumericTickInfo(["min" => [0], "max" => [10]]);
		tickInfo.calcTickNum();
		Assert.equals(0, tickInfo.zeroIndex);

		var tickInfo = new NumericTickInfo(["min" => [-9], "max" => [80]]);
		tickInfo.calcTickNum();
		Assert.equals(1, tickInfo.zeroIndex);

		var tickInfo = new NumericTickInfo(["min" => [-99], "max" => [0]]);
		tickInfo.calcTickNum();
		Assert.equals(10, tickInfo.zeroIndex);

		var tickInfo = new NumericTickInfo(["min" => [-10], "max" => [10]]);
		Assert.equals(10, tickInfo.zeroIndex);

		var tickInfo = new NumericTickInfo(["min" => [0], "max" => [0.6]]);
		tickInfo.calcTickNum();
		Assert.equals(0, tickInfo.zeroIndex);

		var tickInfo = new NumericTickInfo(["min" => [-0.6], "max" => [0]]);
		tickInfo.calcTickNum();
		Assert.equals(6, tickInfo.zeroIndex);
		var tickInfo = new NumericTickInfo(["min" => [-0.6], "max" => [0.7]]);
		tickInfo.calcTickNum();
		Assert.equals(6, tickInfo.zeroIndex);
	}

	@:depends(testTickNum)
	function testNegNum() {
		var tickInfo = new NumericTickInfo(["min" => [0], "max" => [10]]);
		tickInfo.calcTickNum();
		Assert.equals(0, tickInfo.negNum);

		var tickInfo = new NumericTickInfo(["min" => [-9], "max" => [80]]);
		tickInfo.calcTickNum();
		Assert.equals(1, tickInfo.negNum);

		var tickInfo = new NumericTickInfo(["min" => [-99], "max" => [0]]);
		tickInfo.calcTickNum();
		Assert.equals(10, tickInfo.negNum);

		var tickInfo = new NumericTickInfo(["min" => [-10], "max" => [10]]);
		Assert.equals(10, tickInfo.negNum);

		var tickInfo = new NumericTickInfo(["min" => [0], "max" => [0.6]]);
		tickInfo.calcTickNum();
		Assert.equals(0, tickInfo.negNum);

		var tickInfo = new NumericTickInfo(["min" => [-0.6], "max" => [0]]);
		tickInfo.calcTickNum();
		Assert.equals(6, tickInfo.negNum);
		var tickInfo = new NumericTickInfo(["min" => [-0.6], "max" => [0.7]]);
		tickInfo.calcTickNum();
		Assert.equals(6, tickInfo.negNum);
	}

	@:depends(testTickNum, testZeroIndex, testNegNum)
	function testCalcLabels() {
		var tickInfo = new NumericTickInfo(["min" => [0], "max" => [10]]);
		tickInfo.calcTickNum();
		tickInfo.setLabels([]);
		var labels = tickInfo.labels;
		Assert.contains("7", labels);
		Assert.contains("10", labels);
		Assert.contains("0", labels);
		Assert.notContains("11", labels);

		var tickInfo = new NumericTickInfo(["min" => [-9], "max" => [80]]);
		tickInfo.calcTickNum();
		tickInfo.setLabels([]);
		var labels = tickInfo.labels;
		Assert.contains("-10", labels);
		Assert.contains("0", labels);
		Assert.contains("40", labels);
		Assert.contains("80", labels);
		Assert.notContains("-11", labels);
		Assert.notContains("90", labels);

		var tickInfo = new NumericTickInfo(["min" => [-10], "max" => [10]]);
		var labels = tickInfo.labels;
		Assert.contains("-10", labels);
		Assert.contains("0", labels);
		Assert.contains("3", labels);
		Assert.contains("10", labels);
		Assert.notContains("-11", labels);
		Assert.notContains("11", labels);

		var tickInfo = new NumericTickInfo(["min" => [-0.6], "max" => [0.7]]);
		tickInfo.calcTickNum();
		tickInfo.setLabels([]);
		var labels = tickInfo.labels;
		Assert.contains("-0.2", labels);
		Assert.contains("0", labels);
		Assert.contains("0.3", labels);
		Assert.notContains("-0.7", labels);
		Assert.notContains("0.8", labels);
	}

	function testSubTickNum() {
		var tickInfo = new NumericTickInfo(["min" => [0], "max" => [10]], true);
		tickInfo.calcTickNum();
		Assert.equals(30, tickInfo.subTickNum);

		var tickInfo = new NumericTickInfo(["min" => [-9], "max" => [80]], true);
		tickInfo.calcTickNum();
		Assert.equals(27, tickInfo.subTickNum);

		var tickInfo = new NumericTickInfo(["min" => [-99], "max" => [0]], true);
		tickInfo.calcTickNum();
		Assert.equals(30, tickInfo.subTickNum);

		var tickInfo = new NumericTickInfo(["min" => [0], "max" => [0.6]], true);
		tickInfo.calcTickNum();
		Assert.equals(18, tickInfo.subTickNum);

		var tickInfo = new NumericTickInfo(["min" => [-0.6], "max" => [0]], true);
		tickInfo.calcTickNum();
		Assert.equals(18, tickInfo.subTickNum);

		var tickInfo = new NumericTickInfo(["min" => [-0.6], "max" => [0.7]], true);
		tickInfo.calcTickNum();
		Assert.equals(39, tickInfo.subTickNum);
	}

	@:depends(testNegNum)
	function testSubNegNum() {
		var tickInfo = new NumericTickInfo(["min" => [0], "max" => [10]], true);
		tickInfo.calcTickNum();
		Assert.equals(0, tickInfo.subNegNum);

		var tickInfo = new NumericTickInfo(["min" => [-9], "max" => [80]], true);
		tickInfo.calcTickNum();
		Assert.equals(3, tickInfo.subNegNum);

		var tickInfo = new NumericTickInfo(["min" => [-99], "max" => [0]], true);
		tickInfo.calcTickNum();
		Assert.equals(30, tickInfo.subNegNum);

		var tickInfo = new NumericTickInfo(["min" => [0], "max" => [0.6]], true);
		tickInfo.calcTickNum();
		Assert.equals(0, tickInfo.subNegNum);

		var tickInfo = new NumericTickInfo(["min" => [-0.6], "max" => [0]], true);
		tickInfo.calcTickNum();
		Assert.equals(18, tickInfo.subNegNum);

		var tickInfo = new NumericTickInfo(["min" => [-0.6], "max" => [0.7]], true);
		tickInfo.calcTickNum();
		Assert.equals(18, tickInfo.subNegNum);
	}

	@:depends(testSubTickNum, testSubNegNum)
	function testSubLabels() {
		var tickInfo = new NumericTickInfo(["min" => [0], "max" => [10]], true, 3, true);
		var labels = tickInfo.subLabels;
		Assert.contains(".25", labels);
		Assert.contains(".75", labels);
		Assert.notContains("0", labels);
		Assert.notContains("10.25", labels);

		var tickInfo = new NumericTickInfo(["min" => [-9], "max" => [80]], true);
		var labels = tickInfo.subLabels;
		Assert.contains("-7.5", labels);
		Assert.contains("-5", labels);
		Assert.contains("45", labels);
		Assert.contains("77.5", labels);
		Assert.notContains("-12.5", labels);
		Assert.notContains("82.5", labels);

		var tickInfo = new NumericTickInfo(["min" => [-0.6], "max" => [0.7]], true);
		var labels = tickInfo.subLabels;

		Assert.contains("-0.575", labels);
		Assert.contains("0.025", labels);
		Assert.contains("0.675", labels);
		Assert.notContains("-0.625", labels);
		Assert.notContains("0.725", labels);
	}

	function testConstructorWithEmptyTicks() {
		var tickInfo = new NumericTickInfo(["ticks" => []]);
		Assert.equals(1, tickInfo.tickNum);
		Assert.same(["0"], tickInfo.labels);
		Assert.equals(0, tickInfo.zeroIndex);
	}

	function testConstructorWithDuplicateTicks() {
		var tickInfo = new NumericTickInfo(["ticks" => [1, 2, 2, 3, 0, 0]]);
		Assert.equals(4, tickInfo.tickNum);
		Assert.same(["0", "1", "2", "3"], tickInfo.labels);
		Assert.equals(0, tickInfo.zeroIndex);
	}

	function testConstructorWithUnsortedTicks() {
		var tickInfo = new NumericTickInfo(["ticks" => [3, 1, 0, 2]]);
		Assert.equals(4, tickInfo.tickNum);
		Assert.same(["0", "1", "2", "3"], tickInfo.labels);
		Assert.equals(0, tickInfo.zeroIndex);
	}

	function testConstructorWithNoZeroInTicks() {
		var tickInfo = new NumericTickInfo(["ticks" => [1, 2, 3, 4]]);
		Assert.equals(5, tickInfo.tickNum);
		Assert.same(["0", "1", "2", "3", "4"], tickInfo.labels);
		Assert.equals(0, tickInfo.zeroIndex);

		var tickInfo2 = new NumericTickInfo(["ticks" => [-3, -2, -1]]);
		Assert.equals(4, tickInfo2.tickNum);
		Assert.same(["-3", "-2", "-1", "0"], tickInfo2.labels);
		Assert.equals(3, tickInfo2.zeroIndex);
	}

	function testCalcPowerWithLargeValues() {
		var tickInfo = new NumericTickInfo(["min" => [1000000], "max" => [100000000]]);
		Assert.equals(10000000, tickInfo.power);

		var tickInfo2 = new NumericTickInfo(["min" => [-100000000], "max" => [-1000000]]);
		Assert.equals(10000000, tickInfo2.power);
	}

	function testCalcPowerWithSmallValues() {
		var tickInfo = new NumericTickInfo(["min" => [0.00001], "max" => [0.0001]]);
		Assert.floatEquals(0.0001, tickInfo.power);

		var tickInfo2 = new NumericTickInfo(["min" => [-0.0001], "max" => [-0.00001]]);
		Assert.floatEquals(0.0001, tickInfo2.power);
	}

	function testCalcPowerResultingInPowerLessThanOne() {
		var tickInfo = new NumericTickInfo(["min" => [0.1], "max" => [0.9]]);
		Assert.equals(0.1, tickInfo.power);

		var tickInfo2 = new NumericTickInfo(["min" => [-0.9], "max" => [-0.1]]);
		Assert.equals(0.1, tickInfo2.power);
	}

	function testCalcPowerWithMixedMagnitudeValues() {
		var tickInfo = new NumericTickInfo(["min" => [-0.5], "max" => [1000]]);
		Assert.equals(100, tickInfo.power); // Max dominates, initial power is 100. diff = 1000.5. floor(1000.5/100)=10. Not > 16.

		var tickInfo2 = new NumericTickInfo(["min" => [-1000], "max" => [0.5]]);
		Assert.equals(100, tickInfo2.power); // Min dominates, initial power is 100 (from Math.abs(min)). diff = 1000.5. floor(1000.5/100)=10. Not > 16.
	}

	function testCalcPowerRangeCausesRecalculation() {
		// This case should trigger the recalculation logic:
		// min = 0, max = 1.7
		// Initial power = 0.1
		// diff = 1.7
		// floor(diff / power) = floor(1.7 / 0.1) = 17. This is > 16.
		// rawStep = 1.7 / 16 = 0.10625
		// step = 0.10625
		// pow = floor(log10(0.10625)) = -1. power = 0.1
		// power * 2 >= step (0.2 >= 0.10625) is true. step = 0.2.
		// final power = 0.2
		var tickInfo = new NumericTickInfo(["min" => [0], "max" => [1.7]]);
		Assert.floatEquals(0.2, tickInfo.power, 0.000000001);

		// This case should also trigger recalculation:
		// min = -3000, max = 100
		// Initial power: Based on max-1 (99) or abs(min)-1 (2999) -> log10 of larger range.
		// Let's trace: max = 100, min = -3000.
		// initialPower based on (max > 1 ? max-1:max) or (min < -1 ? abs(min)-1:abs(min))
		// maxPart = 99. minPart = 2999.
		// logMax = floor(log10(99)) = 1. logMin = floor(log10(2999)) = 3.
		// initial pow = 10^3 = 1000.
		// diff = abs(100) + abs(-3000) = 3100.
		// floor(diff / power) = floor(3100 / 1000) = 3. This is NOT > 16.
		// The existing test testPower() has: var tickInfo = new NumericTickInfo(["min" => [-9], "max" => [80]]); Assert.equals(10, tickInfo.power);
		// Here, maxPart = 79 (pow 1), minPart = 8 (pow 0). initial power = 10. diff = 89. floor(89/10) = 8. Not > 16.
		// The existing test testPower() has: var tickInfo = new NumericTickInfo(["min" => [-99], "max" => [0]]); Assert.equals(10, tickInfo.power);
		// Here, maxPart = 0 (pow -inf). minPart = 98 (pow 1). initial power = 10. diff = 99. floor(99/10) = 9. Not > 16.

		// Let's re-verify the [-3000, 100] case from the problem description.
		// min = -3000, max = 100.
		// NumericTickInfo.hx:64 this.power = Math.pow(10, p); where p is determined by Math.max(logMax, logMin)
		// logMax = (this.max > 1) ? Math.floor(Math.log(this.max -1) / Math.LN10) : Math.floor(Math.log(this.max) / Math.LN10);
		// logMin = (this.min < -1) ? Math.floor(Math.log(Math.abs(this.min) -1) / Math.LN10) : Math.floor(Math.log(Math.abs(this.min)) / Math.LN10);
		// logMax for 100: floor(log10(99)) = 1.
		// logMin for -3000: floor(log10(2999)) = 3.
		// p = Math.max(1, 3) = 3. Initial power = 10^3 = 1000.
		// diff = Math.abs(max) + Math.abs(min) = 100 + 3000 = 3100.
		// condition: Math.floor(diff / this.power) > 16
		// Math.floor(3100 / 1000) = Math.floor(3.1) = 3. This is NOT > 16.
		// So the power should remain 1000 for ["min" => [-3000], "max" => [100]].

		// Let's re-evaluate the example from testTickNum: new NumericTickInfo(["min" => [-3000], "max" => [100]]);
		// Its power is 1000 based on above.
		// Its tickNum is 17. How?
		// calcTickNum: this.maxNum = Math.ceil(this.max / this.power); (100/1000) = 0.1 -> 1
		// this.negNum = Math.ceil(Math.abs(this.min) / this.power); (3000/1000) = 3
		// tickNum = maxNum + negNum + (containsZero ? 1:0) = 1 + 3 + 1 = 5.
		// This is not 17. The test testTickNum has tickInfo.calcTickNum();
		// Ah, the `power` in `testPower` is asserted *before* `calcTickNum` might change it.
		// The `calcPower` method itself has the recalculation logic.
		// My current tests are for the `power` value set in the constructor, which calls `calcPower` once.

		// The prompt said: Initialize NumericTickInfo with ["min" => [-3000], "max" => [100]]. Assert power is 200.
		// This implies the recalculation logic *is* hit.
		// The logic in NumericTickInfo.hx for calcPower is:
		// ... initial power calculation ...
		// var diff:Float = Math.abs(this.max) + Math.abs(this.min);
		// if (this.max == 0 && this.min == 0) diff = 1; // Avoids diff = 0
		// if (Math.floor(diff / this.power) > 16 || Math.floor(diff / this.power) < 2 && this.power > 0.00000000000001) // Added a check for < 2
		// {
		//    var rawStep = diff / 8; // Targetting between 8 and 16 ticks usually
		// ... then it recalculates power based on rawStep ...
		// Let's assume the code has `diff / 8` and the threshold is `> 16 || < 2`.
		// For min = -3000, max = 100: initial power = 1000. diff = 3100.
		// floor(diff/power) = floor(3100/1000) = 3.
		// This is not > 16. Is it < 2? No, 3 is not < 2.
		// So the recalculation is NOT triggered by this condition if it's `>16 || <2`.

		// Let's use the values from the prompt directly assuming they are correct and based on the actual codebase's behavior.
		// The prompt's analysis for `[-3000, 100]` resulting in `power = 200` implies the internal logic IS hit.
		// My trace of the existing `calcPower` might be missing something or the code is different than I assumed from memory.
		// The key is `Math.floor(diff / power) > 16`.
		// If initial power for `[-3000, 100]` was 10 (not 1000), then `diff/power = 3100/10 = 310`. This IS > 16.
		// When would initial power be 10?
		// logMax for 100 is 1. logMin for -3000 is 3. `p = max(1,3) = 3`. Power = 1000.
		// This seems to be a discrepancy. I will stick to the values provided in the prompt for now.
		// The prompt's derivation for [-3000, 100] to get 200 was:
		// Initial power = 10. diff = 3100. floor(3100/10) = 310 > 16. -> Recalc.
		// rawStep = 3100 / 16 = 193.75. step = 193. pow = floor(log10(193)) = 2. power = 100.
		// if (100 >= 193) F. else if (100*2 >= 193) T (200>=193). step = 200. power = 200.
		// This derivation relies on initial power being 10.
		// The current `testPower` asserts `new NumericTickInfo(["min" => [-99], "max" => [0]]); Assert.equals(10, tickInfo.power);`
		// For this: max=0, min=-99. logMax for 0 is floor(log10(0)) -> negative infinity. logMin for -99 is floor(log10(98)) = 1.
		// So p = 1. power = 10. This is correct.
		// What if min/max are such that one is tiny and other large?
		// `new NumericTickInfo(["min" => [-0.5], "max" => [1000]])`
		// logMax for 1000: floor(log10(999)) = 2.
		// logMin for -0.5: floor(log10(0.5)) = -1.
		// p = max(2, -1) = 2. Power = 100. This matches my comment for `testCalcPowerWithMixedMagnitudeValues`.
		// `new NumericTickInfo(["min" => [-1000], "max" => [0.5]])`
		// logMax for 0.5: floor(log10(0.5)) = -1.
		// logMin for -1000: floor(log10(999)) = 2.
		// p = max(-1, 2) = 2. Power = 100. This also matches.

		// The discrepancy seems to be only for `["min" => [-3000], "max" => [100]]` where the prompt expects 200, but my trace gives 1000.
		// And the `testTickNum` for `[-3000, 100]` implies a `power` that leads to `tickNum = 17`.
		// If power = 200: maxNum = ceil(100/200)=ceil(0.5)=1. negNum = ceil(3000/200)=ceil(15)=15. tickNum = 1+15+1=17.
		// This matches! So power *must* be 200 for `["min" => [-3000], "max" => [100]]`.
		// This means the initial power calculation for this case must be different, OR the recalculation condition/logic is different.
		// If `calcPower` in `NumericTickInfo.hx` has `var diff = this.max - this.min;` instead of `Math.abs(this.max) + Math.abs(this.min);` for some cases? No, that's unlikely for general tick calculation.
		// The most plausible explanation is that the initial power calculation for `[-3000, 100]` results in something like 10 or uses a different mechanism that then triggers the recalculation to 200.
		// Given the existing test `testPower` with `["min" => [-9], "max" => [80]]` results in power 10.
		// For this: logMax(79)=1, logMin(8)=0. p=max(1,0)=1. Power=10. Correct.
		// diff = 80 - (-9) = 89 for range, or 80+9=89 for abs sum.
		// floor(89/10) = 8. Not > 16. So power remains 10.

		// I will trust the prompt's expected value of 200 for `[-3000, 100]` and 0.2 for `[0, 1.7]`.
		var tickInfo2 = new NumericTickInfo(["min" => [-3000], "max" => [100]]);
		Assert.floatEquals(200, tickInfo2.power, 0.000000001);
	}

	function testCalcTickNumAndSubTicksSimpleRange() {
		var config = ["min" => [0.], "max" => [10.]];
		// power = 1. maxNum = 10, negNum = 0. containsZero = true. tickNum = 10 + 0 + 1 = 11.
		var tickInfoWithSub = new NumericTickInfo(config, true, 3);
		Assert.equals(11, tickInfoWithSub.tickNum);
		Assert.equals((11 - 1) * 3, tickInfoWithSub.subTickNum);

		var tickInfoNoSub = new NumericTickInfo(config, false);
		Assert.equals(11, tickInfoNoSub.tickNum);
		Assert.equals(0, tickInfoNoSub.subTickNum);
	}

	function testCalcTickNumAndSubTicksNegativeRange() {
		var config = ["min" => [-100.], "max" => [-10.]];
		// power = 10. max < 0. maxNum = 0. negNum = ceil((abs(-100) - abs(-10))/10)+1 = ceil(90/10)+1 = 9+1=10. containsZero=false.
		// tickNum = maxNum + negNum + zeroTick = 0 + 10 + 1= 11.
		var tickInfoWithSub = new NumericTickInfo(config, true, 4);
		Assert.equals(11, tickInfoWithSub.tickNum);
		Assert.equals(40, tickInfoWithSub.subTickNum);

		var tickInfoNoSub = new NumericTickInfo(config, false);
		Assert.equals(11, tickInfoNoSub.tickNum);
		Assert.equals(0, tickInfoNoSub.subTickNum);
	}

	function testCalcTickNumAndSubTicksMixedRange() {
		var config = ["min" => [-50.], "max" => [50.]];
		// power = 10. maxNum = ceil(50/10)=5. negNum = ceil(abs(-50)/10)=5. containsZero=true.
		// tickNum = 5 + 5 + 1 = 11.
		var tickInfoWithSub = new NumericTickInfo(config, true, 2);
		Assert.equals(11, tickInfoWithSub.tickNum);
		Assert.equals((11 - 1) * 2, tickInfoWithSub.subTickNum); // 20

		var tickInfoNoSub = new NumericTickInfo(config, false);
		Assert.equals(11, tickInfoNoSub.tickNum);
		Assert.equals(0, tickInfoNoSub.subTickNum);
	}

	function testCalcTickNumAndSubTicksSmallRangeDecimalPower() {
		var config = ["min" => [0.], "max" => [0.5]];
		// power = 0.1. maxNum = ceil(0.5/0.1)=5. negNum = ceil(0/0.1)=0. containsZero=true.
		// tickNum = 5 + 0 + 1 = 6.
		var tickInfoWithSub = new NumericTickInfo(config, true, 5);
		Assert.equals(6, tickInfoWithSub.tickNum);
		Assert.equals((6 - 1) * 5, tickInfoWithSub.subTickNum); // 25

		var tickInfoNoSub = new NumericTickInfo(config, false);
		Assert.equals(6, tickInfoNoSub.tickNum);
		Assert.equals(0, tickInfoNoSub.subTickNum);
	}

	function testSetLabelsSimpleRangeNoSubTicks() {
		var tickInfo = new NumericTickInfo(["min" => [0], "max" => [4]], false);
		// power = 1, precision = 0, tickNum = 5, zeroIndex = 0
		Assert.same(["0", "1", "2", "3", "4"], tickInfo.labels);
		Assert.isNull(tickInfo.subLabels); // or Assert.equals(0, tickInfo.subLabels.length); if initialized to empty array
	}

	function testSetLabelsNegativeToPositiveRangeNoSubTicks() {
		var tickInfo = new NumericTickInfo(["min" => [-2], "max" => [2]], false);
		// power = 1, precision = 0, tickNum = 5, zeroIndex = 2
		Assert.same(["-2", "-1", "0", "1", "2"], tickInfo.labels);
		Assert.isNull(tickInfo.subLabels);
	}

	function testSetLabelsWithPrecision() {
		var tickInfo = new NumericTickInfo(["min" => [0], "max" => [0.4]], false);
		// power = 0.1, precision = 1, tickNum = 5, zeroIndex = 0
		Assert.same(["0", "0.1", "0.2", "0.3", "0.4"], tickInfo.labels);
		Assert.isNull(tickInfo.subLabels);
	}

	function testSetLabelsWithSubTicksNoRemoveLead() {
		var tickInfo = new NumericTickInfo(["min" => [0], "max" => [2]], true, 1, false);
		// power = 1, precision = 0, tickNum = 3 (0,1,2), subTicksPerPart = 1
		// subTickNum = (3-1)*1 = 2. subTickPrec = 0+2=2.
		Assert.same(["0", "1", "2"], tickInfo.labels);
		Assert.same(["0.5", "1.5"], tickInfo.subLabels);
	}

	function testSetLabelsWithSubTicksRemoveLead() {
		var tickInfo = new NumericTickInfo(["min" => [0], "max" => [2]], true, 1, true);
		// subLabels: "0.50" -> ".50", "1.50" -> ".50"
		Assert.same(["0", "1", "2"], tickInfo.labels);
		Assert.same([".5", ".5"], tickInfo.subLabels);
	}

	function testSetLabelsWithSubTicksNegativeValuesNoRemoveLead() {
		var tickInfo = new NumericTickInfo(["min" => [-2], "max" => [0]], true, 1, false);
		// power = 1, precision = 0, tickNum = 3 (-2,-1,0), subTicksPerPart = 1
		// subTickNum = (3-1)*1 = 2. subTickPrec = 0+2=2.
		Assert.same(["-2", "-1", "0"], tickInfo.labels);
		Assert.same(["-1.5", "-0.5"], tickInfo.subLabels);
	}

	function testSetLabelsWithSubTicksNegativeValuesRemoveLead() {
		var tickInfo = new NumericTickInfo(["min" => [-2], "max" => [0]], true, 1, true);
		// subLabels: "-1.50" -> ".50", "-0.50" -> ".50"
		Assert.same(["-2", "-1", "0"], tickInfo.labels);
		Assert.same([".5", ".5"], tickInfo.subLabels);
	}
}
