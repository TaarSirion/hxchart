package hxchart.core.optimization;

/**
 * Options for optimizing the rendering process.
 * 
 * Only use when you know what you are doing, as this might result in a different looking plot.
 * 
 * *OptimizationTypes:*
 * - `optimGrid` Create an underlying grid, that hinders drawing multiple points over each other, or too close to each other. Use together with `gridStep` to set the size of each cell. Only use this for really large datasets.
 * - `quadTree` Use a quadtree to optimize the drawing of data. Only use this for semi large data (i.e. less than 100'000 points)
 * @param reduceVia Optional. *OptimizationType* to use, options are `optimGrid`, `quadTree`
 * @param gridStep Optional. Use together with `optimGrid`. Defines the size of each cell. Larger values result in less points being drawn!
 */ @:structInit class OptimizationInfo {
	@:optional public var reduceVia:OptimizationType;

	@:optional public var gridStep:Null<Float>;
}
