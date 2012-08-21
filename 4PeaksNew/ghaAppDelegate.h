//
//  ghaAppDelegate.h
//  4PeaksNew
//
//  Created by Gregor Hagelueken on 11/08/2012.
//  Copyright (c) 2012 Gregor Hagelueken. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ghaAbifFile;

@interface ghaAppDelegate : NSObject <NSApplicationDelegate>



@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTableView *watchBoxesTableView;
@property (weak) IBOutlet NSArrayController *watchBoxesArrayController;
@property (weak) IBOutlet NSArrayController *sequenceFileArrayController;
@property (weak) IBOutlet NSDictionaryController *tagsDictionaryController;
@property ghaAbifFile *selectedAbifFile;
@property IBOutlet NSTextView *sequenceView;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;
- (IBAction)addRemoveWatchBox:(id)sender;
- (IBAction)readAbi:(id)sender;

@end
