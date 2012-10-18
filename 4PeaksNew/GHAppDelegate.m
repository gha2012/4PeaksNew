//
//  ghaAppDelegate.m
//  4PeaksNew
//
//  Created by Gregor Hagelueken on 11/08/2012.
//  Copyright (c) 2012 Gregor Hagelueken. All rights reserved.
//

#import "GHAppDelegate.h"
#import "WatchBox.h"
#import "SequenceFile.h"
#import "GHAbifFile.h"
#import "BCSequenceView.h"
#import "GHRawDataViewControllerWindowController.h"
#import "GHRawDataPopoverViewController.h"

#define LEFT_VIEW_INDEX 0
#define LEFT_VIEW_PRIORITY 2
#define LEFT_VIEW_MINIMUM_WIDTH 100.0
#define MAIN_VIEW_INDEX 1
#define MAIN_VIEW_PRIORITY 0
#define MAIN_VIEW_MINIMUM_WIDTH 200.0
#define RIGHT_VIEW_INDEX 2
#define RIGHT_VIEW_PRIORITY 1
#define RIGHT_VIEW_MINIMUM_WIDTH 50.0


@implementation GHAppDelegate

@synthesize watchBoxesTableView = _watchBoxesTableView;
@synthesize watchBoxesArrayController = _watchBoxesArrayController;
@synthesize sequenceFileArrayController = _sequenceFileArrayController;
@synthesize tagsDictionaryController = _tagsDictionaryController;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize selectedAbifFile = _selectedAbifFile;
@synthesize sequenceView = _sequenceView;
@synthesize notesView = _notesView;
@synthesize mySplitView = _mySplitView;
@synthesize sequenceFilesTableView = _sequenceFilesTableView;
@synthesize searchField = _searchField;



- (NSArray *)watchBoxSortDescriptors {
    return [NSArray arrayWithObject:
            [NSSortDescriptor sortDescriptorWithKey:@"watchBoxName"
                                          ascending:YES]];
}

