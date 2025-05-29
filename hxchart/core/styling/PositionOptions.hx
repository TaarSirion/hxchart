package hxchart.core.styling;

/**
 * Position Options for a chart.
 * 
 * Depending on the chart this can be different things.
 */
enum PositionOption {
	/**
	 * - Barchart: Positions the bar next to each other. The `overlapEffect` is used for how much the bars overlap. A value of 
	 * 1 means no overlap, while 0 means full overlap. 
	 * - Linechart: No effect.
	 * 
	 * @param overlapEffect 
	 */
	layered(overlapEffect:Float);

	/**
	 * - Barchart: Positions the bars on top of each other.
	 * - Linechart: No effect.
	 */
	stacked;

	/**
	 * - Barchart: No effect.
	 * - Linechart: If the line should get filled to the x-axis.
	 */
	filled;
}
