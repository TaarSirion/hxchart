package hxchart.haxeui.colors;

import haxe.ui.util.ColorUtil;
import haxe.ui.util.Color;

enum ColorPaletteEnum {
	normal;
	blue;
	green;
	red;
	grey;
	blueGreen;
	pastellBlueGreen;
	blueRed;
	pastellBlueRed;
	greenRed;
	pastellGreenRed;
}

class ColorPalettes {
	public static function blue(n:Int) {
		return ColorUtil.buildColorArray(Color.fromString("#B9DDF1"), Color.fromString("blue"), n);
	}

	public static function green(n:Int) {
		return ColorUtil.buildColorArray(Color.fromString("#B3E0A6"), Color.fromString("green"), n);
	}

	public static function red(n:Int) {
		return ColorUtil.buildColorArray(Color.fromString("#FFBEB2"), Color.fromString("red"), n);
	}

	public static function grey(n:Int) {
		return ColorUtil.buildColorArray(Color.fromString("#D5D5D5"), Color.fromString("grey"), n);
	}

	public static function blueGreen(n:Int) {
		return ColorUtil.buildColorArray(Color.fromString("blue"), Color.fromString("green"), n);
	}

	public static function pastellBlueGreen(n:Int) {
		return ColorUtil.buildColorArray(Color.fromString("#FEFFD9"), Color.fromString("#41B7C4"), n);
	}

	public static function blueRed(n:Int) {
		return ColorUtil.buildColorArray(Color.fromString("blue"), Color.fromString("red"), n);
	}

	public static function pastellBlueRed(n:Int) {
		return ColorUtil.buildColorArray(Color.fromString("#FEFFD9"), Color.fromString("#ff6961"), n);
	}

	public static function greenRed(n:Int) {
		return ColorUtil.buildColorArray(Color.fromString("green"), Color.fromString("red"), n);
	}

	public static function pastellGreenRed(n:Int) {
		return ColorUtil.buildColorArray(Color.fromString("#41B7C4"), Color.fromString("#ff6961"), n);
	}

	public static function defaultColors(n:Int) {
		if (n == 1) {
			return [Color.fromString("black").toInt()];
		}

		var def = [
			Color.fromString("red"),
			Color.fromString("orange"),
			Color.fromString("green"),
			Color.fromString("#6699FF"),
			Color.fromString("purple"),
			Color.fromString("#99991E"),
			Color.fromString("grey"),
			Color.fromString("pink"),
			Color.fromString("brown"),
			Color.fromString("white"),
			Color.fromString("yellow"),
			Color.fromString("blue"),
			Color.fromString("#CCFFFF"),
			Color.fromString("#79CC3D"),
			Color.fromString("#3F2327"),
			Color.fromString("black")
		];
		var res:Array<Int> = [];
		var x = Math.ceil(n / def.length);
		var ddef = [];
		for (i in 0...x) {
			ddef = ddef.concat(def);
		}
		for (i in 0...n) {
			res.push(ddef[i]);
		}
		return res;
	}
}
