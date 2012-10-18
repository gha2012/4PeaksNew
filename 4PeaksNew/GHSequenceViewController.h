//
//  GHSequenceViewController.h
//  ViewArray
//
//  Created by Gregor Hagelüken on 11.10.12.
//  Copyright (c) 2012 Gregor Hagelüken. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class GHGraphView;
@interface GHSequenceViewController : NSViewController

@property (weak) IBOutlet NSTextField *sequencePositionLabel;
@property (weak) IBOutlet GHGraphView *graphView;
@property (weak) IBOutlet NSTextField *sequenceCharacterLabel;

@end
