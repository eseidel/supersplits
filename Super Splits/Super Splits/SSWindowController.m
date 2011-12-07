//
//  SSWindowController.m
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSWindowController.h"
#import "SSTimeIntervalFormatter.h"


@implementation SSWindowController

@synthesize mainController=_mainController;

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self.window setLevel:NSStatusWindowLevel];

    [totalTimeView setFormatter:[[SSTimeIntervalFormatter alloc] init]];
    [roomTimeView setFormatter:[[SSTimeIntervalFormatter alloc] init]];
    [lastRoomSplitView setFormatter:[[SSTimeIntervalFormatter alloc] init]];

    [self updateTimerViews];
}

-(void)startUpdating
{
    _updateTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0f / 10.0f)
                                                    target:self
                                                  selector:@selector(updateTimerViews)
                                                  userInfo:self
                                                   repeats:true];
}

-(void)stopUpdating
{
    [_updateTimer invalidate];
}

-(void)updateTimerViews
{
    [totalTimeView setObjectValue:[_mainController totalTime]];
    [roomTimeView setObjectValue:[_mainController roomTime]];
    [lastRoomSplitView setObjectValue:[_mainController lastRoomSplit]];
}

@end
