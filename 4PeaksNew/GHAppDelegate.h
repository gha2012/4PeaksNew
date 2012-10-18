//
//  ghaAppDelegate.h
//  4PeaksNew
//
//  Created by Gregor Hagelueken on 11/08/2012.
//  Copyright (c) 2012 Gregor Hagelueken. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class GHAbifFile;
@class BCSequenceView;
@class GHTextView;
@class GHRawDataViewWindowController;
@class GHRawDataPopoverViewController;
@class GHSplitViewDelegate;
@interface GHAppDelegate : NSObject <NSApplicationDelegate> {
    BOOL reverseCompelement;
     GHSplitViewDelegate *splitViewDelegate;
@private
    GHRawDataViewWindowController *rawDataViewWindowController;
    GHRawDataPopoverViewController *rawDataPopoverViewController;
}



@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTableView *watchBoxesTableView;
@property (weak) IBOutlet NSArrayController *watchBoxesArrayController;
@property (weak) IBOutlet NSArrayController *sequenceFileArrayController;
@property (weak) IBOutlet NSDictionaryController *tagsDictionaryController;
@property GHAbifFile *selectedAbifFile;
@property (unsafe_unretained) IBOutlet NSTextView *sequenceView;
@property (unsafe_unretained) IBOutlet NSTextView *notesView;

@property (weak) IBOutlet NSSplitView *mySplitView;
@property (weak) IBOutlet NSTableView *sequenceFilesTableView;
@property (weak) IBOutlet NSSearchField *searchField;



@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;
- (IBAction)addRemoveWatchBox:(id)sender;
- (IBAction)readAbi:(id)sender;
- (IBAction)toggleWatchBoxes:(id)sender;
- (IBAction)toggleUILayout:(id)sender;
- (IBAction)toggleReverseComplement:(id)sender;
- (IBAction)showRawDataViewer:(id)sender;
- (IBAction)updateFilter:(id)sender;
- (IBAction)showPopover:(id)sender;

-(void)collapseLeftView;
-(void)uncollapseLeftView;
- (NSArray *)watchBoxSortDescriptors;
- (NSArray *)sequenceFileSortDescriptors;
@end
