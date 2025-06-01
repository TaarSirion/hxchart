package hxchart.tests;

import utest.Assert;
import utest.Test;

// Core imports
import hxchart.core.axis.Axis;
import hxchart.core.axis.AxisInfo;
import hxchart.core.axis.AxisTypes;
import hxchart.core.axis.AxisTitle;
import hxchart.core.utils.CoordinateSystem;
import hxchart.core.utils.Point;
import hxchart.core.tickinfo.NumericTickInfo;
import hxchart.core.tickinfo.StringTickInfo;

class TestAxis extends Test {

    private function createNumericTickInfo(min:Float, max:Float):NumericTickInfo {
        return new NumericTickInfo(["min"=>[min], "max"=>[max]]);
    }

    private function createStringTickInfo(labels:Array<String>):StringTickInfo {
        return new StringTickInfo(labels);
    }

    function testCorePosition_BasicNoTitles_Horizontal() {
        var cs = new CoordinateSystem();
        cs.left = 0; cs.bottom = 0; cs.width = 200; cs.height = 150;

        var axisInfoX:AxisInfo = {
            id: "x-axis", rotation: 0, tickMargin: 10,
            tickInfo: createNumericTickInfo(0, 10), // Assumed: tickNum=11, zeroIndex=0
            type: AxisTypes.linear
        };

        var axes:Array<AxisInfo> = [axisInfoX];
        var axis = new Axis(axes, cs);
        axis.positionStartPoint();

        Assert.equals(10, axis.zeroPoint.x, "BasicH: zeroPoint.x");
        Assert.equals(75, axis.zeroPoint.y, "BasicH: zeroPoint.y");

        Assert.equals(10, axisInfoX.start.x, "BasicH: x-axis start.x");
        Assert.equals(75, axisInfoX.start.y, "BasicH: x-axis start.y");
        Assert.equals(180, axisInfoX.length, "BasicH: x-axis length");
        Assert.notNull(axisInfoX.end, "BasicH: x-axis end should not be null");
        if (axisInfoX.end != null) {
            Assert.equals(190, axisInfoX.end.x, "BasicH: x-axis end.x");
            Assert.equals(75, axisInfoX.end.y, "BasicH: x-axis end.y");
        }
    }

    function testCorePosition_HorizontalWithTitle_ZeroImpacted() {
        var cs = new CoordinateSystem();
        cs.left = 0; cs.bottom = 0; cs.width = 200; cs.height = 150;

        var titleX:AxisTitle = { text: "X-Axis Title" };
        var axisInfoX:AxisInfo = {
            id: "x-axis", rotation: 0, tickMargin: 10,
            tickInfo: createNumericTickInfo(0,100),
            type: AxisTypes.linear,
            title: titleX
        };

        var axisInfoY:AxisInfo = {
            id: "y-axis", rotation: 90, tickMargin: 5,
            tickInfo: createNumericTickInfo(0,50),
            type: AxisTypes.linear
        };

        var axes:Array<AxisInfo> = [axisInfoX, axisInfoY];
        var axis = new Axis(axes, cs);
        axis.positionStartPoint();

        // Calculation: zp.x=10, zp.y=5. titleX (bottom, 12px) -> spaceTakenBottom=12.
        // newHeight=138. zp.y becomes 12.
        Assert.equals(10, axis.zeroPoint.x, "TitleImpactH: zeroPoint.x");
        Assert.equals(12, axis.zeroPoint.y, "TitleImpactH: zeroPoint.y");

        Assert.equals(10, axisInfoX.start.x, "TitleImpactH: x-axis start.x");
        Assert.equals(12, axisInfoX.start.y, "TitleImpactH: x-axis start.y");
        Assert.equals(180, axisInfoX.length, "TitleImpactH: x-axis length");

        Assert.equals(10, axisInfoY.start.x, "TitleImpactH: y-axis start.x");
        Assert.equals(17, axisInfoY.start.y, "TitleImpactH: y-axis start.y");
        Assert.equals(128, axisInfoY.length, "TitleImpactH: y-axis length");
    }

