//
//  ghaAbifFile.h
//  4PeaksNew
//
//  Created by Gregor Hagelueken on 15/08/2012.
//  Copyright (c) 2012 Gregor Hagelueken. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ghaAbifDirectory;
typedef struct {
    SInt32 name;            //tag name
    SInt32 number;          //tag number
    SInt16 elementType;     //element type code
    SInt16 elementSize;     //size in bytes of one element
    SInt32 numElements;     //number of elements in item
    SInt32 dataSize;        //size in bytes of item
    SInt32 dataOffset;      //item's data, or offset in file
    SInt32 dataHandle;      //reserved
} DirEntry;

@interface ghaAbifFile : NSObject
@property NSData *abifFile;
@property NSMutableDictionary *data;
@property NSMutableDictionary *tags;
@property NSString *fileId;
@property NSString *name;
@property (retain) NSString *seq;

-(id) initWithAbifFileAtURL: (NSURL *) anAbifFileURL;
-(NSDictionary *)parseDirectoryFromAbifFile: (NSData *) anAbifFile atPosition:(int) position withLength:(int) length;
-(NSDictionary *)unpackDataFromAbifFile: (NSData *) anAbifFile fromDirectory: (NSDictionary *) aDirectory;
@end
