package hxchart.core.axis;

import hxchart.core.utils.Statistics;
import haxe.Exception;
import hxchart.core.utils.Trigonometry;
import hxchart.core.utils.Point;
import hxchart.core.tick.Tick;
import hxchart.core.utils.CompassOrientation;
import hxchart.core.tickinfo.StringTickInfo;
import hxchart.core.coordinates.CoordinateSystem;

class Axis {
	public var coordSystem:CoordinateSystem;

	/**
	 * Set and update tick positions on the axis.
	 * @param isUpdate Contains TickInfo and if it should update the positions, or set new ones.
	 */
	public function setTicks(isUpdate:Bool):Void {
		for (i => info in axesInfo) {
			var tickInfo = info.tickInfo;
			var tickNum = tickInfo.tickNum;
			if (Std.isOfType(tickInfo, StringTickInfo)) {
				// Increase tickNum size so that positioning centers the ticks. Necessary because StringTickInfo has no zero Tick.
				tickNum++;
			}

			if (!isUpdate) {
				ticksPerInfo[i] = [];
				// for (j in 0...tickInfo.tickNum) {
				// 	axis.ticksPerInfo[i].push(new Ticks());
				// }
				// axis.sub_ticks = [];
			}

			var labelPosition:CompassOrientation = S;
			var tickPos = (info.length - 2 * info.tickMargin) / (tickNum - 1);
			switch (info.rotation) {
				case 0:
					labelPosition = S;
				case 90:
					labelPosition = W;
				case _:
					labelPosition = S;
			}

			var subTicksPerTick = 0;
			if (tickInfo.useSubTicks) {
				subTicksPerTick = tickInfo.subTicksPerPart;
			}
			var subIndex = 0;
			for (j in 0...tickInfo.tickNum) {
				var tick:Tick = null;
				if (isUpdate) {
					tick = ticksPerInfo[i][j];
				} else {
					tick = new Tick(false, info.rotation);
				}
				var tickPoint = Trigonometry.positionEndpoint(info.start, info.rotation, info.tickMargin + j * tickPos);
				tick.middlePos = tickPoint;
				if (tickInfo.zeroIndex == j && !info.showZeroTick) {
					tick.hidden = true;
				}
				tick.labelPosition = labelPosition;

				tick.text = tickInfo.labels[j];
				if (!isUpdate) {
					ticksPerInfo[i].push(tick);
				}
			}
			// for (j in 0...subTicksPerTick) {
			// 	if (i == (tickInfo.tickNum - 1)) {
			// 		break;
			// 	}
			// 	var tick = axis.sub_ticks[j];
			// 	var tickPoint = AxisTools.positionEndpoint(tickPoint, axis.axisRotation, (j + 1) * tickPos / (subTicksPerTick + 1));
			// 	tick.left = tickPoint.x;
			// 	tick.top = tickPoint.y;
			// 	tick.text = tickInfo.subLabels[subIndex];
			// 	subIndex++;
			// 	if (!ticksInAxis.isUpdate) {
			// 		axis.sub_ticks.push(tick);
			// 		layer.addComponent(tick);
			// 	}
			// }
		}
	}

	/**
	 * Information on the axes.
	 */
	public var axesInfo(default, set):Array<AxisInfo>;

	private function set_axesInfo(info:Array<AxisInfo>) {
		return axesInfo = info;
	}

	/**
	 * Ticks per drawn axis. 
	 */
	public var ticksPerInfo(default, set):Array<Array<Tick>>;

	private function set_ticksPerInfo(ticks:Array<Array<Tick>>) {
		return ticksPerInfo = ticks;
	}

	/**
	 * Zero Point of all axes.
	 */
	public var zeroPoint(default, set):Point;

	private function set_zeroPoint(point:Point) {
		return zeroPoint = point;
	}

	public var firstGen:Bool = true;

	public function new(axisInfo:Array<AxisInfo>, coordSystem:CoordinateSystem) {
		if (axisInfo == null || axisInfo.length == 0) {
			throw new Exception("No AxisInfo found.");
		}

		if (Statistics.any(axisInfo, info -> info.type == null)) {
			throw new Exception("Axis cannot be created without type. You can generate the type via setAxisInfo in AxisInfo or provide one by hand.");
		}

		if (Statistics.any(axisInfo, info -> info.tickInfo == null)) {
			throw new Exception("Axis cannot be created without TickInfo. You can generate the TickInfo via setAxisInfo in AxisInfo or provide one by hand.");
		}

		axesInfo = axisInfo;
		ticksPerInfo = [];
		this.coordSystem = coordSystem;

		for (info in axisInfo) {
			ticksPerInfo.push([]);
		}
	}

