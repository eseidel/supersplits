//
//  SSDebugWindowController.h
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SSMainController;

@interface SSDebugWindowController : NSWindowController

// FIXME: This should be SSRunController eventually.
@property (retain) SSMainController *mainController;

@end
