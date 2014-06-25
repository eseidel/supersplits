//
//  SSHistoryWindowController.m
//  Super Splits
//
//  Created by Eric Seidel on 12/8/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSHistoryWindowController.h"

#import "SSMainController.h"
#import "SSRunBuilder.h"

@implementation SSHistoryWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(NSArray *)runs
{
    NSMutableArray *runs = [NSMutableArray array];
    [runs addObject:_mainController.runBuilder.run];
    if (_mainController.referenceRun)
        [runs addObject:_mainController.referenceRun];
    return runs;
}

@end
