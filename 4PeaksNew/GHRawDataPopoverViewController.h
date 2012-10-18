//
//  GHRawDataPopoverViewController.h
//  4PeaksNew
//
//  Created by Gregor Hagelüken on 08.10.12.
//  Copyright (c) 2012 Gregor Hagelueken. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>

@class GHAbifFile;

@interface GHRawDataPopoverViewController : NSViewController <CPTPlotDataSource> {
    double maxY;
    BOOL reverseComplement;
}
@property (strong) IBOutlet NSPopover *rawDataPopover;
@property (strong) GHAbifFile *abifFile;
@property NSRange graphRange;
@property (weak) IBOutlet CPTGraphHostingView *hostingView;
- (IBAction)plotGraphs:(id)sender;
- (id)initWithNibName:(NSString *)nibName abifFile: (GHAbifFile *) anAbifFile andGraphRange: (NSRange) graphRange isReverseComplement: (BOOL) aBoolValue;
@end
