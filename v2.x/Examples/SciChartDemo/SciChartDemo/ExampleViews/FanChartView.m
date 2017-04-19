//
//  SCIFanChartView.m
//  SciChartDemo
//
//  Created by Hrybenuik Mykola on 9/21/16.
//  Copyright © 2016 ABT. All rights reserved.
//

#import "FanChartView.h"
#import <SciChart/SciChart.h>
#import "DataManager.h"

typedef void(^SCIGeneratingPointsHandler)(double max, double min, double value1, double value2, double value3, double value4, double actualValue, NSDate *date);

@implementation FanChartView

@synthesize sciChartSurfaceView;
@synthesize surface;

- (void)generateRenderableSeries {
    
    SCIXyDataSeries *xyDataSeries = [[SCIXyDataSeries alloc] initWithXType:SCIDataType_DateTime YType:SCIDataType_Double SeriesType:SCITypeOfDataSeries_DefaultType];
    
    SCIXyyDataSeries *xyyDataSeries = [[SCIXyyDataSeries alloc] initWithXType:SCIDataType_DateTime YType:SCIDataType_Double SeriesType:SCITypeOfDataSeries_DefaultType];
    
    SCIXyyDataSeries *xyyDataSeries1 = [[SCIXyyDataSeries alloc] initWithXType:SCIDataType_DateTime YType:SCIDataType_Double SeriesType:SCITypeOfDataSeries_DefaultType];
    
    SCIXyyDataSeries *xyyDataSeries2 = [[SCIXyyDataSeries alloc] initWithXType:SCIDataType_DateTime YType:SCIDataType_Double SeriesType:SCITypeOfDataSeries_DefaultType];
    
    [self p_generatingDataSourceWithCount:10
                               andHandler:^(double max, double min, double value1, double value2, double value3, double value4, double actualValue, NSDate *date) {
                                   [xyDataSeries appendX:SCIGeneric(date) Y:SCIGeneric(actualValue)];
                                   [xyyDataSeries appendX:SCIGeneric(date) Y1:SCIGeneric(max) Y2:SCIGeneric(min)];
                                   [xyyDataSeries1 appendX:SCIGeneric(date) Y1:SCIGeneric(value1) Y2:SCIGeneric(value4)];
                                   [xyyDataSeries2 appendX:SCIGeneric(date) Y1:SCIGeneric(value2) Y2:SCIGeneric(value3)];
                               }];
    
    [surface.renderableSeries add:[self p_generateRenderableSeriesWithDataSeries:xyyDataSeries]];
    [surface.renderableSeries add:[self p_generateRenderableSeriesWithDataSeries:xyyDataSeries1]];
    [surface.renderableSeries add:[self p_generateRenderableSeriesWithDataSeries:xyyDataSeries2]];
    
    SCIFastLineRenderableSeries * fourierRenderableSeries = [SCIFastLineRenderableSeries new];
    fourierRenderableSeries.style.linePen = [[SCISolidPenStyle alloc] initWithColor:[UIColor redColor] withThickness:1];
    [fourierRenderableSeries setDataSeries:xyDataSeries];
    [surface.renderableSeries add:fourierRenderableSeries];
    
    [surface invalidateElement];
}

- (SCIBandRenderableSeries*)p_generateRenderableSeriesWithDataSeries:(SCIXyyDataSeries*)dataSeries {
    SCIBandRenderableSeries * bandRenderableSeries = [[SCIBandRenderableSeries alloc] init];
    [bandRenderableSeries.style setBrush1:[[SCISolidBrushStyle alloc] initWithColor:[UIColor colorWithRed:1.f green:0.4f blue:0.4f alpha:0.5]]];
    [bandRenderableSeries.style setBrush2:[[SCISolidBrushStyle alloc] initWithColor:[UIColor colorWithRed:1.f green:0.4f blue:0.4f alpha:0.5]]];
    [bandRenderableSeries.style setPen2:[[SCISolidPenStyle alloc] initWithColor:[UIColor clearColor] withThickness:1.0]];
    [bandRenderableSeries.style setPen1:[[SCISolidPenStyle alloc] initWithColor:[UIColor clearColor] withThickness:1.0]];
    [bandRenderableSeries.style setDrawPointMarkers:NO];
    [bandRenderableSeries setDataSeries:dataSeries];
    return bandRenderableSeries;
}

- (void)p_generatingDataSourceWithCount:(int)count andHandler:(SCIGeneratingPointsHandler)handler {
    
    double lastValue = 0.0f;
    NSDate *date = [NSDate date];
    
    for (int i = 0; i <= count; i++) {
        double nextValue = lastValue + randf(-0.5, 0.5);
        lastValue = nextValue;
        date = [date dateByAddingTimeInterval: 3600*24];
        
        double maxValue = NAN;
        double minValue = NAN;
        double value1 = NAN;
        double value2 = NAN;
        double value3 = NAN;
        double value4 = NAN;
        
        if (i > 4) {
            maxValue = nextValue + (i - 5) * 0.3;
            value4 = nextValue + (i - 5) * 0.2;
            value3 = nextValue + (i - 5) * 0.1;
            value2 = nextValue - (i - 5) * 0.1;
            value1 = nextValue - (i - 5) * 0.2;
            minValue = nextValue - (i - 5) * 0.3;
        }
        
        if (handler) {
            handler(maxValue, minValue, value1, value2, value3, value4, nextValue, date);
        }
    }
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        SCIChartSurfaceView * view = [[SCIChartSurfaceView alloc]init];
        sciChartSurfaceView = view;
        
        [sciChartSurfaceView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self addSubview:sciChartSurfaceView];
        NSDictionary *layout = @{@"SciChart":sciChartSurfaceView};
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(0)-[SciChart]-(0)-|" options:0 metrics:0 views:layout]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[SciChart]-(0)-|" options:0 metrics:0 views:layout]];
        [self initializeSurfaceData];
    }
    
    return self;
}

- (void)initializeSurfaceData {
    surface = [[SCIChartSurface alloc] initWithView: sciChartSurfaceView];
    
    id<SCIAxis2DProtocol> axis = [[SCINumericAxis alloc] init];
    [axis setGrowBy: [[SCIDoubleRange alloc]initWithMin:SCIGeneric(0.05) Max:SCIGeneric(0.05)]];
    [surface.yAxes add:axis];
    
    axis = [[SCIDateTimeAxis alloc] init];
    [axis setGrowBy: [[SCIDoubleRange alloc]initWithMin:SCIGeneric(0.05) Max:SCIGeneric(0.05)]];
    [surface.xAxes add:axis];
    
    SCIXAxisDragModifier * xDragModifier = [SCIXAxisDragModifier new];
    xDragModifier.dragMode = SCIAxisDragMode_Scale;
    xDragModifier.clipModeX = SCIZoomPanClipMode_None;
    
    SCIYAxisDragModifier * yDragModifier = [SCIYAxisDragModifier new];
    yDragModifier.dragMode = SCIAxisDragMode_Pan;
    
    SCIPinchZoomModifier * pzm = [[SCIPinchZoomModifier alloc] init];
    SCIZoomExtentsModifier * zem = [[SCIZoomExtentsModifier alloc] init];
    SCIRolloverModifier * rollover = [[SCIRolloverModifier alloc] init];
    
    SCIModifierGroup * gm = [[SCIModifierGroup alloc] initWithChildModifiers:@[xDragModifier, yDragModifier, pzm, zem, rollover]];
    surface.chartModifier = gm;
    
    [self generateRenderableSeries];
}

@end
