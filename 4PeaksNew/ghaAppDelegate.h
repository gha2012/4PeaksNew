//
//  ghaAppDelegate.h
//  4PeaksNew
//
//  Created by Gregor Hagelueken on 11/08/2012.
//  Copyright (c) 2012 Gregor Hagelueken. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ghaAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

@end
