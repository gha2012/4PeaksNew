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
@property (nonatomic, retain) WatchBox *watchBox;
@property (readonly) NSString *formattedRund1;
@property (readonly) NSString *pbas1Length;

@end
