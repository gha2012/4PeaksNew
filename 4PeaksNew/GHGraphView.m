//
//  GHGraphView.m
//  ViewArray
//
//  Created by Gregor Hagelüken on 12.10.12.
//  Copyright (c) 2012 Gregor Hagelüken. All rights reserved.
//

#import "GHGraphView.h"

#define X_VAL @"X_VAL"
#define Y_VAL @"Y_VAL"
#define A_PLOT @"A_PLOT"
#define G_PLOT @"G_PLOT"
#define C_PLOT @"C_PLOT"
#define T_PLOT @"T_PLOT"

@implementation GHGraphView
@synthesize plots=_plots;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        _plots = [[NSDictionary alloc] init];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [NSGraphicsContext saveGraphicsState];
    //NSBezierPath* aPath = [NSBezierPath bezierPath];
    //[aPath moveToPoint:NSMakePoint(0.0, 0.0)];
    //[aPath lineToPoint:NSMakePoint(10.0, 10.0)];
    //[aPath curveToPoint:NSMakePoint(18.0, 21.0)
    //      controlPoint1:NSMakePoint(6.0, 2.0)
    //      controlPoint2:NSMakePoint(28.0, 10.0)];
    //[aPath appendBezierPathWithRect:NSMakeRect(2.0, 16.0, 8.0, 5.0)];
    //[aPath stroke];
    
    //A Plot
    NSArray *gPlotData = [NSArray arrayWithArray:[_plots valueForKey:G_PLOT]];
    NSArray *aPlotData = [NSArray arrayWithArray:[_plots valueForKey:A_PLOT]];
    NSArray *tPlotData = [NSArray arrayWithArray:[_plots valueForKey:T_PLOT]];
    NSArray *cPlotData = [NSArray arrayWithArray:[_plots valueForKey:C_PLOT]];
    
    NSBezierPath *gPlot = [[NSBezierPath alloc] init];
    NSBezierPath *aPlot = [[NSBezierPath alloc] init];
    NSBezierPath *tPlot = [[NSBezierPath alloc] init];
    NSBezierPath *cPlot = [[NSBezierPath alloc] init];
    if ([self.plots count] > 0) {
        gPlot = [self createPlotFromData:gPlotData];
        aPlot = [self createPlotFromData:aPlotData];
        tPlot = [self createPlotFromData:tPlotData];
        cPlot = [self createPlotFromData:cPlotData];
        [[NSColor blackColor] set];
        [gPlot stroke];
        [[NSColor greenColor] set];
        [aPlot stroke];
        [[NSColor redColor] set];
        [tPlot stroke];
        [[NSColor blueColor] set];
        [cPlot stroke];
        [[NSColor blackColor] set];
    }
    [NSGraphicsContext restoreGraphicsState];
}

- (NSBezierPath *)createPlotFromData: (NSArray *) dataForPlot {
    NSBezierPath *path = [[NSBezierPath alloc]init];
    //set first point
    NSDictionary *firstPoint = [NSDictionary dictionaryWithDictionary:[dataForPlot objectAtIndex:0]];
    [path moveToPoint:NSMakePoint([[firstPoint valueForKey:X_VAL]floatValue], [[firstPoint valueForKey:Y_VAL]floatValue])];

    for (int j = 1; j <=[dataForPlot count]-1; j++) {
        NSDictionary *point = [NSDictionary dictionaryWithDictionary:[dataForPlot objectAtIndex:j]];
        [path lineToPoint:NSMakePoint([[point valueForKey:X_VAL]floatValue], [[point valueForKey:Y_VAL]floatValue])];
        [path moveToPoint:NSMakePoint([[point valueForKey:X_VAL]floatValue], [[point valueForKey:Y_VAL]floatValue])];
        }
    return path;
}
@end
