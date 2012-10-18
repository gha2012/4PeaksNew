//
//  GHRawDataPopoverViewController.m
//  4PeaksNew
//
//  Created by Gregor Hagelüken on 08.10.12.
//  Copyright (c) 2012 Gregor Hagelueken. All rights reserved.
//

#import "GHRawDataPopoverViewController.h"
#import <CorePlot/CorePlot.h>
#import "GHAbifFile.h"
#define X_VAL @"X_VAL"
#define Y_VAL @"Y_VAL"

@interface GHRawDataPopoverViewController ()

@end

@implementation GHRawDataPopoverViewController
@synthesize abifFile = _abifFile, graphRange = _graphRange;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.rawDataPopover = [[NSPopover alloc] init];
        self.rawDataPopover.contentViewController = self;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibName abifFile: (GHAbifFile *) anAbifFile andGraphRange: (NSRange) graphRange isReverseComplement: (BOOL) aBoolValue
{
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        self.rawDataPopover = [[NSPopover alloc] init];
        self.rawDataPopover.contentViewController = self;
        _abifFile=[[GHAbifFile alloc] init];
        _abifFile=anAbifFile;
        _graphRange=NSMakeRange(graphRange.location, graphRange.length);
        reverseComplement=aBoolValue;
    }
    
    return self;
}
-(void)awakeFromNib {
    [self plotGraphs:nil];
}


- (IBAction)plotGraphs:(id)sender {
    double xAxisStart = _graphRange.location;
    double xAxisLength = _graphRange.length; //[_abifFile.DATA09pointsForPlot count];
    maxY = 1000;
    double yAxisStart = -10;
    double yAxisLength = maxY;
    
    
    CPTXYGraph *graph = [[CPTXYGraph alloc] initWithFrame:[_hostingView bounds]];
    _hostingView.hostedGraph=graph;
    
    //white background
    CPTTheme *myTheme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
    [graph applyTheme:myTheme];
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    axisSet.xAxis.majorIntervalLength=CPTDecimalFromDouble(1000000);
    graph.axisSet=axisSet;
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(xAxisStart) length:CPTDecimalFromDouble(xAxisLength)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(yAxisStart) length:CPTDecimalFromDouble(yAxisLength)];
    
    //DATA09 G
    CPTScatterPlot *dataSourceData09Plot = [[CPTScatterPlot alloc] init];
    dataSourceData09Plot.cachePrecision = CPTPlotCachePrecisionAuto;
    dataSourceData09Plot.dataSource=self;
    dataSourceData09Plot.identifier=@"DATA09";
    CPTMutableLineStyle *gLine=[[CPTMutableLineStyle alloc]init];
    if (!reverseComplement)
        gLine.lineColor = [CPTColor blackColor];
    else
        gLine.lineColor = [CPTColor blueColor];
    dataSourceData09Plot.dataLineStyle=gLine;
    //NSLog(@"%@",dataSourceData09Plot);
    
    //DATA10 A
    CPTScatterPlot *dataSourceData10Plot = [[CPTScatterPlot alloc] init];
    dataSourceData10Plot.cachePrecision = CPTPlotCachePrecisionAuto;
    dataSourceData10Plot.dataSource=self;
    dataSourceData10Plot.identifier=@"DATA10";
    CPTMutableLineStyle *aLine=[[CPTMutableLineStyle alloc]init];
    if (!reverseComplement)
        aLine.lineColor = [CPTColor greenColor];
    else
        aLine.lineColor = [CPTColor redColor];
    dataSourceData10Plot.dataLineStyle=aLine;
    //NSLog(@"%@",dataSourceData10Plot);
    
    //DATA11 T
    CPTScatterPlot *dataSourceData11Plot = [[CPTScatterPlot alloc] init];
    dataSourceData11Plot.cachePrecision = CPTPlotCachePrecisionAuto;
    dataSourceData11Plot.dataSource=self;
    dataSourceData11Plot.identifier=@"DATA11";
    CPTMutableLineStyle *tLine=[[CPTMutableLineStyle alloc]init];
    if (!reverseComplement)
        tLine.lineColor = [CPTColor redColor];
    else
        tLine.lineColor = [CPTColor greenColor];
    dataSourceData11Plot.dataLineStyle=tLine;
    //NSLog(@"%@",dataSourceData11Plot);
    
    //DATA12 C
    CPTScatterPlot *dataSourceData12Plot = [[CPTScatterPlot alloc] init];
    dataSourceData12Plot.cachePrecision = CPTPlotCachePrecisionAuto;
    dataSourceData12Plot.dataSource=self;
    dataSourceData12Plot.identifier=@"DATA12";
    CPTMutableLineStyle *cLine =[[CPTMutableLineStyle alloc]init];
    if (!reverseComplement)
        cLine.lineColor = [CPTColor blueColor];
    else
        cLine.lineColor = [CPTColor blackColor];
    dataSourceData12Plot.dataLineStyle=cLine;
    //NSLog(@"%@",dataSourceData12Plot);
    
    [graph addPlot:dataSourceData09Plot];
    [graph addPlot:dataSourceData10Plot];
    [graph addPlot:dataSourceData11Plot];
    [graph addPlot:dataSourceData12Plot];
    //[graph reloadData];
}
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    NSLog(@"%lu", [_abifFile.DATA09pointsForPlot count]);
    return [_abifFile.DATA09pointsForPlot count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    //NSLog(@"%@",_abifFile.DATA10pointsForPlot);
    NSDictionary *point=[[NSDictionary alloc]init];
    if ([(NSString *)plot.identifier isEqualToString:@"DATA09"]) {
        point=[NSDictionary dictionaryWithDictionary:[_abifFile.DATA09pointsForPlot objectAtIndex:index]];
    }
    if ([(NSString *)plot.identifier isEqualToString:@"DATA10"]) {
        point=[NSDictionary dictionaryWithDictionary:[_abifFile.DATA10pointsForPlot objectAtIndex:index]];
        //NSLog(@"%@",point);
    }
    if ([(NSString *)plot.identifier isEqualToString:@"DATA11"]) {
        point=[NSDictionary dictionaryWithDictionary:[_abifFile.DATA11pointsForPlot objectAtIndex:index]];
    }
    if ([(NSString *)plot.identifier isEqualToString:@"DATA12"]) {
        point=[NSDictionary dictionaryWithDictionary:[_abifFile.DATA12pointsForPlot objectAtIndex:index]];
    }
    NSNumber *num = nil;
    //X-data
    if (fieldEnum == CPTScatterPlotFieldX)
    {
        num = [point valueForKey:X_VAL];
        //reverse the plot if reverseComplement is displayed
        if (reverseComplement) {
            int delta=[num integerValue]-_graphRange.location;
            int newX=_graphRange.location+_graphRange.length-delta;
            num=[NSNumber numberWithInt:newX];
        }
    }
    //Y-data
    else
    {
        if ([(NSString *)plot.identifier isEqualToString:@"DATA09"]) {
            num = [point valueForKey:Y_VAL];
        }
        if ([(NSString *)plot.identifier isEqualToString:@"DATA10"]) {
            num = [point valueForKey:Y_VAL];
        }
        if ([(NSString *)plot.identifier isEqualToString:@"DATA11"]) {
            num = [point valueForKey:Y_VAL];
        }
        if ([(NSString *)plot.identifier isEqualToString:@"DATA12"]) {
            num = [point valueForKey:Y_VAL];
        }
    }
    return num;
}

@end