    function testCorePosition_HorizontalWithTitle_ZeroNotImpactedButSpaceTaken() {
        var cs = new CoordinateSystem();
        cs.left = 0; cs.bottom = 0; cs.width = 200; cs.height = 150;

        var titleX:AxisTitle = { text: "X-Axis Title" };
        var axisInfoX:AxisInfo = {
            id: "x-axis", rotation: 0, tickMargin: 10,
            tickInfo: createNumericTickInfo(0,100),
            type: AxisTypes.linear,
            title: titleX
        };

        var axisInfoY_highZero:AxisInfo = {
            id: "y-high", rotation: 90, tickMargin: 5,
            tickInfo: new NumericTickInfo(["min"=>[-50.], "max"=>[50.]]), // zeroIndex=5 (for 11 ticks) -> zp.y=80
            type: AxisTypes.linear
        };

        var axes:Array<AxisInfo> = [axisInfoX, axisInfoY_highZero];
        var axis = new Axis(axes, cs);
        axis.positionStartPoint();

        // Calculation: zp.x=10, zp.y=80. titleX (bottom, 12px) -> spaceTakenBottom=12.
        // newHeight=138. zp.y (80) is not < 12, so zp.y remains 80.
        Assert.equals(10, axis.zeroPoint.x, "TitleNoImpactH: zeroPoint.x");
        Assert.equals(80, axis.zeroPoint.y, "TitleNoImpactH: zeroPoint.y");

        Assert.equals(10, axisInfoX.start.x, "TitleNoImpactH: x-axis start.x");
        Assert.equals(80, axisInfoX.start.y, "TitleNoImpactH: x-axis start.y");
        Assert.equals(180, axisInfoX.length, "TitleNoImpactH: x-axis length");

        Assert.equals(10, axisInfoY_highZero.start.x, "TitleNoImpactH: y-axis start.x");
        Assert.equals(17, axisInfoY_highZero.start.y, "TitleNoImpactH: y-axis start.y");
        Assert.equals(128, axisInfoY_highZero.length, "TitleNoImpactH: y-axis length");
    }

    function testCorePosition_StringTicksHorizontal() {
        var cs = new CoordinateSystem();
        cs.left = 0; cs.bottom = 0; cs.width = 220; cs.height = 100;
        var strLabels = ["A", "B", "C", "D"];
        var axisInfoX:AxisInfo = {
            id: "x-str-axis", rotation: 0, tickMargin: 10,
            tickInfo: createStringTickInfo(strLabels),
            type: AxisTypes.categorical
        };
        var axes:Array<AxisInfo> = [axisInfoX];
        var axis = new Axis(axes, cs);
        axis.positionStartPoint();

        // Calculation: StringInfo tickNum=4 -> for zero calc = 5. zeroIndex=0.
        // zp.x = (0*220/4)+0+10 = 10. zp.y=50 (cs center).
        Assert.equals(10, axis.zeroPoint.x, "StringH: zeroPoint.x");
        Assert.equals(50, axis.zeroPoint.y, "StringH: zeroPoint.y");

        Assert.equals(10, axisInfoX.start.x, "StringH: x-axis start.x");
        Assert.equals(50, axisInfoX.start.y, "StringH: x-axis start.y");
        Assert.equals(200, axisInfoX.length, "StringH: x-axis length");
    }

    function testCorePosition_SmallDimensions_LengthClamped() {
        var cs = new CoordinateSystem();
        cs.left = 0; cs.bottom = 0; cs.width = 30; cs.height = 20;
        var axisInfoX:AxisInfo = {
            id: "x-small", rotation: 0, tickMargin: 20,
            tickInfo: createNumericTickInfo(0,1),
            type: AxisTypes.linear
        };
        var axes:Array<AxisInfo> = [axisInfoX];
        var axis = new Axis(axes, cs);
        axis.positionStartPoint();
        // Calculation: length = 30 - 2*20 = -10 -> clamped to 0.
        Assert.equals(0, axisInfoX.length, "SmallDim: x-axis length clamped");
    }

    function testCorePosition_VerticalWithSubtitle_ZeroImpacted() {
        var cs = new CoordinateSystem();
        cs.left = 0; cs.bottom = 0; cs.width = 200; cs.height = 150;

        var subtitleY:AxisTitle = { text: "Y-Axis Subtitle" };
        var axisInfoY:AxisInfo = {
            id: "y-axis", rotation: 90, tickMargin: 5,
            tickInfo: createNumericTickInfo(0,50),
            type: AxisTypes.linear,
            subTitle: subtitleY
        };

        var axisInfoX:AxisInfo = {
            id: "x-axis", rotation: 0, tickMargin: 10,
            tickInfo: createNumericTickInfo(0,100),
            type: AxisTypes.linear
        };

        var axes:Array<AxisInfo> = [axisInfoX, axisInfoY];
        var axis = new Axis(axes, cs);
        axis.positionStartPoint();

        // Calculation: zp.x=10, zp.y=5. subtitleY (left, 20px) -> spaceTakenLeft=20.
        // newWidth=180. zp.x becomes 20.
        Assert.equals(20, axis.zeroPoint.x, "SubImpactV: zeroPoint.x");
        Assert.equals(5, axis.zeroPoint.y, "SubImpactV: zeroPoint.y");

        Assert.equals(20, axisInfoY.start.x, "SubImpactV: y-axis start.x");
        Assert.equals(5, axisInfoY.start.y, "SubImpactV: y-axis start.y");
        Assert.equals(140, axisInfoY.length, "SubImpactV: y-axis length");

        Assert.equals(30, axisInfoX.start.x, "SubImpactV: x-axis start.x");
        Assert.equals(5, axisInfoX.start.y, "SubImpactV: x-axis start.y");
        Assert.equals(160, axisInfoX.length, "SubImpactV: x-axis length");
    }
}
