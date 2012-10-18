//
//  GHRawDataViewControllerWindowController.h
//  4PeaksNew
//
//  Created by Gregor Hagelüken on 25.09.12.
//  Copyright (c) 2012 Gregor Hagelueken. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>
@class GHScatterPlot;
@class GHAbifFile;

@interface GHRawDataViewControllerWindowController : NSWindowController {
    NSRect firstBaseRect;
    int baseCount;
    int rowCount;
    BOOL reverseComplement;
}
@property (weak) IBOutlet NSView *sequenceScrollView;
@property  NSMutableArray *baseViewControllerArray;
@property (strong) GHAbifFile *abifFile;
@property NSRange graphRange;

- (id)initWithAbifFile: (GHAbifFile *) anAbifFile andGraphRange: (NSRange) graphRange isReverseComplement: (BOOL) aBoolValue;
@end
