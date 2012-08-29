//
//  SequenceFile.m
//  4PeaksNew
//
//  Created by Gregor Hagelueken on 12/08/2012.
//  Copyright (c) 2012 Gregor Hagelueken. All rights reserved.
//

#import "SequenceFile.h"
#import "WatchBox.h"


@implementation SequenceFile

@dynamic sequenceFile;
@dynamic sequenceFileName;
@dynamic sequenceFilePath;
@dynamic watchBox;

+ (NSSet *)keyPathsForValuesAffectingFormattedRund1 {
	return [NSSet setWithObjects:@"rund1",nil];
}
+ (NSSet *)keyPathsForValuesAffectingPbas1Length {
	return [NSSet setWithObjects:@"pbas1",nil];
}
-(NSString *)formattedRund1 {
    NSDate *date=[[NSDate alloc]init];
    date = [self valueForKey:@"rund1"];
    NSLocale *locale = [NSLocale currentLocale];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"E MMM d yyyy" options:0 locale:locale];
    [formatter setDateFormat:dateFormat];
    [formatter setLocale:locale];
    NSLog(@"Formatted date: %@", [formatter stringFromDate:date]);
    return [formatter stringFromDate:date];
}

-(NSString *)pbas1Length{
    NSString *pbas1=[[NSString alloc]init];
    pbas1=[self valueForKey:@"pbas1"];
    long pbas1Length=[pbas1 length];
    return [NSString stringWithFormat:@"%li",pbas1Length];
}
@end
