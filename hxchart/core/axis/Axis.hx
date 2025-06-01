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
    // Step 1: Initialize zeroPoint to geometric center
    this.zeroPoint = new Point(coordSystem.left + coordSystem.width / 2, coordSystem.bottom + coordSystem.height / 2);

    var xaxesNum:Int = 0;
    var yaxesNum:Int = 0;

    // Step 2: Adjust zeroPoint based on the first X and Y axis's zeroIndex.
    // (This part remains unchanged from the previous subtask's version)
    for (info in this.axesInfo) {
        var rotation = info.rotation;
        var tickInfo = info.tickInfo;
        var tickNum = tickInfo.tickNum;

        if (Std.isOfType(tickInfo, StringTickInfo)) {
             tickNum++;
        }

        var divisor = (tickNum - 1);
        if (divisor == 0) divisor = 1;

        switch (rotation) {
            case 0:
                if (xaxesNum == 0) {
                    this.zeroPoint.x = tickInfo.zeroIndex * coordSystem.width / divisor + coordSystem.left + info.tickMargin;
                }
                // info.length is calculated later
                xaxesNum++;
                break;
            case 90:
                if (yaxesNum == 0) {
                    this.zeroPoint.y = tickInfo.zeroIndex * coordSystem.height / divisor + coordSystem.bottom + info.tickMargin;
                }
                // info.length is calculated later
                yaxesNum++;
                break;
            case _:
        }
    }

    // Step 3: Adjust newWidth, newHeight, and potentially this.zeroPoint due to titles/subtitles.
    // This section is REPLACED with the new logic.
    var newHeight = coordSystem.height;
    var newWidth = coordSystem.width;

    var spaceTakenBottom = 0;
    var spaceTakenLeft = 0;
    var titleFixedSize = 12;    // Standard size for title text area
    var subtitleFixedSize = 20; // Standard size for subtitle text area (assumed to include title if both present)

    for (info in this.axesInfo) {
        switch (info.rotation) {
            case 0: // Horizontal axis, titles/subtitles are assumed at the bottom if auto-positioned
                if (info.subTitle != null && info.subTitle.position == null) {
                    spaceTakenBottom = Math.max(spaceTakenBottom, subtitleFixedSize);
                } else if (info.title != null && info.title.position == null) {
                    spaceTakenBottom = Math.max(spaceTakenBottom, titleFixedSize);
                }
                break;
            case 90: // Vertical axis, titles/subtitles are assumed at the left if auto-positioned
                if (info.subTitle != null && info.subTitle.position == null) {
                    spaceTakenLeft = Math.max(spaceTakenLeft, subtitleFixedSize);
                } else if (info.title != null && info.title.position == null) {
                    spaceTakenLeft = Math.max(spaceTakenLeft, titleFixedSize);
                }
                break;
            case _:
        }
    }

    newHeight = coordSystem.height - spaceTakenBottom;
    newWidth = coordSystem.width - spaceTakenLeft;

    // Adjust zeroPoint if it falls into the space taken by titles/subtitles
    if (spaceTakenBottom > 0) {
        var minZeroY = coordSystem.bottom + spaceTakenBottom;
        if (this.zeroPoint.y < minZeroY) {
            this.zeroPoint.y = minZeroY;
        }
    }

    if (spaceTakenLeft > 0) {
        var minZeroX = coordSystem.left + spaceTakenLeft;
        if (this.zeroPoint.x < minZeroX) {
            this.zeroPoint.x = minZeroX;
        }
    }
    // End of REPLACED Step 3 logic

    // Step 4: Set final start positions and lengths for each axis.
    // (This part remains unchanged from the previous subtask's version, using the new newHeight/newWidth)
    for (info in this.axesInfo) {
        var rotation = info.rotation;
        if (info.start == null) {
            info.start = new Point(0, 0);
        }
        switch (rotation) {
            case 0: // Horizontal axis
                var axisActualLeftEdge = coordSystem.left;
                if (newWidth < coordSystem.width) {
                    axisActualLeftEdge = coordSystem.left + (coordSystem.width - newWidth);
                }

                info.start.x = axisActualLeftEdge + info.tickMargin;
                info.start.y = this.zeroPoint.y;

                info.length = newWidth - (2 * info.tickMargin);
                if (info.length < 0) info.length = 0;
                break;

            case 90: // Vertical axis
                var axisActualBottomEdge = coordSystem.bottom;
                if (newHeight < coordSystem.height) {
                    axisActualBottomEdge = coordSystem.bottom + (coordSystem.height - newHeight);
                }

                info.start.y = axisActualBottomEdge + info.tickMargin;
                info.start.x = this.zeroPoint.x;

                info.length = newHeight - (2 * info.tickMargin);
                if (info.length < 0) info.length = 0;
                break;
            case _:
        }
    }

    // Step 5: Calculate end points based on new start and length
    // (This part remains unchanged from the previous subtask's version)
    for (info in this.axesInfo) {
        info.end = Trigonometry.positionEndpoint(info.start, info.rotation, info.length);
    }
}
}
