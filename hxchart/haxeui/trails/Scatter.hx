package hxchart.haxeui.trails;

import hxchart.core.coordinates.CoordinateSystem;
import haxe.ui.events.MouseEvent;
import hxchart.haxeui.utils.ConvertCoords;
import hxchart.core.styling.TrailStyle;
import hxchart.core.chart.ChartStatus;
import hxchart.core.trails.TrailInfo;
import hxchart.haxeui.axis.Axis;
import haxe.ui.containers.Box;
import haxe.ui.styles.elements.Directive;
import haxe.ui.styles.elements.RuleElement;
import haxe.ui.styles.StyleSheet;
import hxchart.core.events.EventLayer.EventHandler;
import hxchart.core.optimization.OptimGrid;
import hxchart.core.optimization.Quadtree;
import haxe.ui.components.Canvas;
import haxe.ui.geom.Point;
import haxe.ui.containers.Absolute;
import haxe.ui.util.Color;
import hxchart.core.trails.Scatter in ScatterCalc;
import hxchart.core.optimization.OptimizationType;

class Scatter {
	public var id:String;
	public var axisID:String;
	public var axes:Axis;

	public var dataLayer:Absolute;
	public var dataCanvas:Canvas;

	var quadTree:Quadtree;
	var optimGrid:OptimGrid;
	var gridStep:Float = 1;
	var useOptimization:Bool;
	var keepHoverOn:Bool = false;

	public var scatterCalc:ScatterCalc;

	@:allow(hxchart.tests)
	public var chartInfo:TrailInfo;

	public var colorPalette:Array<Int>;

	public var parent:Absolute;
	public var eventHandler:EventHandler;
	public var hoverLayer:Absolute;
	public var clickLayer:Canvas;

	public function new(chartInfo:TrailInfo, axes:Axis, parent:Absolute, id:String, axisID:String, eventHandler:EventHandler, coordSystem:CoordinateSystem) {
		scatterCalc = new ScatterCalc(chartInfo, axes.axisCalc, coordSystem);
		scatterCalc.validateChart();

		this.parent = parent;
		this.eventHandler = eventHandler;
		hoverLayer = new Absolute();
		hoverLayer.id = id + "_hover";
		hoverLayer.percentHeight = 100;
		hoverLayer.percentWidth = 100;
		var hoverCanvas = new Canvas();
		hoverCanvas.percentWidth = 100;
		hoverCanvas.percentHeight = 100;
		hoverLayer.addComponent(hoverCanvas);
		hoverLayer.styleSheet = new StyleSheet();
		hoverLayer.styleSheet.addRule(new RuleElement(".default-hover-box", [
			new Directive("border-size", VDimension(PX(1))),
			new Directive("border-color", VColor(0x000000)),
			new Directive("border-style", VString("solid")),
			new Directive("background-color", VColor(0xf5f5f5)),
			new Directive("padding", VDimension(PX(10)))
		]));
		clickLayer = new Canvas();
		clickLayer.id = id + "_click";
		clickLayer.percentHeight = 100;
		clickLayer.percentWidth = 100;
		dataCanvas = new Canvas();
		dataCanvas.id = id;
		dataCanvas.percentHeight = 100;
		dataCanvas.percentWidth = 100;
		this.id = id;
		this.axisID = axisID;
		this.chartInfo = chartInfo;
		if (axes != null) {
			this.axes = axes;
		}
		if (chartInfo.optimizationInfo != null && chartInfo.optimizationInfo.reduceVia != null) {
			useOptimization = true;
			switch (chartInfo.optimizationInfo.reduceVia) {
				case OptimizationType.optimGrid:
					if (chartInfo.optimizationInfo.gridStep != null) {
						gridStep = chartInfo.optimizationInfo.gridStep;
					}
					optimGrid = new OptimGrid(parent.width, parent.height, gridStep);
				case OptimizationType.quadTree:
					quadTree = new Quadtree(new Region(0, parent.width, 0, parent.height));
			}
		}
	}

