//
//  WatchBox.m
//  4PeaksNew
//
//  Created by Gregor Hagelueken on 12/08/2012.
//  Copyright (c) 2012 Gregor Hagelueken. All rights reserved.
//

#import "WatchBox.h"


@implementation WatchBox

@dynamic watchBoxDate;
@dynamic watchBoxName;
@dynamic sequenceFiles;

+ (NSSet *)keyPathsForValuesAffectingNumberOfSequencesInWatchBox {
	return [NSSet setWithObjects:@"sequenceFiles",nil];
}

+ (NSSet *)keyPathsForValuesAffectingFormattedWatchBoxDate {
	return [NSSet setWithObjects:@"watchBoxDate",nil];
}

-(NSString *)numberOfSequencesInWatchBox {
    long numberOfSequences=[[self sequenceFiles]count];
    return [NSString stringWithFormat:@"%li",numberOfSequences];
}

-(NSString *)formattedWatchBoxDate {
    NSDate *date=[[NSDate alloc]init];
    date = [self valueForKey:@"watchBoxDate"];
    NSLocale *locale = [NSLocale currentLocale];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"E MMM d yyyy" options:0 locale:locale];
    [formatter setDateFormat:dateFormat];
    [formatter setLocale:locale];
    NSLog(@"Formatted date: %@", [formatter stringFromDate:date]);
    return [formatter stringFromDate:date];
}

@end