- (NSArray *)sequenceFileSortDescriptors {
    return [NSArray arrayWithObject:
            [NSSortDescriptor sortDescriptorWithKey:@"sequenceFileName"
                                          ascending:YES]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
	
	[_mySplitView setDelegate:self];
	[[[_mySplitView subviews] objectAtIndex:LEFT_VIEW_INDEX]
     setBackgroundColor:[NSColor redColor]];
	[[[_mySplitView subviews] objectAtIndex:MAIN_VIEW_INDEX]
     setBackgroundColor:[NSColor darkGrayColor]];
	[[[_mySplitView subviews] objectAtIndex:RIGHT_VIEW_INDEX]
     setBackgroundColor:[NSColor blueColor]];
}

- (void)awakeFromNib {
    reverseCompelement=FALSE;
    //register for dropable files
    [_watchBoxesTableView registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    [_sequenceFilesTableView registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    // tell NSTableView we want to drag and drop accross applications
	// the default has forLocal:YES
	[_watchBoxesTableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
    [_sequenceFilesTableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
    //[_sequenceView setUnit: @"bp"];
	//[_sequenceView setFilter: YES];
    //NSLog(@"%@",[_sequenceFileArrayController exposedBindings]);
    
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "gregorhagelueken._PeaksNew" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"gregorhagelueken._PeaksNew"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"_PeaksNew" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"_PeaksNew.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (IBAction)addRemoveWatchBox:(id)sender {
    NSSegmentedControl *segmentedControl = (NSSegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegment;
    
    if (selectedSegment == 0) {
        //add an empty watchbox
        NSUInteger counter = [[_watchBoxesArrayController content] count];
        WatchBox *newWatchBox = [NSEntityDescription insertNewObjectForEntityForName:@"WatchBox" inManagedObjectContext:[self managedObjectContext]];
        [newWatchBox setValue: [NSString stringWithFormat:@"New WatchBox %li", counter] forKey:@"watchBoxName"];
        NSDate *date=[NSDate date];
        [newWatchBox setValue: date forKey:@"watchBoxDate"];
        [_watchBoxesArrayController addObject:newWatchBox];
    }
    else {
        //remove the selected watchbox
        NSAlert *alert = [NSAlert alertWithMessageText:@"Delete the watchbox?"
                                         defaultButton:@"OK" alternateButton:@"Cancel" otherButton:nil
                             informativeTextWithFormat:@""];
        
        NSInteger answer = [alert runModal];
        NSLog(@"%ld",answer);
        if (answer == NSAlertDefaultReturn) {
            NSLog(@"delete");
            NSIndexSet *selectedWatchBox=[_watchBoxesArrayController selectionIndexes];
            [_watchBoxesArrayController removeObjectsAtArrangedObjectIndexes: selectedWatchBox];
        }
    }
}

- (IBAction)readAbi:(id)sender {
    NSURL *sequenceFileURL=[NSURL fileURLWithPath:[[_sequenceFileArrayController selection] valueForKey:@"sequenceFilePath"]];
    if ([[sequenceFileURL path]length]>0) {
        GHAbifFile *abifFile=[[GHAbifFile alloc ] initWithAbifFileAtURL:sequenceFileURL];
        _selectedAbifFile=abifFile;
        NSLog(@"%@",[_selectedAbifFile valueForKeyPath:@"seq"]);
        NSLog(@"%@",[_selectedAbifFile valueForKeyPath:@"tags.PCON2"]);
        //[_sequenceView setString:[_selectedAbifFile valueForKeyPath:@"seq"]];
        NSLog(@"read file");
    }
    else
        NSLog(@"no file to read");
    
}

- (IBAction)toggleReverseComplement:(id)sender {
    NSSegmentedControl *segmentedControl = (NSSegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegment;
    //NSLog(@"%@",[_sequenceView exposedBindings]);
    NSLog(@"%@", _sequenceView);
    NSLog(@"%@", _notesView);
    if (selectedSegment == 0) {
        //[_sequenceView unbind:@"Value"];
        [_sequenceView bind:@"attributedString" toObject: _sequenceFileArrayController withKeyPath:@"selection.coloredPbas1" options:nil];
        reverseCompelement=FALSE;
    }
    if (selectedSegment == 1) {
        [_sequenceView bind:@"attributedString" toObject: _sequenceFileArrayController withKeyPath:@"selection.coloredReverseComplementPbas1" options:nil];
        reverseCompelement=TRUE;
    }
}

- (IBAction)showRawDataViewer:(id)sender {
    NSRect rect=[_sequenceView firstRectForCharacterRange:[_sequenceView selectedRange]];
    NSRect textViewBounds = [_sequenceView convertRectToBase:[_sequenceView bounds]];
    textViewBounds.origin = [[_sequenceView window] convertBaseToScreen:textViewBounds.origin];
    
    rect.origin.x -= textViewBounds.origin.x;
    rect.origin.y -= textViewBounds.origin.y;
    rect.origin.y = textViewBounds.size.height - rect.origin.y - 10;
    NSLog(@"rect %@",NSStringFromRect(rect));
    NSLog(@"bounds %@",NSStringFromRect([_sequenceView bounds]));
    //rawDataPopover = [[NSPopover alloc] init];
    //rawDataPopover.contentViewController = _rawDataPopoverViewController;
    //[rawDataPopover showRelativeToRect:rect ofView:_sequenceView preferredEdge:NSMaxYEdge];
    
    NSURL *sequenceFileURL=[NSURL fileURLWithPath:[[_sequenceFileArrayController selection] valueForKey:@"sequenceFilePath"]];
    if ([[sequenceFileURL path]length]>0) {
        NSLog(@"%@",sequenceFileURL);
        GHAbifFile *abifFile=[[GHAbifFile alloc ] initWithAbifFileAtURL:sequenceFileURL];
        NSRange selected=[_sequenceView selectedRange];
        if (reverseCompelement==FALSE) {
            NSUInteger graphBegin = [[[abifFile valueForKeyPath:@"tags.PLOC2"] objectAtIndex:selected.location]integerValue];
            NSUInteger graphEnd = [[[abifFile valueForKeyPath:@"tags.PLOC2"] objectAtIndex:selected.location + selected.length]integerValue];
            NSRange graphRange=NSMakeRange(graphBegin, graphEnd-graphBegin);
            rawDataViewWindowController=[[GHRawDataViewControllerWindowController alloc] initWithAbifFile:abifFile andGraphRange:graphRange isReverseComplement: reverseCompelement];
            [rawDataViewWindowController showWindow:nil];
            rawDataPopoverViewController=[[GHRawDataPopoverViewController alloc]initWithNibName:@"GHRawDataPopoverViewController" abifFile:abifFile andGraphRange:graphRange isReverseComplement:reverseCompelement];
            [rawDataPopoverViewController.rawDataPopover showRelativeToRect:rect ofView:_sequenceView preferredEdge:NSMaxYEdge];
        } //endif
        
        
        else if (reverseCompelement==TRUE) {
            NSUInteger lengthOfSequence = [[_sequenceView string]length];
            NSUInteger graphBegin = [[[abifFile valueForKeyPath:@"tags.PLOC2"] objectAtIndex:lengthOfSequence-selected.location-selected.length]integerValue];
            NSUInteger graphEnd = [[[abifFile valueForKeyPath:@"tags.PLOC2"] objectAtIndex:lengthOfSequence-selected.location]integerValue];
            NSRange graphRange=NSMakeRange(graphBegin, graphEnd-graphBegin);
            //rawDataViewWindowController=[[GHRawDataViewControllerWindowController alloc] initWithAbifFile:abifFile andGraphRange:graphRange isReverseComplement: reverseCompelement];
            //[rawDataViewWindowController showWindow:nil];
            rawDataPopoverViewController=[[GHRawDataPopoverViewController alloc]initWithNibName:@"GHRawDataPopoverViewController" abifFile:abifFile andGraphRange:graphRange isReverseComplement:reverseCompelement];
            [rawDataPopoverViewController.rawDataPopover showRelativeToRect:rect ofView:_sequenceView preferredEdge:NSMaxYEdge];
        }// endif
    }// end if
    
}

- (IBAction)updateFilter:(id)sender {
    NSString *searchString = [[_searchField stringValue] uppercaseString];
    NSString *displayedSequence = [_sequenceView string];
    NSRange range = [displayedSequence rangeOfString:searchString];
    [_sequenceView showFindIndicatorForRange:range];
    [_sequenceView setSelectedRange:range];
}

- (IBAction)showPopover:(id)sender {
    rawDataPopoverViewController=[[GHRawDataPopoverViewController alloc]initWithNibName:@"GHRawDataPopoverViewController" bundle:nil];
    [rawDataPopoverViewController.rawDataPopover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxYEdge];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

#pragma mark - tableView delegate

- (BOOL)    tableView:(NSTableView *)aTableView
 writeRowsWithIndexes:(NSIndexSet *)rowIndexes
         toPasteboard:(NSPasteboard *)pboard {
    [pboard declareTypes:[NSArray arrayWithObjects:NSFilesPromisePboardType, nil] owner:nil];
    NSMutableArray *filenameExtensions = [NSArray arrayWithObjects:@".ab1", @".seq", @".fas",nil];
    [pboard setPropertyList:filenameExtensions
                    forType:NSFilesPromisePboardType];
    return YES;
}//end tableView:writeRowsWithIndexes:toPasteboard

- (NSArray *)tableView:(NSTableView *)aTableView
namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination
forDraggedRowsWithIndexes:(NSIndexSet *)indexSet {
    NSMutableArray *filesToBeDragged =[NSMutableArray array];
    if ([aTableView isEqualTo:_watchBoxesTableView]) {
        //Find out which sequenceFiles are in the selected watchbox and write the paths to an array
        NSArray *sequenceFilesInWatchBox = [NSArray arrayWithArray:[_sequenceFileArrayController arrangedObjects]];
        for (SequenceFile *sequencefile in sequenceFilesInWatchBox) {
            [filesToBeDragged addObject:[sequencefile valueForKey:@"sequenceFilePath"]];
        }//end for
        NSLog(@"%@", filesToBeDragged);
        NSLog(@"%@", [dropDestination path]);
        
        //create folder at drop destination and copy the files to this folder
        NSFileManager *fileManager= [NSFileManager defaultManager];
        NSString *watchBoxName=[NSString stringWithString:[[_watchBoxesArrayController selection] valueForKey:@"watchBoxName"]];
        NSString *destinationFolderPath=[[dropDestination path] stringByAppendingPathComponent:watchBoxName];
        BOOL isDir;
        if(![fileManager fileExistsAtPath:destinationFolderPath isDirectory:&isDir]);
            if(![fileManager createDirectoryAtPath:destinationFolderPath withIntermediateDirectories:YES attributes:nil error:NULL]){
                NSLog(@"Error: Create folder failed %@", destinationFolderPath);
                return FALSE;
            }//end if
        
        
        for (NSString *sourceFilePath in filesToBeDragged) {
            NSURL *sourceURL = [NSURL fileURLWithPath:sourceFilePath];
            NSURL *destinationURL = [[NSURL fileURLWithPath: destinationFolderPath] URLByAppendingPathComponent:[sourceFilePath lastPathComponent]];
            [[NSFileManager defaultManager] copyItemAtURL:sourceURL toURL:destinationURL error:nil];
        }//end for
        NSLog(@"drop");
    }//end if
    if ([aTableView isEqualTo:_sequenceFilesTableView]) {
        //get selected sequence files
        NSArray *selectedFiles=[[NSArray alloc]initWithArray:[[_sequenceFileArrayController arrangedObjects] objectsAtIndexes:indexSet]];
        for (SequenceFile *sequencefile in selectedFiles) {
            [filesToBeDragged addObject:[sequencefile valueForKey:@"sequenceFilePath"]];
        }//end for
        NSLog(@"%@", filesToBeDragged);
        NSLog(@"%@", [dropDestination path]);
        NSFileManager *fileManager= [NSFileManager defaultManager];
        for (NSString *sourceFilePath in filesToBeDragged) {
            NSURL *sourceURL = [NSURL fileURLWithPath:sourceFilePath];
            NSURL *destinationURL = [[NSURL fileURLWithPath: [dropDestination path]] URLByAppendingPathComponent:[sourceFilePath lastPathComponent]];
            if(![fileManager fileExistsAtPath:[destinationURL path]])
                [[NSFileManager defaultManager] copyItemAtURL:sourceURL toURL:destinationURL error:nil];
        
        }//end for
    }//end if
    return filesToBeDragged;
}//end tableView:namesOfPromisedFilesDroppedAtDestination:forDraggedRowsWithIndexes

- (NSDragOperation)tableView:(NSTableView *)aTableView
                validateDrop:(id < NSDraggingInfo >)info
                 proposedRow:(NSInteger)row
       proposedDropOperation:(NSTableViewDropOperation)operation {
    // Add code here to validate the drop
    NSLog(@"validate Drop");
    return NSDragOperationCopy;
}


- (BOOL)tableView:(NSTableView *)aTableView
       acceptDrop:(id <NSDraggingInfo>)info
              row:(NSInteger)row
    dropOperation:(NSTableViewDropOperation)operation {
    
    NSPasteboard* zPBoard = [info draggingPasteboard];
	
	NSArray *supportedTypes = [NSArray arrayWithObjects:
                               NSFilenamesPboardType,
                               nil];
    NSString * zStrAvailableType = [zPBoard availableTypeFromArray:supportedTypes];
	NSLog(@"zStrAvailableType=%@",zStrAvailableType);
    NSLog(@"accept Drop");
    if ([zStrAvailableType compare:NSFilenamesPboardType] == NSOrderedSame ) {
		NSLog(@"NSFilenamesPboardType");
        NSArray* pListFilesArray = [zPBoard propertyListForType:NSFilenamesPboardType];
		NSInteger i;
		if ([aTableView isEqualTo:_watchBoxesTableView]) {
            //create new Watchbox for all dropped files
            NSDate *date=[NSDate date];
            WatchBox *newWatchBox = [NSEntityDescription insertNewObjectForEntityForName:@"WatchBox" inManagedObjectContext:[self managedObjectContext]];
            NSUInteger counter = [[_watchBoxesArrayController content] count];
            [newWatchBox setValue: [NSString stringWithFormat:@"New WatchBox %li", counter] forKey:@"watchBoxName"];
            [newWatchBox setValue: date forKey:@"watchBoxDate"];
            
            //create a folder for the watchbox
            NSString *uniqueID = [[NSProcessInfo processInfo] globallyUniqueString];
            NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
            NSURL *uniqueWatchBoxDirectory = [applicationFilesDirectory URLByAppendingPathComponent:uniqueID isDirectory:YES];
            [newWatchBox setValue:[uniqueWatchBoxDirectory path] forKey:@"watchBoxPath"];
            NSLog(@"%@", uniqueWatchBoxDirectory);
            [[ NSFileManager defaultManager] createDirectoryAtURL:uniqueWatchBoxDirectory withIntermediateDirectories:YES attributes:nil error:nil];
            //create new SequenceFile for each dropped file and set relationship
            for (i = 0; i < [pListFilesArray count]; i++) {
                //get the filepath of each file that is to be dropped
                NSString * originalFilePath	= [pListFilesArray objectAtIndex:i];
                NSURL *originalFileURL = [NSURL fileURLWithPath:originalFilePath];
                NSString* originalFileName = [originalFilePath lastPathComponent];
                NSURL *targetFileURL = [uniqueWatchBoxDirectory URLByAppendingPathComponent:originalFileName];
                SequenceFile *newSequenceFile = [NSEntityDescription insertNewObjectForEntityForName:@"SequenceFile" inManagedObjectContext:[self managedObjectContext]];
                [newSequenceFile setValue: originalFileName forKey:@"sequenceFileName"];
                [newSequenceFile setValue:[targetFileURL path] forKey:@"sequenceFilePath"];
                [newSequenceFile setWatchBox:newWatchBox];
                //parse some metadata
                NSLog(@"%@",[[originalFilePath lastPathComponent] pathExtension]);
                if ([[[originalFilePath lastPathComponent] pathExtension] isEqualTo:@"ab1"]) {
                    GHAbifFile *abifFile=[[GHAbifFile alloc ] initWithAbifFileAtURL:originalFileURL];
                    [newSequenceFile setValue: [abifFile valueForKeyPath:@"tags.PBAS1"] forKey:@"pbas1"]; //sequence
                    [newSequenceFile setValue: [abifFile valueForKeyPath:@"tags.SMPL1"] forKey:@"smpl1"]; //sample name in abi file
                    [newSequenceFile setValue: [abifFile valueForKeyPath:@"tags.RUND1"] forKey:@"rund1"]; //sample name in abi file
                    [newSequenceFile setValue: [abifFile valueForKeyPath:@"tags.PCON2"] forKey:@"pcon2"]; //sample name in abi file
                    //NSLog(@"%@",[abifFile valueForKeyPath:@"tags.PCON2"]);
                }//end if
                //copy the file to the new directory
                [[NSFileManager defaultManager] copyItemAtURL:originalFileURL toURL:targetFileURL error:nil];
            } // end for
            return YES;
        }//end if isEqualToWatchBoxTableView
        if ([aTableView isEqualTo:_sequenceFilesTableView]) {
            NSLog(@"sequenceFileTableView");
            //get parent watchbox
            NSLog(@"%@",[[_watchBoxesArrayController arrangedObjects]objectAtIndex:[_watchBoxesArrayController selectionIndex]]);
            WatchBox *parentWatchbox=[[_watchBoxesArrayController arrangedObjects]objectAtIndex:[_watchBoxesArrayController selectionIndex]];
            NSLog(@"%@",parentWatchbox);
            NSURL *watchboxFileURL = [NSURL fileURLWithPath:[parentWatchbox valueForKey:@"watchBoxPath"]];
            //create new SequenceFile for each dropped file and set relationship
            for (i = 0; i < [pListFilesArray count]; i++) {
                //get the filepath of each file that is to be dropped
                NSString * originalFilePath	= [pListFilesArray objectAtIndex:i];
                NSURL *originalFileURL = [NSURL fileURLWithPath:originalFilePath];
                NSString* originalFileName = [originalFilePath lastPathComponent];
                NSURL *targetFileURL = [watchboxFileURL URLByAppendingPathComponent:originalFileName];
                SequenceFile *newSequenceFile = [NSEntityDescription insertNewObjectForEntityForName:@"SequenceFile" inManagedObjectContext:[self managedObjectContext]];
                [newSequenceFile setValue: originalFileName forKey:@"sequenceFileName"];
                [newSequenceFile setValue:[targetFileURL path] forKey:@"sequenceFilePath"];
                NSLog(@"%@",newSequenceFile);
                
                [newSequenceFile setWatchBox:parentWatchbox];
                //parse some metadata
                NSLog(@"%@",[[originalFilePath lastPathComponent] pathExtension]);
                if ([[[originalFilePath lastPathComponent] pathExtension] isEqualTo:@"ab1"]) {
                    GHAbifFile *abifFile=[[GHAbifFile alloc ] initWithAbifFileAtURL:originalFileURL];
                    [newSequenceFile setValue: [abifFile valueForKeyPath:@"tags.PBAS1"] forKey:@"pbas1"]; //sequence
                    [newSequenceFile setValue: [abifFile valueForKeyPath:@"tags.SMPL1"] forKey:@"smpl1"]; //sample name in abi file
                    [newSequenceFile setValue: [abifFile valueForKeyPath:@"tags.RUND1"] forKey:@"rund1"]; //sample name in abi file
                    [newSequenceFile setValue: [abifFile valueForKeyPath:@"tags.PCON2"] forKey:@"pcon2"]; //sample name in abi file

                }//end if ...
                //copy the file to the new directory
                [[NSFileManager defaultManager] copyItemAtURL:originalFileURL toURL:targetFileURL error:nil];
            }//end for...
            return YES;
        }//end if ...
    }//end if ... NSFilenamesPboardType
    return NO;
} //end tableView:acceptDrop:row:dropOperation:

//- (void)tableViewSelectionDidChange:(NSNotification *)aNotification{
//    [self readAbi:nil];
//}



#pragma mark - splitview delegate
- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview;
{
    //NSView* leftView = [[splitView subviews] objectAtIndex:0];
    //NSLog(@"%@:%s returning %@",[self class], _cmd, ([subview isEqual:leftView])?@"YES":@"NO");
    return YES;//([subview isEqual:leftView]);
}

- (BOOL)splitView:(NSSplitView *)splitView shouldCollapseSubview:(NSView *)subview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex
{
    //NSView* leftView = [[splitView subviews] objectAtIndex:0];
    //NSLog(@"%@:%s returning %@",[self class], _cmd, ([subview isEqual:leftView])?@"YES":@"NO");
    return YES;//([subview isEqual:leftView]);
}
-(IBAction)toggleWatchBoxes:(id)sender {
    BOOL leftViewCollapsed = [[self mySplitView] isSubviewCollapsed:[[[self mySplitView] subviews] objectAtIndex: 0]];
    //NSLog(@"%@:%s toggleInspector isCollapsed: %@",[self class], _cmd, leftViewCollapsed?@"YES":@"NO");
    if (leftViewCollapsed) {
        [self uncollapseLeftView];
    } else {
        [self collapseLeftView];
    }
}

- (IBAction)toggleUILayout:(id)sender {
    NSSegmentedControl *segmentedControl = (NSSegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegment;
    BOOL leftViewCollapsed = [[self mySplitView] isSubviewCollapsed:[[[self mySplitView] subviews] objectAtIndex: 0]];
    BOOL middleViewCollapsed = [[self mySplitView] isSubviewCollapsed:[[[self mySplitView] subviews] objectAtIndex: 1]];
    if (selectedSegment == 0) {
        if (leftViewCollapsed && middleViewCollapsed) {
            [self uncollapseLeftAndMiddleView];
        }
        else if (leftViewCollapsed) {
            [self uncollapseLeftView];
        }
    }//end if
    if (selectedSegment == 1) {
        if (!leftViewCollapsed) {
            [self collapseLeftView];
        }
        if (middleViewCollapsed){
            [self uncollapseLeftAndMiddleView];
            [self collapseLeftView];
        }
        
    }//end if
    if (selectedSegment == 2) {
        if (!leftViewCollapsed && !middleViewCollapsed) {
            [self collapseLeftAndMiddleView];
        }
        else if (!leftViewCollapsed || !middleViewCollapsed) {
            [self collapseLeftAndMiddleView];
        }
    }//end if
    
}//end toggleUILayout

-(void)collapseLeftView
{
    CGFloat dividerThickness = [[self mySplitView] dividerThickness];
    NSView *left = [[[self mySplitView] subviews] objectAtIndex:0];
    NSView *middle  = [[[self mySplitView] subviews] objectAtIndex:1];
    NSView *right = [[[self mySplitView] subviews] objectAtIndex:2];
    
    NSRect leftFrame = [left frame];
    NSRect middleFrame = [middle frame];
    NSRect rightFrame = [right frame];
    NSRect overallFrame = [[self mySplitView] frame];
    
    [left setHidden:YES];
    CGFloat originDifference=middleFrame.origin.x-leftFrame.origin.x;
    CGFloat newMiddleOrigin=middleFrame.origin.x-originDifference+dividerThickness;
    CGFloat newRightOrigin=rightFrame.origin.x-originDifference+dividerThickness;
    int leftWidth = leftFrame.size.width;
    [right setFrameSize:NSMakeSize(rightFrame.size.width+leftWidth,overallFrame.size.height)];
    [right setFrameOrigin:NSMakePoint(newRightOrigin, rightFrame.origin.y)];
    [middle setFrameOrigin:NSMakePoint(newMiddleOrigin, middleFrame.origin.y)];
    [[self mySplitView] display];
}
-(void)uncollapseLeftView
{
    CGFloat dividerThickness = [[self mySplitView] dividerThickness];
    NSView *left = [[[self mySplitView] subviews] objectAtIndex:0];
    NSView *middle  = [[[self mySplitView] subviews] objectAtIndex:1];
    NSView *right = [[[self mySplitView] subviews] objectAtIndex:2];
    
    // get the different frames
    NSRect leftFrame = [left frame];
    NSRect middleFrame = [middle frame];
    NSRect rightFrame = [right frame];
    NSRect overallFrame = [[self mySplitView] frame];
    [left setHidden:NO];
    
    // Adjust left frame size
    middleFrame.origin.x+=leftFrame.size.width + dividerThickness;
    rightFrame.size.width-=leftFrame.size.width;
    rightFrame.origin.x+=leftFrame.size.width + dividerThickness;
    
    [middle setFrameSize:middleFrame.size];
    [middle setFrameOrigin:middleFrame.origin];
    [right setFrameSize:rightFrame.size];
    [right setFrameOrigin:rightFrame.origin];
    [[self mySplitView] display];
}

-(void)collapseLeftAndMiddleView
{
    CGFloat dividerThickness = [[self mySplitView] dividerThickness];
    NSView *left = [[[self mySplitView] subviews] objectAtIndex:0];
    NSView *middle  = [[[self mySplitView] subviews] objectAtIndex:1];
    NSView *right = [[[self mySplitView] subviews] objectAtIndex:2];
    
    NSRect leftFrame = [left frame];
    NSRect middleFrame = [middle frame];
    NSRect rightFrame = [right frame];
    NSRect overallFrame = [[self mySplitView] frame];
    
    [left setHidden:YES];
    [middle setHidden:YES];
    CGFloat originDifference=rightFrame.origin.x-leftFrame.origin.x-middleFrame.origin.x;
    CGFloat newRightOrigin=rightFrame.origin.x-originDifference+2*dividerThickness;
    int leftWidth = leftFrame.size.width;
    int middleWidth = middleFrame.size.width;
    [right setFrameSize:NSMakeSize(rightFrame.size.width+leftWidth+middleWidth,overallFrame.size.height)];
    [right setFrameOrigin:NSMakePoint(newRightOrigin, rightFrame.origin.y)];
    [[self mySplitView] display];
}
-(void)uncollapseLeftAndMiddleView
{
    CGFloat dividerThickness = [[self mySplitView] dividerThickness];
    NSView *left = [[[self mySplitView] subviews] objectAtIndex:0];
    NSView *middle  = [[[self mySplitView] subviews] objectAtIndex:1];
    NSView *right = [[[self mySplitView] subviews] objectAtIndex:2];
    
    // get the different frames
    NSRect leftFrame = [left frame];
    NSRect middleFrame = [middle frame];
    NSRect rightFrame = [right frame];
    NSRect overallFrame = [[self mySplitView] frame];
    [left setHidden:NO];
    [middle setHidden:NO];
    // Adjust left frame size
    rightFrame.origin.x+=leftFrame.size.width + middleFrame.size.width + 2*dividerThickness;
    rightFrame.size.width-=leftFrame.size.width-middleFrame.size.width;
    
    [middle setFrameSize:middleFrame.size];
    [middle setFrameOrigin:middleFrame.origin];
    [right setFrameSize:rightFrame.size];
    [right setFrameOrigin:rightFrame.origin];
    [[self mySplitView] display];
}

@end