	public function validateChart(status:ChartStatus) {
		var canvasComponent = parent.findComponent(id);
		if (canvasComponent != null) {
			dataCanvas = canvasComponent;
		}
		var canvasComponent = parent.findComponent(id + "_hover");
		if (canvasComponent != null) {
			hoverLayer = canvasComponent;
		}
		var canvasComponent = parent.findComponent(id + "_click");
		if (canvasComponent != null) {
			clickLayer = canvasComponent;
		}
		render(chartInfo.style);
	}

	public function render(style:TrailStyle) {
		// Hover event handling
		eventHandler.hoverHandlers.push(function(e) {
			if (e is MouseEvent) {
				var event:MouseEvent = e;
				// hoverLayer.componentGraphics.clear();
				// if (chartInfo.events != null && chartInfo.events.onHover != null) {
				// 	for (group in dataByGroup) {
				// 		for (dataPoint in group) {
				// 			if (!dataPoint.allowed) {
				// 				continue;
				// 			}
				// 			if (inPointRadius(new Point(e.localX, e.localY), new Point(dataPoint.coord.x + parent.left, dataPoint.coord.y + parent.top),
				// 				dataPoint.size + dataPoint.borderThickness)) {
				// 				var selectInfo = chartInfo.events.onHover({
				// 					coords: [dataPoint.coord],
				// 					border: {
				// 						thickness: dataPoint.borderThickness,
				// 						color: dataPoint.borderColor,
				// 						alpha: dataPoint.borderAlpha
				// 					},
				// 					alpha: dataPoint.alpha,
				// 					color: dataPoint.color,
				// 					size: dataPoint.size
				// 				});
				// 				hoverLayer.componentGraphics.strokeStyle(selectInfo.border.color, selectInfo.border.thickness, selectInfo.border.alpha);
				// 				hoverLayer.componentGraphics.fillStyle(selectInfo.color, selectInfo.alpha);
				// 				hoverLayer.componentGraphics.circle(selectInfo.coords[0].x, selectInfo.coords[0].y, selectInfo.size);
				// 			}
				// 		}
				// 	}
				// 	return;
				// }
				for (i in 1...hoverLayer.numComponents) {
					hoverLayer.removeComponentAt(i);
				}
				for (group in scatterCalc.dataByGroup) {
					for (dataPoint in group) {
						if (!dataPoint.allowed) {
							continue;
						}
						if (inPointRadius(new Point(event.localX, event.localY), new Point(dataPoint.coord.x + parent.left, dataPoint.coord.y + parent.top),
							dataPoint.size + dataPoint.borderThickness)) {
							var abs:Box = new Box();
							abs.percentWidth = 10;
							abs.percentHeight = 20;
							abs.left = dataPoint.coord.x;
							abs.top = 0;
							abs.addClass("default-hover-box");
							abs.onMouseOver = function(e) {}
							hoverLayer.addComponent(abs);
							var canvas:Canvas = cast(hoverLayer.childComponents[0], Canvas);
							canvas.componentGraphics.fillStyle(Color.fromString("#ffffff"), 0.5);
							canvas.componentGraphics.strokeStyle(0x000000, 1, 1);
							canvas.componentGraphics.rectangle(dataPoint.coord.x, dataPoint.coord.y, 10, 20);
							canvas.componentGraphics.circle(dataPoint.coord.x, dataPoint.coord.y, dataPoint.size);
						}
					}
				}
			}
		});
		// Click event handling
		eventHandler.clickHandlers.push(function(e) {
			if (e is MouseEvent) {
				var event:MouseEvent = e;
				clickLayer.componentGraphics.clear();
				if (chartInfo.events != null && chartInfo.events.onClick != null) {
					for (group in scatterCalc.dataByGroup) {
						for (dataPoint in group) {
							if (!dataPoint.allowed) {
								continue;
							}
							if (inPointRadius(new Point(event.localX, event.localY), new Point(dataPoint.coord.x, dataPoint.coord.y),
								dataPoint.size + dataPoint.borderThickness)) {
								var selectInfo = chartInfo.events.onHover({
									coords: [dataPoint.coord],
									border: {
										thickness: dataPoint.borderThickness,
										color: dataPoint.borderColor,
										alpha: dataPoint.borderAlpha
									},
									alpha: dataPoint.alpha,
									color: dataPoint.color,
									size: dataPoint.size
								});
								// hoverLayer.componentGraphics.strokeStyle(selectInfo.border.color, selectInfo.border.thickness, selectInfo.border.alpha);
								// hoverLayer.componentGraphics.fillStyle(selectInfo.color, selectInfo.alpha);
								// hoverLayer.componentGraphics.circle(selectInfo.coords[0].x, selectInfo.coords[0].y, selectInfo.size);
							}
						}
					}
					return;
				}
				for (group in scatterCalc.dataByGroup) {
					for (dataPoint in group) {
						if (!dataPoint.allowed) {
							continue;
						}
						if (inPointRadius(new Point(event.localX, event.localY), new Point(dataPoint.coord.x, dataPoint.coord.y),
							dataPoint.size + dataPoint.borderThickness)) {
							// hoverLayer.componentGraphics.fillStyle(Color.fromString("#ffffff"), 0.5);
							// hoverLayer.componentGraphics.circle(dataPoint.coord.x, dataPoint.coord.y, dataPoint.size);
						}
					}
				}
			}
		});

		dataCanvas.componentGraphics.clear();
		var coordSystem = {
			zero: new Point(0, 0),
			width: parent.width,
			height: parent.height
		}
		if (chartInfo.type == line) {
			dataCanvas.componentGraphics.clear();
			for (group in scatterCalc.dataByGroup) {
				var start = ConvertCoords.convertFromCore(scatterCalc.coordSystem, coordSystem, group[0].coord);
				var last = start;
				if (style.positionOption == filled) {
					dataCanvas.componentGraphics.fillStyle(group[0].color, 0.5);
				} else {
					dataCanvas.componentGraphics.fillStyle(0x000000, 0);
				}
				dataCanvas.componentGraphics.strokeStyle(group[0].color, group[0].size, group[0].alpha);
				#if !(haxeui_heaps)
				dataCanvas.componentGraphics.beginPath();
				#end
				dataCanvas.componentGraphics.moveTo(last.x, last.y);
				for (i => dataPoint in group) {
					if (!dataPoint.allowed) {
						continue;
					}
					var coord = ConvertCoords.convertFromCore(scatterCalc.coordSystem, coordSystem, dataPoint.coord);
					dataCanvas.componentGraphics.lineTo(coord.x, coord.y);
					last = coord;
				}
				if (style.positionOption == filled) {
					dataCanvas.componentGraphics.lineTo(last.x, axes.axisCalc.ticksPerInfo[1][axes.axisCalc.axesInfo[1].tickInfo.zeroIndex].middlePos.y);
					dataCanvas.componentGraphics.lineTo(start.x, axes.axisCalc.ticksPerInfo[1][axes.axisCalc.axesInfo[1].tickInfo.zeroIndex].middlePos.y);
					dataCanvas.componentGraphics.lineTo(start.x, start.y);
					#if !(haxeui_heaps)
					dataCanvas.componentGraphics.closePath();
					#end
				}
			}
		} else {
			for (group in scatterCalc.dataByGroup) {
				for (dataPoint in group) {
					if (!dataPoint.allowed) {
						continue;
					}
					var coord = ConvertCoords.convertFromCore(scatterCalc.coordSystem, coordSystem, dataPoint.coord);
					dataCanvas.componentGraphics.strokeStyle(dataPoint.borderColor, dataPoint.borderThickness, dataPoint.borderAlpha);
					dataCanvas.componentGraphics.fillStyle(dataPoint.color, dataPoint.alpha);
					dataCanvas.componentGraphics.circle(coord.x, coord.y, dataPoint.size);
				}
			}
		}
		var canvasComponent = parent.findComponent(id);
		if (canvasComponent == null) {
			parent.addComponent(dataCanvas);
			parent.addComponent(hoverLayer);
			parent.addComponent(clickLayer);
		}
	}

	private function inPointRadius(mouseCoords:Point, pointCenter:Point, size:Float) {
		var dist = Math.pow(pointCenter.x - mouseCoords.x, 2) + Math.pow(pointCenter.y - mouseCoords.y, 2);
		return dist <= Math.pow(size, 2);
	}
}
