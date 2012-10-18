//
//  GHSequenceViewController.m
//  ViewArray
//
//  Created by Gregor Hagelüken on 11.10.12.
//  Copyright (c) 2012 Gregor Hagelüken. All rights reserved.
//

#import "GHSequenceViewController.h"
#import "GHGraphView.h"
@interface GHSequenceViewController ()

@end

@implementation GHSequenceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //if I dont do this, the graphView is not shown.
        [[self view] displayIfNeeded];
        //NSLog(@"%@",self.view);
        //self.graphView=[[GHGraphView alloc]initWithFrame:[self.view frame] andData:data];;
        //NSLog(@"%@",self.graphView);
    }
    
    return self;
}

-(void)awakeFromNib {
}

-(void)drawGraph {
    
}

@end
