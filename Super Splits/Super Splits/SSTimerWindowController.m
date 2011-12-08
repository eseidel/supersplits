//
//  SSWindowController.m
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSRunController.h"
#import "SSTimerWindowController.h"
#import "SSTimeIntervalFormatter.h"


@implementation SSTimerWindowController

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
    [self updateTimerViews]; // Do one last update.
}

-(void)updateTimerViews
{
    SSRunController *run = [_mainController currentRun];
    [totalTimeView setObjectValue:[run totalTime]];
    [roomTimeView setObjectValue:[run roomTime]];
    [lastRoomSplitView setObjectValue:[run lastRoomSplit]];
}

@end
