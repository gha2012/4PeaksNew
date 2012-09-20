//
//  SequenceFile.h
//  4PeaksNew
//
//  Created by Gregor Hagelueken on 12/08/2012.
//  Copyright (c) 2012 Gregor Hagelueken. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WatchBox;

@interface SequenceFile : NSManagedObject

@property (nonatomic, retain) NSData * sequenceFile;
@property (nonatomic, retain) NSString * sequenceFileName;
@property (nonatomic, retain) NSString * sequenceFilePath;
@property (nonatomic, retain) NSString * sequenceFileInfo;
@property (nonatomic, retain) WatchBox *watchBox;
@property (nonatomic, retain) NSString *pbas1;
@property (nonatomic, retain) NSString *pcon2;
@property (nonatomic, retain) NSString *rund1;
@property (readonly) NSString *formattedRund1;
@property (readonly) NSString *pbas1Length;
@property (readonly) NSString *reverseComplement;
@property (readonly) NSAttributedString *coloredPbas1;
@property (readonly) NSAttributedString *coloredReverseComplementPbas1;

@end
