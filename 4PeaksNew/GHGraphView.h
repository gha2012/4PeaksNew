//
//  GHGraphView.h
//  ViewArray
//
//  Created by Gregor Hagelüken on 12.10.12.
//  Copyright (c) 2012 Gregor Hagelüken. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GHGraphView : NSView {
    NSDictionary *plots;
}
@property NSDictionary *plots;

- (id)initWithFrame:(NSRect)frame;
- (NSBezierPath *)createPlotFromData: (NSArray *) dataForPlot;

@end
