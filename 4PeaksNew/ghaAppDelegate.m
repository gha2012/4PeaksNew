//
//  ghaAppDelegate.m
//  4PeaksNew
//
//  Created by Gregor Hagelueken on 11/08/2012.
//  Copyright (c) 2012 Gregor Hagelueken. All rights reserved.
//

#import "ghaAppDelegate.h"
#import "WatchBox.h"
#import "SequenceFile.h"
#import "ghaAbifFile.h"

@implementation ghaAppDelegate

@synthesize watchBoxesTableView = _watchBoxesTableView;
@synthesize watchBoxesArrayController = _watchBoxesArrayController;
@synthesize sequenceFileArrayController = _sequenceFileArrayController;
@synthesize tagsDictionaryController = _tagsDictionaryController;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize selectedAbifFile = _selectedAbifFile;
@synthesize sequenceView = _sequenceView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (void)awakeFromNib {
    //register for dropable files
    [_watchBoxesTableView registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    
    // tell NSTableView we want to drag and drop accross applications
	// the default has forLocal:YES
	[_watchBoxesTableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
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
        ghaAbifFile *abifFile=[[ghaAbifFile alloc ] initWithAbifFileAtURL:sequenceFileURL];
        _selectedAbifFile=abifFile;
        NSLog(@"%@",[_selectedAbifFile valueForKeyPath:@"seq"]);
        [_sequenceView setString:[_selectedAbifFile valueForKeyPath:@"seq"]];
        NSLog(@"read file");
    }
    else
        NSLog(@"no file to read");
    
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
    //Find out which sequenceFiles are in the selected watchbox and write the paths to an array
    NSArray *sequenceFilesInWatchBox = [NSArray arrayWithArray:[_sequenceFileArrayController arrangedObjects]];
    NSMutableArray *filesToBeDragged =[NSMutableArray array];
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
        }
    
    for (NSString *sourceFilePath in filesToBeDragged) {
        NSURL *sourceURL = [NSURL fileURLWithPath:sourceFilePath];
        NSURL *destinationURL = [[NSURL fileURLWithPath: destinationFolderPath] URLByAppendingPathComponent:[sourceFilePath lastPathComponent]];
        [[NSFileManager defaultManager] copyItemAtURL:sourceURL toURL:destinationURL error:nil];
    }//end for
    NSLog(@"drop");
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
		
        //create new Watchbox for all dropped files
        WatchBox *newWatchBox = [NSEntityDescription insertNewObjectForEntityForName:@"WatchBox" inManagedObjectContext:[self managedObjectContext]];
        NSUInteger counter = [[_watchBoxesArrayController content] count];
        [newWatchBox setValue: [NSString stringWithFormat:@"New WatchBox %li", counter] forKey:@"watchBoxName"];
        
        //create a folder for the watchbox
        NSString *uniqueID = [[NSProcessInfo processInfo] globallyUniqueString];
        NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
        NSURL *uniqueWatchBoxDirectory = [applicationFilesDirectory URLByAppendingPathComponent:uniqueID isDirectory:YES];
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
            //copy the file to the new directory
            [[NSFileManager defaultManager] copyItemAtURL:originalFileURL toURL:targetFileURL error:nil];
            
        } // end for
        return YES;
    }//end if ... NSFilenamesPboardType
    return NO;
} //end tableView:acceptDrop:row:dropOperation:

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification{
    [self readAbi:nil];
}
@end
