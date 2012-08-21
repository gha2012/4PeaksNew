//
//  ghaAbifFile.m
//  4PeaksNew
//
//  Created by Gregor Hagelueken on 15/08/2012.
//  Copyright (c) 2012 Gregor Hagelueken. All rights reserved.
//

#import "ghaAbifFile.h"

@implementation ghaAbifFile
@synthesize seq = _seq;
-(id) initWithAbifFileAtURL: (NSURL *)anAbifFileURL {
    if ((self=[super init])) {
        _data=[[NSMutableDictionary alloc]init];
        _tags=[[NSMutableDictionary alloc]init];
        self.abifFile = [NSData dataWithContentsOfURL: anAbifFileURL];
        //test if abif format - first 4 bytes should be ABIF
        unsigned char charStr[4];
        short shortNumber;
        //get first 4 bytes
        [_abifFile getBytes:charStr range: NSMakeRange(0, 4)];
        //convert them to NSString
        NSString *fileType =[[NSString alloc]initWithBytes:charStr length:4 encoding:NSASCIIStringEncoding];
        NSLog(@"%@",fileType);
        if ([fileType isNotEqualTo:@"ABIF"]) {
            NSLog(@"Not a valid .ab1 file");
            return nil;
        }//end if
        
        //get version
        shortNumber=0;
        [_abifFile getBytes:&shortNumber range:NSMakeRange(4, 2)];
        //endianness: swap to big
        short swapped=CFSwapInt16(shortNumber);
        NSNumber *fileVersion=[NSNumber numberWithShort:swapped];
        NSLog(@"File version: %li",[fileVersion integerValue]);
        NSDictionary *header=[[NSDictionary alloc]init];
        int positionPointer=6;
        header = [self parseDirectoryFromAbifFile:_abifFile atPosition:positionPointer withLength:28];
        NSLog(@"%@",header);
        int headerOffset=[[header objectForKey:@"dataOffset"]intValue];
        int headerElementSize=[[header objectForKey:@"elementSize"]intValue];
        NSLog(@"%i",[[header objectForKey:@"numElements"]intValue]);
        for (int i=0; i<[[header objectForKey:@"numElements"]intValue]-1; i++) {
            positionPointer=headerOffset+i*headerElementSize;
            NSDictionary *newDirectory=[[NSDictionary alloc] init];
            newDirectory = [self parseDirectoryFromAbifFile:_abifFile atPosition:positionPointer withLength:28];
            NSString *tagName=[newDirectory objectForKey:@"tagName"];
            NSString *tagNumber=[newDirectory objectForKey:@"tagNumber"];
            NSString *nameAndNumber=[NSString stringWithFormat:@"%@%@",tagName,tagNumber];
            [_data setObject:newDirectory forKey:nameAndNumber];
            NSDictionary *tag=[[NSDictionary alloc]init];
            tag = [NSDictionary dictionaryWithDictionary:[self unpackDataFromAbifFile:_abifFile fromDirectory:newDirectory]];
            //NSLog(@"%@",tag);
            if ([tag count]>0) {
                [_tags setObject:[tag objectForKey:nameAndNumber] forKey:nameAndNumber];
            }
            
            //NSLog(@"%@",_data);
        }//end for
        _seq=[_tags objectForKey:@"PBAS1"];
    }//end if
    return self;
}//end initWithAbifFileAtURL:

-(NSDictionary *)parseDirectoryFromAbifFile: (NSData *) anAbifFile
                                     atPosition:(int) position
                                     withLength:(int) length {
    DirEntry dirEntry;
    [anAbifFile getBytes:&dirEntry range:NSMakeRange(position, length)];
    NSString *tagName=[[NSString alloc] initWithBytes:&dirEntry length:4 encoding:NSASCIIStringEncoding];
    NSNumber *tagNumber=[[NSNumber alloc] initWithInt:CFSwapInt32(dirEntry.number)];
    NSNumber *elementTypeCode=[[NSNumber alloc] initWithInt:CFSwapInt16(dirEntry.elementType)];
    NSNumber *elementSize=[[NSNumber alloc] initWithInt:CFSwapInt16(dirEntry.elementSize)];
    NSNumber *numElements=[[NSNumber alloc] initWithInt:CFSwapInt32(dirEntry.numElements)];
    NSNumber *dataSize=[[NSNumber alloc] initWithInt:CFSwapInt32(dirEntry.dataSize)];
    NSNumber *dataOffset=[NSNumber alloc];
    if ([dataSize intValue]>4) {
        dataOffset=[dataOffset initWithInt:CFSwapInt32(dirEntry.dataOffset)];
    }//end if
    else if ([dataSize intValue]<=4) {
        //this is because data <=4 byte is stored in the directory
        dataOffset=[dataOffset initWithInt:position+20];
    }//end else if
    NSDictionary *directory=[NSDictionary dictionaryWithObjectsAndKeys:
                             tagName, @"tagName",
                             tagNumber, @"tagNumber",
                             elementTypeCode, @"elementTypeCode",
                             elementSize, @"elementSize",
                             numElements, @"numElements",
                             dataSize, @"dataSize",
                             dataOffset, @"dataOffset",
                             nil];
    return directory;
}//end parseDirectoryFromAbifFile:atPosition:withLength:

