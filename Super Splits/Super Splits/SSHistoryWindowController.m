//
//  SSHistoryWindowController.m
//  Super Splits
//
//  Created by Eric Seidel on 12/8/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSHistoryWindowController.h"

#import "SSCoreDataController.h"

@implementation SSHistoryWindowController

@synthesize coreDataController=_coreDataController;

- (NSManagedObjectContext *)managedObjectContext
{
    return _coreDataController.managedObjectContext;
}

- (id)initWithWindow:(NSWindow *)window
{
    if (self = [super initWithWindow:window]) {
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
