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
@dynamic sequenceFileInfo;
@dynamic watchBox;
@dynamic pbas1;
@dynamic pcon2;
@dynamic rund1;

+ (NSSet *)keyPathsForValuesAffectingFormattedRund1 {
	return [NSSet setWithObjects:@"rund1",nil];
}
+ (NSSet *)keyPathsForValuesAffectingPbas1Length {
	return [NSSet setWithObjects:@"pbas1",nil];
}

+ (NSSet *)keyPathsForValuesAffectingReverseComplementPbas1 {
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

-(NSString *)pbas1Length {
    NSString *pbas1=[[NSString alloc]init];
    pbas1=[self valueForKey:@"pbas1"];
    long pbas1Length=[pbas1 length];
    return [NSString stringWithFormat:@"%li",pbas1Length];
}

-(NSString *)reverseComplement {
	NSString *original = [NSString stringWithString:[self valueForKey:@"pbas1"]];
    NSMutableString *reverseComplement = [[NSMutableString alloc]initWithCapacity:[original length]]; //get sequence from GUI and declare some variable
	NSLog(@"%@",original);
	int i; // i,j are counters
	NSUInteger j;
	NSUInteger lengthOfSequence = [original length];;
	NSString *base=[[NSString alloc]init];
    NSString *swappedBase=[[NSString alloc]init];
	for (i = 0; i < lengthOfSequence; i++){
		j = (lengthOfSequence - 1 ) - i;
		base = [original substringWithRange:NSMakeRange(j, 1)];
		if ([base isEqualToString:@"G"] || [base isEqualToString:@"g"] ||[base isEqualToString:@"A"] || [base isEqualToString:@"a"] || [base isEqualToString:@"T"] || [base isEqualToString:@"t"] || [base isEqualToString:@"C"] || [base isEqualToString:@"c"]) {
			
			if ([base isEqualToString:@"G"] || [base isEqualToString:@"g"]) {
				swappedBase = @"C";
			}
			if ([base isEqualToString:@"A"] || [base isEqualToString:@"a"]) {
				swappedBase = @"T";
			}
			if ([base isEqualToString:@"T"] || [base isEqualToString:@"t"]) {
				swappedBase = @"A";
			}
			if ([base isEqualToString:@"C"] || [base isEqualToString:@"c"]) {
				swappedBase = @"G";
			}
			
		}//end if
		else {
			swappedBase=base;
		}// end else
		[reverseComplement insertString:swappedBase atIndex:i];
	}//end for
    NSLog(@"%@",reverseComplement);
    return reverseComplement;
}

-(NSMutableAttributedString *)coloredReverseComplementPbas1 {
    //NSLog(@"%@",[self valueForKey:@"pcon2"]);
    //NSLog(@"%@",[self valueForKey:@"pbas1"]);
    NSString *original = [[NSString alloc]init];
    NSString *colorValues = [[NSString alloc]init];
    original = [self reverseComplement];
    colorValues = [NSString stringWithString:[self valueForKey:@"pcon2"]];
    NSMutableAttributedString *coloredReverseComplementPbas1 = [[NSMutableAttributedString alloc] initWithString:original];
    //NSLog(@"%@",coloredReverseComplementPbas1);
    int qualVal = 0 ;
    for (int i = 0; i < [original length]; i++ ) {
        qualVal = [colorValues characterAtIndex:([original length]-1)-i];
        if (qualVal <= 10) {
            [coloredReverseComplementPbas1 addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(i,1)];
        }
        if (qualVal > 10 && qualVal <=20) {
            [coloredReverseComplementPbas1 addAttribute:NSForegroundColorAttributeName value:[NSColor magentaColor] range:NSMakeRange(i,1)];
        }
        //if (qualVal > 30 && qualVal <=60) {
        //    [coloredString addAttribute:NSForegroundColorAttributeName value:[NSColor greenColor] range:NSMakeRange(i,1)];
        //}
    }
    return coloredReverseComplementPbas1;
}

-(NSMutableAttributedString *)coloredPbas1 {
    //NSLog(@"%@",[self valueForKey:@"pcon2"]);
    //NSLog(@"%@",[self valueForKey:@"pbas1"]);
    NSString *original = [[NSString alloc]init];
    NSString *colorValues = [[NSString alloc]init];
    original = [NSString stringWithString:[self valueForKey:@"pbas1"]];
    colorValues = [NSString stringWithString:[self valueForKey:@"pcon2"]];
    NSMutableAttributedString *coloredPbas1 = [[NSMutableAttributedString alloc] initWithString:original];
    //NSLog(@"%@",coloredPbas1);
    int qualVal = 0 ;
    for (int i = 0; i < [original length]; i++ ) {
        qualVal = [colorValues characterAtIndex:i];
        if (qualVal <= 10) {
            [coloredPbas1 addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(i,1)];
        }
        if (qualVal > 10 && qualVal <=20) {
            [coloredPbas1 addAttribute:NSForegroundColorAttributeName value:[NSColor magentaColor] range:NSMakeRange(i,1)];
        }
        //if (qualVal > 30 && qualVal <=60) {
        //    [coloredString addAttribute:NSForegroundColorAttributeName value:[NSColor greenColor] range:NSMakeRange(i,1)];
        //}
    }
    return coloredPbas1;
}
@end
