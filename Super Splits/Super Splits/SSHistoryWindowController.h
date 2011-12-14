//
//  SSHistoryWindowController.h
//  Super Splits
//
//  Created by Eric Seidel on 12/8/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SSCoreDataController;

@interface SSHistoryWindowController : NSWindowController
{
    SSCoreDataController *_coreDataController;
}

@property (retain) SSCoreDataController *coreDataController;
@property (readonly) NSManagedObjectContext *managedObjectContext;

@end