	final titleSpace:Float = 12;
	final subTitleSpace:Float = 20;

	/**
	 * Positions the startpoints of the axes according to the other axes, titles and margins.
	 */
	public function positionStartPoint() {
		var width = coordSystem.end.x - coordSystem.start.x;
		var height = coordSystem.end.y - coordSystem.start.y;

		this.zeroPoint = new Point(coordSystem.start.x + width / 2, coordSystem.start.y + height / 2);
		// First position zero point according to axes information. Only the first two axes will be considered.
		var xaxesNum:Int = 0;
		var yaxesNum:Int = 0;
		for (info in this.axesInfo) {
			var rotation = info.rotation;
			switch (rotation) {
				case 0:
					if (xaxesNum == 0) {
						this.zeroPoint.x = info.tickInfo.zeroIndex * width / (info.tickInfo.tickNum - 1) + coordSystem.start.x + info.tickMargin;
					}
					info.length = width;
					xaxesNum++;
				case 90:
					if (yaxesNum == 0) {
						this.zeroPoint.y = info.tickInfo.zeroIndex * height / (info.tickInfo.tickNum - 1) + coordSystem.start.y + info.tickMargin;
					}
					info.length = height;
					yaxesNum++;
				case _:
			}
		}
		// Then we change the height of the axes and position of zeroPoint according to present titles.
		var newHeight = height;
		var newWidth = width;
		for (info in this.axesInfo) {
			if (info.title == null) {
				continue;
			}
			if (info.title.position != null) {
				continue;
			}
			switch (info.rotation) {
				case 0:
					if (zeroPoint.y <= coordSystem.start.y + titleSpace) {
						newHeight = height - titleSpace;
						zeroPoint.y = coordSystem.start.y + (height - newHeight) + info.tickMargin;
					}
				case 90:
					if (zeroPoint.x <= (coordSystem.start.x + titleSpace)) {
						newWidth = width - titleSpace;
						zeroPoint.x = coordSystem.start.x + (width - newWidth) + info.tickMargin;
					}
				case _:
			}
		}
		// Repeat for subtitles
		for (info in this.axesInfo) {
			if (info.subTitle == null) {
				continue;
			}
			if (info.title == null) {
				trace("WARNING: Trying to set a subtitle without a title. This is not possible, and the step will be skipped!");
				continue;
			}
			if (info.subTitle.position != null) {
				continue;
			}
			switch (info.rotation) {
				case 0:
					if (zeroPoint.y <= (coordSystem.start.y + subTitleSpace)) {
						newHeight = height - subTitleSpace;
						zeroPoint.y = coordSystem.start.y + (height - newHeight) + info.tickMargin;
					}
				case 90:
					if (zeroPoint.x <= (coordSystem.start.x + subTitleSpace)) {
						newWidth = width - subTitleSpace;
						zeroPoint.x = coordSystem.start.x + (width - newWidth) + info.tickMargin;
					}
				case _:
			}
		}
		// Lastly set the start positions of the axes according to zeroPoint and newWidth or newHeight
		for (info in this.axesInfo) {
			var rotation = info.rotation;
			if (info.start == null) {
				info.start = new Point(0, 0);
			}
			switch (rotation) {
				case 0:
					var leftEdge = coordSystem.start.x;
					if (width != newWidth) {
						leftEdge = coordSystem.start.x + (width - newWidth);
					}
					info.start.x = leftEdge;

					info.start.y = zeroPoint.y;
					info.length = newWidth;
				case 90:
					var bottomEdge = coordSystem.start.y;
					if (height != newHeight) {
						bottomEdge = coordSystem.start.y + (height - newHeight);
					}
					info.start.y = bottomEdge;

					info.length = newHeight;
					info.start.x = zeroPoint.x;
				case _:
			}
		}

		for (info in this.axesInfo) {
			info.end = Trigonometry.positionEndpoint(info.start, info.rotation, info.length);
		}
	}
}