-(NSDictionary *)unpackDataFromAbifFile: (NSData *) anAbifFile fromDirectory: (NSDictionary *) aDirectory {
    int elementTypeCode=[[aDirectory valueForKey:@"elementTypeCode"] intValue];
    int elementSize = [[aDirectory valueForKey:@"elementSize"] intValue];
    int dataSize = [[aDirectory valueForKey:@"dataSize"] intValue];
    int numElements = [[aDirectory objectForKey:@"numElements"]intValue];
    int offset = [[aDirectory valueForKey:@"dataOffset"]intValue];
    NSString *tagName=[aDirectory valueForKey:@"tagName"];
    NSNumber *tagNumber=[aDirectory valueForKey:@"tagNumber"];
    NSString *nameAndNumber=[NSString stringWithFormat:@"%@%@",tagName,tagNumber];
    NSDictionary *dictionary=[[NSDictionary alloc]init];
    switch (elementTypeCode) {
        case 1: //byte unsigned 8-bit integer
            {
                if (dataSize > 0) {
                    UInt8 buffer[numElements];
                    NSMutableArray *array=[NSMutableArray arrayWithCapacity:numElements];
                    [anAbifFile getBytes:&buffer range:NSMakeRange(offset, numElements)];
                    int i=0;
                    while (i <= numElements-1) {
                        [array addObject:[NSNumber numberWithInt:buffer[i]]];
                        i++;
                    }
                    //NSLog(@"%@",array);
                }//end if
            }
            break; //end case 1
        case 2: //char
        {
            if (dataSize > 0) {
                char buffer[numElements];
                [anAbifFile getBytes:&buffer range:NSMakeRange(offset, numElements)];
                NSString *bufferString=[[NSString alloc]initWithBytes:&buffer length:numElements encoding:NSASCIIStringEncoding];
                dictionary=[NSDictionary dictionaryWithObjectsAndKeys:bufferString, nameAndNumber,nil];
                //NSLog(@"%@",test);
            }// end if
        }
            break; //end case 2
        case 3: //word
        {
            if (dataSize > 0) {
                UInt16 buffer[numElements];
                NSMutableArray *array=[NSMutableArray arrayWithCapacity:numElements];
                [anAbifFile getBytes:&buffer range:NSMakeRange(offset, numElements*elementSize)];
                int i=0;
                while (i <= numElements-1) {
                    [array addObject:[NSNumber numberWithInt:CFSwapInt16(buffer[i])]];
                    i++;
                }
                dictionary=[NSDictionary dictionaryWithObjectsAndKeys:array, nameAndNumber,nil];
                //NSLog(@"%@",array);
            }// end if
        }
            break; //end case 3
        case 4: //short
        {
            if (dataSize > 0) {
                short buffer[numElements];
                NSMutableArray *array=[NSMutableArray arrayWithCapacity:numElements];
                [anAbifFile getBytes:&buffer range:NSMakeRange(offset, numElements*elementSize)];
                int i=0;
                while (i <= numElements-1) {
                    [array addObject:[NSNumber numberWithInt:CFSwapInt16(buffer[i])]];
                    i++;
                }
                dictionary=[NSDictionary dictionaryWithObjectsAndKeys:array, nameAndNumber,nil];
                //NSLog(@"%@",array);
            }// end if
        }
            break; //end case 4
        case 5: //long
        {
            if (dataSize > 0) {
                long buffer[numElements];
                NSMutableArray *array=[NSMutableArray arrayWithCapacity:numElements];
                [anAbifFile getBytes:&buffer range:NSMakeRange(offset, numElements*elementSize)];
                int i=0;
                while (i <= numElements-1) {
                    [array addObject:[NSNumber numberWithLong:CFSwapInt32(buffer[i])]];
                    i++;
                }
                dictionary=[NSDictionary dictionaryWithObjectsAndKeys:array, nameAndNumber,nil];
                //NSLog(@"%@",array);
            }// end if
        }
            break; //end case 5
        case 7: //float
        {
            if (dataSize > 0) {
                CFSwappedFloat32 buffer[numElements];
                NSMutableArray *array=[NSMutableArray arrayWithCapacity:numElements];
                [anAbifFile getBytes:&buffer range:NSMakeRange(offset, numElements*elementSize)];
                int i=0;
                while (i <= numElements-1) {
                    [array addObject:[NSNumber numberWithFloat: CFConvertFloat32SwappedToHost(buffer[i])]];
                    i++;
                }
                dictionary=[NSDictionary dictionaryWithObjectsAndKeys:array, nameAndNumber,nil];
                //NSLog(@"%@",array);
            }// end if
        }
            break; //end case 7
        case 8: //double
        {
            if (dataSize > 0) {
                CFSwappedFloat64 buffer[numElements];
                NSMutableArray *array=[NSMutableArray arrayWithCapacity:numElements];
                [anAbifFile getBytes:&buffer range:NSMakeRange(offset, numElements*elementSize)];
                int i=0;
                while (i <= numElements-1) {
                    [array addObject:[NSNumber numberWithFloat: CFConvertFloat64SwappedToHost(buffer[i])]];
                    i++;
                }
                dictionary=[NSDictionary dictionaryWithObjectsAndKeys:array, nameAndNumber,nil];
                //NSLog(@"%@",array);
            }// end if
        }
            break; //end case 8
        case 10: //date
        {
            if (dataSize > 0) {
                struct {
                    SInt16 year; // 4-digit year
                    UInt8 month; // month 1-12
                    UInt8 day; // day 1-31
                } date;
                [anAbifFile getBytes:&date range:NSMakeRange(offset, numElements*elementSize)];
                int year=CFSwapInt16(date.year);
                int month=date.month;
                int day=date.day;
                NSDateFormatter *mmddccyy = [[NSDateFormatter alloc] init];
                mmddccyy.timeStyle = NSDateFormatterNoStyle;
                mmddccyy.dateFormat = @"MM/dd/yyyy";
                NSDate *d = [mmddccyy dateFromString:[NSString stringWithFormat:@"%i/%i/%i",month,day,year]];
                dictionary=[NSDictionary dictionaryWithObjectsAndKeys:d, nameAndNumber,nil];
                //NSLog(@"%@", d);
            }// end if
        }
            break; //end case 10
        case 11: //time
        {
            if (dataSize > 0) {
                struct {
                        UInt8 hour; // hour 0-23
                        UInt8 minute; // minute 0-59
                        UInt8 second; // second 0-59
                        UInt8 hsecond; // 0.01 second 0-99
                } time;
                [anAbifFile getBytes:&time range:NSMakeRange(offset, numElements*elementSize)];
                int hour=time.hour;
                int minute=time.minute;
                int second=time.second;
                int hsecond=time.hsecond;
                NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
                [timeFormat setDateFormat:@"HH:mm:ss"];
                NSDate *d = [timeFormat dateFromString:[NSString stringWithFormat:@"%i:%i:%i",hour,minute,second]];
                dictionary=[NSDictionary dictionaryWithObjectsAndKeys:d, nameAndNumber,nil];
                //NSLog(@"%@", d);
            }// end if
        }
            break; //end case 11
        case 18: //pString
        {
            if (dataSize > 0) {
                char buffer[255];
                [anAbifFile getBytes:&buffer range:NSMakeRange(offset+1, numElements)]; //ignore first byte
                NSString *bufferString=[[NSString alloc]initWithBytes:&buffer length:numElements encoding:NSASCIIStringEncoding];
                dictionary=[NSDictionary dictionaryWithObjectsAndKeys:bufferString, nameAndNumber,nil];
                //NSLog(@"%@",test);
            }// end if
        }
            break; //end case 18
        case 19: //cString
        {
            if (dataSize > 0) {
                char buffer[255];
                [anAbifFile getBytes:&buffer range:NSMakeRange(offset, numElements-1)]; //ignore last byte
                NSString *bufferString=[[NSString alloc]initWithBytes:&buffer length:numElements encoding:NSASCIIStringEncoding];
                dictionary=[NSDictionary dictionaryWithObjectsAndKeys:bufferString, nameAndNumber,nil];//NSLog(@"%@",test);
            }// end if
        }
            break; //end case 19
        default:
            break;
    }// end switch
    return dictionary;
}

@end
