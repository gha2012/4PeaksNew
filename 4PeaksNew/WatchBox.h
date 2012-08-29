//
//  WatchBox.h
//  4PeaksNew
//
//  Created by Gregor Hagelueken on 12/08/2012.
//  Copyright (c) 2012 Gregor Hagelueken. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface WatchBox : NSManagedObject

@property (nonatomic, retain) NSDate * watchBoxDate;
@property (nonatomic, retain) NSString * watchBoxName;
@property (nonatomic, retain) NSSet *sequenceFiles;
@property (readonly) NSString *numberOfSequencesInWatchBox;
@property (readonly) NSString *formattedWatchBoxDate;
@end

@interface WatchBox (CoreDataGeneratedAccessors)

- (void)addSequenceFilesObject:(NSManagedObject *)value;
- (void)removeSequenceFilesObject:(NSManagedObject *)value;
- (void)addSequenceFiles:(NSSet *)values;
- (void)removeSequenceFiles:(NSSet *)values;

@end
