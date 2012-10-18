//
//  GHRawDataViewControllerWindowController.m
//  4PeaksNew
//
//  Created by Gregor Hagelüken on 25.09.12.
//  Copyright (c) 2012 Gregor Hagelueken. All rights reserved.
//

#import "GHRawDataViewControllerWindowController.h"
#import "GHSequenceViewController.h"
#import "GHAbifFile.h"
#import "GHGraphView.h"

#define X_VAL @"X_VAL"
#define Y_VAL @"Y_VAL"
#define A_PLOT @"A_PLOT"
#define G_PLOT @"G_PLOT"
#define C_PLOT @"C_PLOT"
#define T_PLOT @"T_PLOT"

@interface GHRawDataViewControllerWindowController ()

@end

@implementation GHRawDataViewControllerWindowController
@synthesize baseViewControllerArray = _baseViewControllerArray;
@synthesize abifFile = _abifFile, graphRange = _graphRange;
- (id)init
{
    self = [super initWithWindowNibName:@"GHRawDataViewControllerWindowController"];
    return self;
}

- (id)initWithAbifFile: (GHAbifFile *) anAbifFile andGraphRange:(NSRange)graphRange isReverseComplement:(BOOL)aBoolValue {
    self = [super initWithWindowNibName:@"GHRawDataViewControllerWindowController"];
    _abifFile=[[GHAbifFile alloc] init];
    _abifFile=anAbifFile;
    _graphRange=NSMakeRange(graphRange.location, graphRange.length);
    reverseComplement=aBoolValue;
    
    
    return self;
}

-(void)awakeFromNib {
    _baseViewControllerArray = [[NSMutableArray alloc ] initWithCapacity:10];
    firstBaseRect.origin=NSMakePoint(0.0, 0.0);
    firstBaseRect.size=NSMakeSize(20.0, 118.0);
    baseCount = 0;
    rowCount = 1;
    //double xAxisStart = _graphRange.location;
    //double xAxisLength = _graphRange.length; //[_abifFile.DATA09pointsForPlot count];
    //generate data base by base
    for (int h = 1; h<=[[_abifFile valueForKeyPath:@"tags.PBAS2"] length]-2; h++) {
        NSMutableDictionary *dataForBase = [[NSMutableDictionary alloc]initWithCapacity:5];
        NSMutableArray *gPlot = [[NSMutableArray alloc] initWithCapacity:10];
        NSMutableArray *aPlot = [[NSMutableArray alloc] initWithCapacity:10];
        NSMutableArray *tPlot = [[NSMutableArray alloc] initWithCapacity:10];
        NSMutableArray *cPlot = [[NSMutableArray alloc] initWithCapacity:10];
        
        NSUInteger peakPos = [[[_abifFile valueForKeyPath:@"tags.PLOC2"] objectAtIndex:h]integerValue];
        NSUInteger previousPeakPos = [[[_abifFile valueForKeyPath:@"tags.PLOC2"] objectAtIndex:h - 1]integerValue];
        NSUInteger nextPeakPos = [[[_abifFile valueForKeyPath:@"tags.PLOC2"] objectAtIndex:h + 1]integerValue];
        NSUInteger peakStart = peakPos-(peakPos-previousPeakPos)/2;
        NSUInteger peakEnd = peakPos+(nextPeakPos-peakPos)/2;
        
        for (NSUInteger i = peakStart; i <= peakEnd; i++) {
            NSDictionary *point = [NSDictionary dictionaryWithDictionary:[_abifFile.DATA09pointsForPlot objectAtIndex:i]];
            [gPlot addObject:point];
            point = [NSDictionary dictionaryWithDictionary:[_abifFile.DATA10pointsForPlot objectAtIndex:i]];
            [aPlot addObject:point];
            point = [NSDictionary dictionaryWithDictionary:[_abifFile.DATA11pointsForPlot objectAtIndex:i]];
            [tPlot addObject:point];
            point = [NSDictionary dictionaryWithDictionary:[_abifFile.DATA12pointsForPlot objectAtIndex:i]];
            [cPlot addObject:point];
            //NSLog(@"%@",aPlot);
        }
        [dataForBase setValue:gPlot forKey:G_PLOT];
        [dataForBase setValue:aPlot forKey:A_PLOT];
        [dataForBase setValue:tPlot forKey:T_PLOT];
        [dataForBase setValue:cPlot forKey:C_PLOT];
        //NSLog(@"%@",[dataForBase valueForKey:A_PLOT]);
        GHSequenceViewController *sequenceViewController = [[GHSequenceViewController alloc] initWithNibName:@"GHSequenceViewController" bundle:nil];
        //adjust bounds to number of points
        //give all the data to graphView to be plottet
        sequenceViewController.graphView.bounds=NSMakeRect(peakStart, 0.0, peakEnd-peakStart, 3000);
        sequenceViewController.graphView.plots=dataForBase;
        //NSLog(@"%f",sequenceViewController.graphView.bounds.size.width);
        sequenceViewController.sequencePositionLabel.stringValue=[NSString stringWithFormat:@"%i",h];
        sequenceViewController.sequenceCharacterLabel.stringValue=[[_abifFile valueForKeyPath:@"tags.PBAS2"]substringWithRange:NSMakeRange(h, 1)];
        [_baseViewControllerArray addObject:sequenceViewController];
        [self drawSequence];
        baseCount++;
    }
}

- (void)drawSequence {
    NSRect newBaseRect;
    newBaseRect.origin = NSMakePoint(baseCount*20, 0);
    newBaseRect.size = firstBaseRect.size;
    NSView *view = [[_baseViewControllerArray objectAtIndex:baseCount] view];
    //NSLog(@"%@",view);
    view.frame = newBaseRect;
    NSRect oldFrame = [_sequenceScrollView frame];
    float height = oldFrame.size.height;
    float width = oldFrame.size.width;
    NSRect newFrame = NSMakeRect(oldFrame.origin.x, oldFrame.origin.y, baseCount*20, height);
    _sequenceScrollView.frame=newFrame;
    //sequenceScrollViewFrame.size = NSMakeSize(float (sequenceScrollViewFrame.size.wid+20.0), float (sequenceScrollViewFrame.height));
    
    [_sequenceScrollView addSubview: view];
    
}

@end
