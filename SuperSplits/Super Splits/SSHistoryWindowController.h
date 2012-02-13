//
//  SSHistoryWindowController.h
//  Super Splits
//
//  Created by Eric Seidel on 12/8/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SSMainController;

@interface SSHistoryWindowController : NSWindowController

// FIXME: This should be the RunController once we move the referenceRun out of MainController.
@property (retain) SSMainController *mainController;

@property (readonly) NSArray *runs;

@end
