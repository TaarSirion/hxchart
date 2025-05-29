package hxchart.core.axis;

import hxchart.core.utils.Statistics;
import haxe.Exception;
import hxchart.core.utils.Trigonometry;
import hxchart.core.utils.Point;
import hxchart.core.tick.Tick;
import hxchart.core.utils.CompassOrientation;
import hxchart.core.tickinfo.StringTickInfo;
import hxchart.core.utils.CoordinateSystem;

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
			trace(tickNum, tickInfo);
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

	/**
	 * Positions the startpoints of the axes according to the other axes, titles and margins.
	 */
	public function positionStartPoint() {
		this.zeroPoint = new Point(coordSystem.left + coordSystem.width / 2, coordSystem.bottom + coordSystem.height / 2);
		// First position zero point according to axes information. Only the first two axes will be considered.
		var xaxesNum:Int = 0;
		var yaxesNum:Int = 0;
		for (info in this.axesInfo) {
			var rotation = info.rotation;
			switch (rotation) {
				case 0:
					if (xaxesNum == 0) {
						this.zeroPoint.x = info.tickInfo.zeroIndex * coordSystem.width / (info.tickInfo.tickNum - 1) + coordSystem.left + info.tickMargin;
					}
					info.length = coordSystem.width;
					xaxesNum++;
				case 90:
					if (yaxesNum == 0) {
						this.zeroPoint.y = info.tickInfo.zeroIndex * coordSystem.height / (info.tickInfo.tickNum - 1) + coordSystem.bottom + info.tickMargin;
					}
					info.length = coordSystem.height;
					yaxesNum++;
				case _:
			}
		}
		// Then we change the height of the axes and position of zeroPoint according to present titles.
		var newHeight = coordSystem.height;
		var newWidth = coordSystem.width;
		for (info in this.axesInfo) {
			switch (info.rotation) {
				case 0:
					trace(info.title, zeroPoint.y, coordSystem.bottom);
					if (info.title == null) {
						continue;
					}
					if (info.title.position != null) {
						continue;
					}

					if (zeroPoint.y <= coordSystem.bottom + 12) {
						newHeight = coordSystem.height - 12;
						zeroPoint.y = coordSystem.bottom + 12;
					} else {
						newHeight = coordSystem.height;
					}
				case 90:
					trace(info.title, zeroPoint.x, coordSystem.left);
					if (info.title == null) {
						continue;
					}
					if (info.title.position != null) {
						continue;
					}
					// We assume a fixed size of 12 for title
					if (zeroPoint.x <= (coordSystem.left + 12)) {
						newWidth = coordSystem.width - 12;
						zeroPoint.x = coordSystem.left + 12;
					} else {
						newWidth = coordSystem.width;
					}
				case _:
			}
		}
		// Repeat for subtitles
		for (info in this.axesInfo) {
			switch (info.rotation) {
				case 0:
					if (info.subTitle == null) {
						continue;
					}
					if (info.subTitle.position != null) {
						continue;
					}
					if (zeroPoint.y <= (coordSystem.bottom + 20)) {
						newHeight = coordSystem.height - 20;
						zeroPoint.y = coordSystem.bottom + 20;
					}
				case 90:
					trace(info.title, zeroPoint.x, coordSystem.left);
					if (info.subTitle == null) {
						continue;
					}
					if (info.subTitle.position != null) {
						continue;
					}
					if (zeroPoint.x <= (coordSystem.left + 20)) {
						newWidth = coordSystem.width - 20;
						zeroPoint.x = coordSystem.left + 20;
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
					if (info.length != newWidth) {
						info.length = newWidth;
						info.start.x = zeroPoint.x - info.tickMargin;
					} else {
						info.start.x = coordSystem.left;
					}
					info.start.y = zeroPoint.y;
				case 90:
					if (info.length != newHeight) {
						info.length = newHeight;
						info.start.y = zeroPoint.y - info.tickMargin;
					} else {
						info.start.y = coordSystem.bottom;
					}
					info.start.x = zeroPoint.x;
				case _:
			}
		}

		for (info in this.axesInfo) {
			info.end = Trigonometry.positionEndpoint(info.start, info.rotation, info.length);
		}
	}
}
