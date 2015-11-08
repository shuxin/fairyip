//
//  test_201301_AppDelegate.h
//  fairyip_loader
//
//  Created by fairy tale on 13-1-26.
//  Copyright (c) 2013年 fairytale. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface test_201301_AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;
////////////////////////

@property (weak) IBOutlet NSTextField *myTextView;

- (IBAction)startup_loader:(id)sender;


/*
@property (weak) IBOutlet NSTextField *lable_text;
- (IBAction)start_loader:(id)sender;
*/

@end
